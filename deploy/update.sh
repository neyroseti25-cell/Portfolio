#!/bin/bash
# ==============================================
# Скрипт обновления сайта после git push
# Запускать: bash ~/site/deploy/update.sh
# ==============================================

set -e

cd /home/tatiana/site
git pull origin main
source venv/bin/activate
pip install -r requirements.txt --quiet
sudo systemctl restart portfolio
echo "Сайт обновлен и перезапущен!"
