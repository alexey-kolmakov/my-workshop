#!/bin/bash
# INFO:[THUNAR] OCR-обробка PDF в Thunar


export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

PDF=$(realpath "$1")

if [ ! -f "$PDF" ]; then
    zenity --error --text="Файл не найден:\n$PDF"
    exit 1
fi

DIR=$(dirname "$PDF")
BASE=$(basename "$PDF" .pdf)
OUTPUT="$DIR/${BASE}_OCR.pdf"

# Проверяем, есть ли текст в PDF
if pdffonts "$PDF" | grep -q .; then
    # PDF уже содержит текст → пропускаем OCR
    ocrmypdf --skip-text "$PDF" "$OUTPUT" 2> /tmp/ocr_error.log
else
    # PDF без текста → спрашиваем язык для OCR
    LANG_OCR=$(zenity --entry --title="Выберите язык OCR" \
    --text="Введите язык(-и) через + (например: rus+ukr, eng, deu)" \
    --entry-text "rus+ukr")

    ocrmypdf -l "$LANG_OCR" --deskew --clean "$PDF" "$OUTPUT" 2> /tmp/ocr_error.log
fi

# Проверка успешного создания файла
if [ ! -f "$OUTPUT" ]; then
    zenity --error --text="OCR не выполнен!\nСмотрите лог: /tmp/ocr_error.log"
    exit 1
fi

# Открываем файл сразу в Evince
zenity --info --text="OCR завершен!\nФайл создан:\n$OUTPUT"
evince "$OUTPUT"
