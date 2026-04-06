#!/bin/bash
# INFO: [THUNAR] відкриває у редакторі задану сторінку pdf

PDF="$1"
TMPFILE="/tmp/pdf_text_$$.txt"

# Проверка
if [ -z "$PDF" ]; then
  zenity --error --text="Не выбран PDF файл!"
  exit 1
fi

# Запрос диапазона страниц
PAGES=$(zenity --entry \
  --title="Копирование PDF" \
  --text="Введите страницы (пример: 3-5 или 7).\nОставьте пустым — весь файл:")

# Отмена
[ $? -ne 0 ] && exit 0

# Извлечение текста
if [ -z "$PAGES" ]; then
  pdftotext "$PDF" "$TMPFILE"
else
  if [[ "$PAGES" == *"-"* ]]; then
    START=$(echo "$PAGES" | cut -d- -f1)
    END=$(echo "$PAGES" | cut -d- -f2)
    pdftotext -f "$START" -l "$END" "$PDF" "$TMPFILE"
  else
    pdftotext -f "$PAGES" -l "$PAGES" "$PDF" "$TMPFILE"
  fi
fi

# Копируем в буфер
xclip -selection clipboard < "$TMPFILE"

# Открываем в редакторе (можно заменить на любой)
featherpad "$TMPFILE" &

# Сообщение
zenity --info --text="Готово!\nТекст скопирован и открыт в редакторе."
