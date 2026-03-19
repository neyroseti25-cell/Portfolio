#!/bin/bash
# ==============================================
# Скрипт первоначальной настройки VPS
# Запускать от root: bash setup-server.sh
# ==============================================

set -e

echo "=== 1. Обновление системы ==="
apt update && apt upgrade -y

echo "=== 2. Установка ПО ==="
apt install -y python3 python3-pip python3-venv nginx git ufw certbot python3-certbot-nginx

echo "=== 3. Создание пользователя tatiana ==="
if ! id "tatiana" &>/dev/null; then
    adduser --gecos "" tatiana
    usermod -aG sudo tatiana
    echo "Пользователь tatiana создан"
else
    echo "Пользователь tatiana уже существует"
fi

echo "=== 4. Настройка файрвола ==="
ufw allow OpenSSH
ufw allow 'Nginx Full'
echo "y" | ufw enable

echo "=== 5. Готово! ==="
echo ""
echo "Следующие шаги:"
echo "  1. На вашем Mac выполните: ssh-copy-id tatiana@$(hostname -I | awk '{print $1}')"
echo "  2. Подключитесь: ssh tatiana@$(hostname -I | awk '{print $1}')"
echo "  3. Запустите скрипт deploy-app.sh"
