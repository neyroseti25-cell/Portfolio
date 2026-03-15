from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, TextAreaField, SubmitField
from wtforms.validators import DataRequired, Email, Length, Optional, Regexp


class LoginForm(FlaskForm):
    username = StringField('Логин', validators=[
        DataRequired(message='Введите логин'),
        Length(min=3, max=80, message='Логин должен быть от 3 до 80 символов')
    ])
    password = PasswordField('Пароль', validators=[
        DataRequired(message='Введите пароль')
    ])
    submit = SubmitField('Войти')


class ContactForm(FlaskForm):
    name = StringField('Имя', validators=[
        DataRequired(message='Введите ваше имя'),
        Length(min=2, max=100, message='Имя должно быть от 2 до 100 символов')
    ])
    email = StringField('Email', validators=[
        DataRequired(message='Введите email'),
        Email(message='Введите корректный email'),
        Length(max=120)
    ])
    phone = StringField('Телефон', validators=[
        Optional(),
        Regexp(r'^[\+]?[\d\s\-\(\)]{7,20}$', message='Введите корректный номер телефона')
    ])
    subject = StringField('Тема сообщения', validators=[
        DataRequired(message='Укажите тему сообщения'),
        Length(min=3, max=200, message='Тема должна быть от 3 до 200 символов')
    ])
    message = TextAreaField('Сообщение', validators=[
        DataRequired(message='Напишите сообщение'),
        Length(min=10, max=5000, message='Сообщение должно быть от 10 до 5000 символов')
    ])
    submit = SubmitField('Отправить')
