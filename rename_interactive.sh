#!/bin/bash
# INFO: [СОРТУВАННЯ] обробляє файли .docx .txt .pdf


# Проводит разборки с файлами .docx .txt .pdf


TARGET_DIR="$1"
LOGFILE="$HOME/.rename_log.txt"
mkdir -p "$TARGET_DIR"

# Перевірка залежностей
for cmd in docx2txt pdftotext xclip notify-send zenity; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ Команда $cmd не знайдена. Встанови її перед запуском."
    exit 1
  fi
done

cd "$TARGET_DIR" || exit
echo "📁 Обробка: $TARGET_DIR" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

for file in *; do
  [ -f "$file" ] || continue
  ext="${file##*.}"
  TMPFILE=$(mktemp)

  # Витяг тексту
  case "$ext" in
    docx) docx2txt "$file" "$TMPFILE" ;;
    txt|md) cp "$file" "$TMPFILE" ;;
    pdf) pdftotext "$file" "$TMPFILE" ;;
    *) continue ;;
  esac

  # Попередній перегляд
  zenity --text-info --filename="$TMPFILE" --title="📄 $file" --width=600 --height=400

  # Заголовок
  TITLE=$(head -n 1 "$TMPFILE" | sed 's/[[:space:]]\+/ /g' | tr -d '\r\n' | cut -c1-80)
  [ -z "$TITLE" ] && continue
  SAFE_TITLE=$(echo "$TITLE" | sed 's/[^a-zA-Zа-яА-Я0-9 _-]/_/g')

  # Запит на підтвердження
  NEWNAME=$(zenity --entry --title="✏️ Нове ім’я для $file" --text="Заголовок:\n$TITLE\n\nВведи або підтверди нове ім’я:" --entry-text="$SAFE_TITLE")
  [ -z "$NEWNAME" ] && continue

  FINAL="${NEWNAME}.${ext}"
  COUNT=1
  while [ -e "$FINAL" ]; do
    COUNT=$((COUNT + 1))
    FINAL="${NEWNAME} ($COUNT).${ext}"
  done

  mv "$file" "$FINAL"
  echo "$file → $FINAL" >> "$LOGFILE"
  echo -n "$FINAL" | xclip -selection clipboard
  notify-send "✅ Переіменовано" "$file → $FINAL"
  rm "$TMPFILE"
done

echo "✅ Готово! Усі файли оброблено." >> "$LOGFILE"
