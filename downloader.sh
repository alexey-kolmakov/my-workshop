#!/bin/bash

# Файл со списком (должен быть в той же папке)
LIST_FILE="files.txt"

# Проверяем, существует ли файл списка
if [[ ! -f "$LIST_FILE" ]]; then
    zenity --error --text="Файл $LIST_FILE не найден!"
    exit 1
fi

# 1. Формируем данные для Zenity. 
# Мы берем из файла Имя и Описание, а Ссылку прячем.
# Используем awk, чтобы превратить "имя|описание|ссылка" в формат для колонок Zenity.
selected_item=$(awk -F'|' '{print $1 "\n" $2 "\n" $3}' "$LIST_FILE" | \
    zenity --list \
    --title="Мои Скрипты" \
    --column="Скрипт" --column="Что делает" --column="URL (скрыто)" \
    --hide-column=3 \
    --print-column=3 \
    --width=700 --height=500 \
    --text="Выбери нужный инструмент:")

# 2. Если пользователь нажал "Отмена" или закрыл окно
if [[ -z "$selected_item" ]]; then
    exit 0
fi

# 3. Извлекаем имя файла из выбранной строки (нужно для сохранения)
# Так как мы вывели в переменную $selected_item только 3-ю колонку (--print-column=3),
# нам нужно найти, какому имени файла она соответствует.
file_to_save=$(grep "|$selected_item" "$LIST_FILE" | cut -d'|' -f1)

# 4. Процесс загрузки
(
echo "10" ; sleep 1
echo "# Начинаю загрузку $file_to_save..." ; sleep 1
curl -L "$selected_item" -o "$file_to_save"
echo "100" ; sleep 1
echo "# Готово! Скрипт сохранен."
) | zenity --progress --title="Загрузка" --auto-close --pulsate

# 5. Делаем файл исполняемым
chmod +x "$file_to_save"

zenity --info --text="Скрипт <b>$file_to_save</b> успешно скачан и готов к запуску!" --timeout=3
