#!/bin/bash
# INFO: [СИСТЕМА] видаляє метадані з фото


# Проверяем наличие exiftool
if ! command -v exiftool >/dev/null 2>&1; then
    zenity --error --text="ExifTool не установлен.\nУстанови: sudo apt install libimage-exiftool-perl"
    exit 1
fi

# Выбор папки
DIR=$(zenity --file-selection --directory --title="Выбери папку для очистки")
[ -z "$DIR" ] && exit 0

# Сбор файлов
FILES=$(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

if [ -z "$FILES" ]; then
    zenity --info --text="В выбранной папке нет изображений."
    exit 0
fi

COUNT=$(echo "$FILES" | wc -l)
i=0

(
for FILE in $FILES; do
    exiftool -overwrite_original -all= "$FILE" >/dev/null 2>&1
    i=$((i+1))
    PERCENT=$((100 * i / COUNT))
    echo "$PERCENT"
    echo "# Очищено: $FILE"
done
) | zenity --progress \
           --title="Очистка метаданных" \
           --percentage=0 \
           --auto-close

zenity --info --text="Готово! Очищено файлов: $COUNT"
