#!/bin/bash
# INFO: [СОРТУВАННЯ] оптове перейменування файлів


# Папка з файлами
TARGET_DIR="$1"
LOGFILE="$HOME/.rename_log.txt"
mkdir -p "$TARGET_DIR"

# Перевірка залежностей
for cmd in docx2txt xclip notify-send; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ Команда $cmd не знайдена. Встанови її перед запуском."
    exit 1
  fi
done

# Створення тимчасової папки для витягу тексту
TMPDIR=$(mktemp -d)

# Переіменування
echo "📁 Починаю обробку файлів у: $TARGET_DIR"
echo "📝 Лог: $LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

cd "$TARGET_DIR" || exit

for file in *.docx; do
  [ -f "$file" ] || continue

  # Витяг тексту
  docx2txt "$file" "$TMPDIR/text.txt" &> /dev/null
  TITLE=$(head -n 1 "$TMPDIR/text.txt" | sed 's/[[:space:]]\+/ /g' | tr -d '\r\n' | cut -c1-80)

  # Якщо заголовок порожній — пропустити
  if [ -z "$TITLE" ]; then
    echo "⚠️ $file — заголовок не знайдено" >> "$LOGFILE"
    continue
  fi

  # Очистити заголовок для імені
  SAFE_TITLE=$(echo "$TITLE" | sed 's/[^a-zA-Zа-яА-Я0-9 _-]/_/g')

  # Перевірка на дублікати
  NEWNAME="${SAFE_TITLE}.docx"
  COUNT=1
  while [ -e "$NEWNAME" ]; do
    COUNT=$((COUNT + 1))
    NEWNAME="${SAFE_TITLE} ($COUNT).docx"
  done

  # Переіменування
  mv "$file" "$NEWNAME"
  echo "$file → $NEWNAME" >> "$LOGFILE"

  # Копіювання в буфер
  echo -n "$NEWNAME" | xclip -selection clipboard

  # Повідомлення
  notify-send "✅ Переіменовано" "$file → $NEWNAME"
done

# Прибирання
rm -r "$TMPDIR"
echo "✅ Готово! Усі файли оброблено." >> "$LOGFILE"

