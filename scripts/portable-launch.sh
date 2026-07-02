#!/bin/bash
# INFO: [СИСТЕМА] Скрипт вимикає інші скрипти у перенесенні

# Каталог, где лежит portable-launch.sh
DIR="$(dirname "$(readlink -f "$0")")"

# Убиваем старый run.sh
pkill -f "$DIR/../run.sh" 2>/dev/null

# Убиваем браузеры
killall python3 firefox firefox-bin 2>/dev/null

killall python3 Min min 2>/dev/null
