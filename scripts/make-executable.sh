#!/bin/bash

# Проверка наличия zenity
if ! command -v zenity >/dev/null; then
    echo "Ошибка: zenity не установлен. Установите: sudo apt install zenity"
    exit 1
fi

# Запрос пути к файлу
FILE=$(zenity --entry --title="Сделать файл исполняемым" \
  --text="Введите полный путь к файлу:")

# Если нажали "Отмена"
if [ -z "$FILE" ]; then
    exit 0
fi

# Проверка существования файла
if [ -f "$FILE" ]; then
  chmod +x "$FILE"
  zenity --info --title="Готово!" \
    --text="Файл:\n$FILE\nтеперь исполняемый!"
else
  zenity --error --title="Ошибка" \
    --text="Файл не найден:\n$FILE"
fi
