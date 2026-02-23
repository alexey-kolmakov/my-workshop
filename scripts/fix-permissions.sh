#!/bin/bash
# fix-permissions.sh — модуль для исправления прав доступа.
# Использование:
#   ./fix-permissions.sh /path/to/folder
#
# Скрипт:
#   - ставит владельца текущего пользователя
#   - выставляет 755 для директорий
#   - выставляет 644 для файлов

TARGET="$1"

if [ -z "$TARGET" ]; then
    echo "Использование: $0 /path/to/folder"
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "Ошибка: $TARGET не является директорией."
    exit 1
fi

echo "Исправляю права в $TARGET..."

# Меняем владельца на текущего пользователя
chown -R "$(whoami)":"$(whoami)" "$TARGET"

# Права для директорий
find "$TARGET" -type d -exec chmod 755 {} \;

# Права для файлов
find "$TARGET" -type f -exec chmod 644 {} \;

echo "Готово: права исправлены."
