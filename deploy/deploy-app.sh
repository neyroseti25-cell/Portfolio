#!/bin/bash
# ==============================================
# Скрипт деплоя приложения
# Запускать от пользователя tatiana: bash deploy-app.sh
# ==============================================

set -e

DOMAIN="tatidzufri.com"
APP_DIR="/home/tatiana/site"
PROJECTS_DIR="/home/tatiana/projects"

echo "=== 1. Клонирование проекта ==="
if [ -d "$APP_DIR" ]; then
    echo "Папка $APP_DIR уже существует, обновляю..."
    cd "$APP_DIR"
    git pull origin main
else
    cd /home/tatiana
    git clone https://github.com/neyroseti25-cell/Portfolio.git site
    cd "$APP_DIR"
fi

echo "=== 2. Виртуальное окружение и зависимости ==="
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo "=== 3. Файл .env ==="
if [ ! -f ".env" ]; then
    SECRET=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    cat > .env << EOF
SECRET_KEY=$SECRET
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123
EOF
    echo "Файл .env создан. ОБЯЗАТЕЛЬНО смените ADMIN_PASSWORD!"
    echo "  nano $APP_DIR/.env"
else
    echo "Файл .env уже существует"
fi

echo "=== 4. Инициализация базы данных ==="
python3 -c "from app import app, init_db; init_db()"

echo "=== 5. Настройка systemd-сервиса ==="
sudo cp "$APP_DIR/deploy/portfolio.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start portfolio
sudo systemctl enable portfolio

echo "=== 6. Настройка Nginx ==="
sudo cp "$APP_DIR/deploy/nginx-portfolio.conf" /etc/nginx/sites-available/portfolio
sudo ln -sf /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

echo "=== 7. Создание папки для кейс-проектов ==="
mkdir -p "$PROJECTS_DIR"/{vk-generator,rag-assistant,competitor-ai,web-scraper,business-reports,llm-fine-tuning}

echo ""
echo "=========================================="
echo " Сайт запущен: http://$DOMAIN"
echo "=========================================="
echo ""
echo "Следующий шаг — SSL-сертификат:"
echo "  sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN"
echo ""
echo "Проверить статус:"
echo "  sudo systemctl status portfolio"
echo "  sudo systemctl status nginx"
echo ""
echo "Папка для кейсов: $PROJECTS_DIR"
