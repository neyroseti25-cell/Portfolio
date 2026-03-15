import logging
from flask import Flask, render_template, redirect, url_for, flash, request, abort
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from config import Config
from models import db, Admin, ContactMessage
from forms import LoginForm, ContactForm

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.FileHandler('app.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config.from_object(Config)

db.init_app(app)

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'admin_login'
login_manager.login_message = 'Пожалуйста, войдите для доступа к админ-панели.'
login_manager.login_message_category = 'warning'


@login_manager.user_loader
def load_user(user_id):
    return db.session.get(Admin, int(user_id))


def init_db():
    """Create tables and default admin user."""
    with app.app_context():
        db.create_all()
        if not Admin.query.filter_by(username=Config.ADMIN_USERNAME).first():
            admin = Admin(username=Config.ADMIN_USERNAME)
            admin.set_password(Config.ADMIN_PASSWORD)
            db.session.add(admin)
            db.session.commit()
            logger.info('Default admin user created: %s', Config.ADMIN_USERNAME)


# --- Public routes ---

@app.route('/')
def index():
    cases = Config.CASES
    return render_template('index.html', cases=cases)


@app.route('/cases')
def cases():
    cases_list = Config.CASES
    return render_template('cases.html', cases=cases_list)


@app.route('/case/<slug>')
def case_detail(slug):
    case = next((c for c in Config.CASES if c['slug'] == slug), None)
    if case is None:
        abort(404)
    return render_template('case_detail.html', case=case, cases=Config.CASES)


@app.route('/contact', methods=['GET', 'POST'])
def contact():
    form = ContactForm()
    if form.validate_on_submit():
        msg = ContactMessage(
            name=form.name.data,
            email=form.email.data,
            phone=form.phone.data or '',
            subject=form.subject.data,
            message=form.message.data
        )
        db.session.add(msg)
        db.session.commit()
        logger.info('New contact message from %s <%s>: %s', msg.name, msg.email, msg.subject)
        flash('Сообщение отправлено! Я свяжусь с вами в ближайшее время.', 'success')
        return redirect(url_for('contact'))
    return render_template('contact.html', form=form)


# --- Admin routes ---

@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    if current_user.is_authenticated:
        return redirect(url_for('admin_dashboard'))
    form = LoginForm()
    if form.validate_on_submit():
        admin = Admin.query.filter_by(username=form.username.data).first()
        if admin and admin.check_password(form.password.data):
            login_user(admin)
            logger.info('Admin logged in: %s', admin.username)
            next_page = request.args.get('next')
            return redirect(next_page or url_for('admin_dashboard'))
        flash('Неверный логин или пароль.', 'danger')
        logger.warning('Failed login attempt for: %s', form.username.data)
    return render_template('admin/login.html', form=form)


@app.route('/admin/logout')
@login_required
def admin_logout():
    logger.info('Admin logged out: %s', current_user.username)
    logout_user()
    flash('Вы вышли из системы.', 'info')
    return redirect(url_for('index'))


@app.route('/admin')
@login_required
def admin_dashboard():
    page = request.args.get('page', 1, type=int)
    messages = ContactMessage.query.order_by(
        ContactMessage.created_at.desc()
    ).paginate(page=page, per_page=15, error_out=False)
    unread_count = ContactMessage.query.filter_by(is_read=False).count()
    return render_template('admin/dashboard.html', messages=messages, unread_count=unread_count)


@app.route('/admin/message/<int:msg_id>/read', methods=['POST'])
@login_required
def mark_read(msg_id):
    msg = db.session.get(ContactMessage, msg_id)
    if msg is None:
        abort(404)
    msg.is_read = not msg.is_read
    db.session.commit()
    status = 'прочитано' if msg.is_read else 'не прочитано'
    logger.info('Message %d marked as %s', msg_id, status)
    return redirect(url_for('admin_dashboard'))


@app.route('/admin/message/<int:msg_id>/delete', methods=['POST'])
@login_required
def delete_message(msg_id):
    msg = db.session.get(ContactMessage, msg_id)
    if msg is None:
        abort(404)
    db.session.delete(msg)
    db.session.commit()
    logger.info('Message %d deleted', msg_id)
    flash('Заявка удалена.', 'info')
    return redirect(url_for('admin_dashboard'))


# --- Error handlers ---

@app.errorhandler(404)
def page_not_found(e):
    return render_template('base.html', error=True, error_code=404, error_msg='Страница не найдена'), 404


@app.errorhandler(500)
def internal_error(e):
    db.session.rollback()
    return render_template('base.html', error=True, error_code=500, error_msg='Внутренняя ошибка сервера'), 500


if __name__ == '__main__':
    init_db()
    logger.info('Application started')
    app.run(debug=True, host='0.0.0.0', port=5001)
