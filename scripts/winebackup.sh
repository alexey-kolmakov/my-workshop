#!/bin/bash

# Папка, где хранятся все префиксы
WINEPREFIX_BASE=~/prefixes

# Папка для бекапов
BACKUP_DIR=~/prefixes/backups
mkdir -p "$BACKUP_DIR"

# Получаем список префиксов
PREFIXES=("$WINEPREFIX_BASE"/*)

# Проверяем, есть ли префиксы
if [ ${#PREFIXES[@]} -eq 0 ]; then
    echo "Префиксов в $WINEPREFIX_BASE не найдено!"
    exit 1
fi

# Меню для выбора префикса
echo "Доступные префиксы:"
select PREFIX in "${PREFIXES[@]}"; do
    if [ -n "$PREFIX" ]; then
        echo "Выбран префикс: $PREFIX"
        
        # Создаём имя для бекапа с датой
        DATE=$(date +%Y-%m-%d_%H-%M-%S)
        PREFIX_NAME=$(basename "$PREFIX")
        BACKUP_NAME="${PREFIX_NAME}_backup_$DATE"
        BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

        # Копируем префикс
        cp -a "$PREFIX" "$BACKUP_PATH"

        # Проверка успешности
        if [ $? -eq 0 ]; then
            echo "✅ Бекап выполнен успешно: $BACKUP_PATH"
        else
            echo "❌ Что-то пошло не так!"
        fi
        break
    else
        echo "Неверный выбор, попробуйте ещё раз."
    fi
done
