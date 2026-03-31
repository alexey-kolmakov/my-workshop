#!/bin/bash
# INFO:[АРХІВ] скачує скрипти з GitHub


# --- НАСТРОЙКИ ---
USER="alexey-kolmakov"
REPO="my-workshop"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/$USER/$REPO/$BRANCH/scripts"
LIST_URL="https://raw.githubusercontent.com/$USER/$REPO/$BRANCH/files.txt"

# 1. Скачиваем список файлов и показываем индикатор загрузки
notify-send "Мастерская" "Синхронизация списка скриптов..." -i system-software-update
curl -s "$LIST_URL" -o /tmp/gh_files.txt

# 2. Подготовка данных для таблицы (имя | описание)
# Мы создаем временный файл для хранения строк таблицы
TABLE_DATA=()
while IFS= read -r filename || [ -n "$filename" ]; do
    [ -z "$filename" ] && continue
    filename=$(echo "$filename" | tr -d '\r')
    clean_name=$(basename "$filename")
    
    # Извлекаем описание (быстро, через curl первой строки)
    desc=$(curl -s "$RAW_URL/$clean_name" | grep -m 1 "^# INFO:" | sed 's/^# INFO: //')
    [ -z "$desc" ] && desc="Описание не найдено"
    
    # Добавляем в массив для Zenity
    TABLE_DATA+=("$clean_name" "$desc")
done < /tmp/gh_files.txt

# 3. Окно выбора скрипта
SELECTED=$(zenity --list \
    --title="Моя мастерская: $REPO" \
    --column="Файл" --column="Что делает этот скрипт?" \
    --width=700 --height=400 \
    "${TABLE_DATA[@]}")

# Если нажата отмена - выходим
if [ -z "$SELECTED" ]; then exit; fi

# 4. Окно выбора папки для сохранения
TARGET_DIR=$(zenity --file-selection --directory --title="Куда сохранить $SELECTED?")

if [ -z "$TARGET_DIR" ]; then exit; fi

# 5. Финальное скачивание
curl -s -L "$RAW_URL/$SELECTED" -o "$TARGET_DIR/$SELECTED"

if [ $? -eq 0 ]; then
    chmod +x "$TARGET_DIR/$SELECTED"
    zenity --info --text="Успешно!\nФайл: $SELECTED\nСохранен в: $TARGET_DIR" --title="Готово"
else
    zenity --error --text="Ошибка при загрузке файла." --title="Упс!"
fi

# Чистим временные файлы
rm /tmp/gh_files.txt
