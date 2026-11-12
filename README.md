# Татьяна AI — Портфолио сайт

Веб-приложение на Flask: портфолио AI-специалиста с кейсами, формой обратной связи и админ-панелью.

## Возможности

- **Главная страница** — hero-блок, ценностные предложения, bento-grid кейсов
- **Страница кейсов** — 6 подробных кейсов с детальными страницами
- **Форма обратной связи** — валидация, CSRF-защита, сохранение в БД
- **Админ-панель** — авторизация, просмотр/удаление заявок, отметка «прочитано»
- **Дизайн** — темная тема «Cyber-Business Minimal», анимации, адаптивная верстка

## Быстрый старт

### 1. Клонировать и перейти в папку

```bash
cd Site
```

### 2. Создать виртуальное окружение

```bash
python3 -m venv venv
source venv/bin/activate   # macOS/Linux
# venv\Scripts\activate    # Windows
```

### 3. Установить зависимости

```bash
pip install -r requirements.txt
```

### 4. Запустить приложение

```bash
python app.py
```

Сайт будет доступен по адресу: **http://localhost:5001**

## Админ-панель

- URL: http://localhost:5001/admin/login
- Логин: `admin`
- Пароль: `admin123`

Данные можно изменить через переменные окружения:

```bash
export ADMIN_USERNAME=mylogin
export ADMIN_PASSWORD=mypassword
export SECRET_KEY=my-secret-key
```

## Структура проекта

```
Site/
├── app.py                 # Основное приложение Flask
├── config.py              # Конфигурация и данные кейсов
├── models.py              # Модели базы данных (SQLAlchemy)
├── forms.py               # Формы (Flask-WTF)
├── requirements.txt       # Зависимости
├── README.md              # Документация
├── templates/
│   ├── base.html          # Базовый шаблон
│   ├── index.html         # Главная страница
│   ├── cases.html         # Список кейсов
│   ├── case_detail.html   # Детальная страница кейса
│   ├── contact.html       # Форма обратной связи
│   └── admin/
│       ├── login.html     # Вход в админку
│       └── dashboard.html # Панель управления
├── static/
│   ├── css/
│   │   └── style.css      # Стили (Cyber-Business Minimal)
│   ├── js/
│   │   └── main.js        # Анимации и интерактив
│   └── images/            # Изображения (добавить свои)
└── site.db                # SQLite база (создается автоматически)
```

## Деплой на VPS

В папке `deploy/` находятся готовые скрипты и конфиги:

```bash
# 1. На сервере от root — первоначальная настройка:
bash deploy/setup-server.sh

# 2. От пользователя tatiana — деплой приложения:
bash deploy/deploy-app.sh

# 3. SSL-сертификат:
sudo certbot --nginx -d tatidzufri.com -d www.tatidzufri.com

# 4. Обновление сайта после изменений:
bash deploy/update.sh
```

### Обычный выкат (с Mac)

```bash
git push origin main
ssh server 'bash ~/site/deploy/update.sh'
```

`update.sh` работает без sudo. Он выполняет `git pull --ff-only`, ставит зависимости, только если изменился `requirements.txt`, и мягко перезагружает gunicorn (HUP, без простоя). Затем проверяет `/`, `/cases`, `/contact`, `/robots.txt` и `/sitemap.xml` через сокет. Если проверка не прошла, скрипт печатает команду отката.

Полный рестарт (`ssh server-root 'systemctl restart portfolio'`) нужен только при обновлении gunicorn или правке юнита.

При изменении `static/css/style.css` поменяйте `v=` в `templates/base.html`. Nginx кэширует `/static` на 30 дней с `immutable`.

## Защита формы контактов от спама

- Скрытое поле-ловушка `website`: боты его заполняют, люди не видят.
- Подписанная метка времени `form_ts`: отклоняет заявки быстрее 3 секунд после открытия формы и поддельные метки.
- Спам отбрасывается молча: бот видит «успешно», в базу ничего не пишется. В лог пишется `Contact spam blocked (причина) from IP`.

Посмотреть отсеянное: `ssh server 'journalctl -u portfolio --since "-7 days" | grep "spam blocked"'`.

## Шрифты

Inter и Space Grotesk хранятся локально в `static/fonts/` (SIL OFL 1.1, вариативные, наборы латиница и кириллица). `@font-face` встроен в `base.html`, запросов к Google Fonts нет.

## Технологии

- Python 3.10+
- Flask 3.x
- Flask-SQLAlchemy (SQLite)
- Flask-Login
- Flask-WTF (CSRF-защита)
- Gunicorn (production)
- Nginx (reverse proxy)
- Jinja2 шаблоны
- CSS3 (glassmorphism, анимации, адаптив)
- Vanilla JavaScript (particles, scroll animations)
