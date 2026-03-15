# Татьяна AI — Портфолио сайт

Веб-приложение на Flask: портфолио AI-специалиста с кейсами, формой обратной связи и админ-панелью.

## Возможности

- **Главная страница** — hero-блок, ценностные предложения, bento-grid кейсов
- **Страница кейсов** — 5 подробных кейсов с детальными страницами
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

## Технологии

- Python 3.10+
- Flask 3.x
- Flask-SQLAlchemy (SQLite)
- Flask-Login
- Flask-WTF (CSRF-защита)
- Jinja2 шаблоны
- CSS3 (glassmorphism, анимации, адаптив)
- Vanilla JavaScript (particles, scroll animations)
