#!/bin/bash
# INFO: [СИСТЕМА] показує метадані фото


# Проверяем наличие exiftool
if ! command -v exiftool >/dev/null 2>&1; then
    zenity --error --text="ExifTool не установлен.\nУстанови: sudo apt install libimage-exiftool-perl"
    exit 1
fi

# Выбор папки
DIR=$(zenity --file-selection --directory --title="Выбери папку для проверки" 2>/dev/null)
[ -z "$DIR" ] && exit 0

# Сбор изображений
FILES=$(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

if [ -z "$FILES" ]; then
    zenity --info --text="В выбранной папке нет изображений."
    exit 0
fi

RESULT=""

for FILE in $FILES; do
    META=$(exiftool -EXIF:all -IPTC:all -XMP:all -GPS:all "$FILE" | grep -v "image files")

    if [ -z "$META" ]; then
        RESULT+="✔ $FILE — метаданные отсутствуют\n\n"
    else
        RESULT+="⚠ $FILE — найдены метаданные:\n$META\n\n"
    fi
done

# Вывод в растягиваемом окне с прокруткой
echo -e "$RESULT" | zenity --text-info \
    --title="Результат проверки метаданных" \
    --width=900 \
    --height=700 \
    --font="Monospace 10"
