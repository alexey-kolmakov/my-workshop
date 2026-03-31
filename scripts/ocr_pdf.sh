#!/bin/bash
# INFO: [THUNAR] работа с PDF


# Получаем файл (Thunar передает его через %f)
PDF="$1"

# Проверка
if [ -z "$PDF" ]; then
    zenity --error --text="Не выбран PDF файл!"
    exit 1
fi

# Генерируем имя нового файла
DIR=$(dirname "$PDF")
BASE=$(basename "$PDF" .pdf)
OUTPUT="$DIR/${BASE}_OCR.pdf"

# Запускаем OCR
ocrmypdf -l rus+eng --deskew --clean "$PDF" "$OUTPUT"

# Сообщение
zenity --info --text="OCR завершен!\nСоздан файл:\n$OUTPUT"
