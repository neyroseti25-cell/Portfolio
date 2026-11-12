#!/bin/bash
# ==============================================
# Обновление сайта после git push — без sudo.
#
# С Mac одной командой (после git push):
#   ssh server 'bash ~/site/deploy/update.sh'
#
# Что делает: git pull --ff-only → pip install (только если изменился
# requirements.txt) → graceful reload gunicorn (HUP мастер-процессу,
# без простоя) → проверка страниц через сокет.
# Полный рестарт сервиса нужен только при обновлении самого gunicorn
# или правке portfolio.service: ssh server-root 'systemctl restart portfolio'
# ==============================================

set -euo pipefail

# Всё тело — в функции main: bash прочитает файл целиком до запуска,
# поэтому git pull может безопасно перезаписать этот же скрипт.
main() {

SITE=/home/tatiana/site
SERVICE=portfolio
CHECK_PATHS=(/ /cases /contact /robots.txt /sitemap.xml)

cd "$SITE"

if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
    echo "✗ В $SITE есть незакоммиченные правки отслеживаемых файлов — разберитесь вручную:"
    git status --short --untracked-files=no
    exit 1
fi

OLD=$(git rev-parse --short HEAD)
REQ_OLD=$(sha256sum requirements.txt | cut -d' ' -f1)
GUNICORN_OLD=$(venv/bin/gunicorn --version 2>/dev/null || echo "?")

git pull --ff-only --quiet origin main
NEW=$(git rev-parse --short HEAD)

if [ "$OLD" = "$NEW" ]; then
    echo "Новых коммитов нет (HEAD $NEW), перезагрузка не нужна."
    exit 0
fi

echo "Обновление $OLD → $NEW:"
git log --oneline "$OLD..$NEW"

if [ "$(sha256sum requirements.txt | cut -d' ' -f1)" != "$REQ_OLD" ]; then
    echo "requirements.txt изменился — ставлю зависимости…"
    venv/bin/pip install --quiet -r requirements.txt
fi

if [ "$(venv/bin/gunicorn --version 2>/dev/null || echo "?")" != "$GUNICORN_OLD" ]; then
    echo "⚠ Изменилась версия gunicorn. HUP её не подхватит — нужен рестарт:"
    echo "    ssh server-root 'systemctl restart $SERVICE'"
fi

PID=$(systemctl show -p MainPID --value "$SERVICE")
if [ -z "$PID" ] || [ "$PID" -eq 0 ]; then
    echo "✗ Сервис $SERVICE не запущен. Запуск: ssh server-root 'systemctl start $SERVICE'"
    exit 1
fi

kill -HUP "$PID"
sleep 4

FAILED=0
for path in "${CHECK_PATHS[@]}"; do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 \
        --unix-socket "$SITE/portfolio.sock" -H 'Host: tatidzufri.com' "http://localhost$path" || echo "000")
    if [ "$code" = "200" ]; then
        echo "  ✓ $path $code"
    else
        echo "  ✗ $path $code"
        FAILED=1
    fi
done

WORKERS=$(pgrep -P "$PID" | wc -l)
echo "Воркеров gunicorn: $WORKERS"

if [ "$FAILED" -ne 0 ]; then
    echo "✗ Проверка не прошла. Логи: journalctl -u $SERVICE -n 50 --no-pager"
    echo "  Откат: cd $SITE && git reset --hard $OLD && kill -HUP $PID"
    exit 1
fi

echo "✓ Сайт обновлён до $NEW без простоя."

}

main "$@"
exit
