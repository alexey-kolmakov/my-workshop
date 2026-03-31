#!/bin/bash
# INFO:[АРХІВ] завантажує скрипти по tab
set -e

# ----------------------------
# Настройки
# ----------------------------
BASE_URL="https://raw.githubusercontent.com/alexey-kolmakov/my-workshop/main"
LOCAL_FILE="$HOME/files.txt"
DOWNLOAD_DIR="$HOME/Downloads/scripts"
TMP_FILE="$HOME/files_sorted.tmp"

mkdir -p "$DOWNLOAD_DIR"

echo "====================================="
echo "   SMART DOWNLOADER"
echo "====================================="

# ----------------------------
# 1. Скачиваем свежий files.txt
# ----------------------------
echo "Обновляем список файлов с GitHub..."
if curl -fSL "$BASE_URL/files.txt" -o "$LOCAL_FILE.tmp"; then
    mv "$LOCAL_FILE.tmp" "$LOCAL_FILE"
    sed -i 's/\r$//' "$LOCAL_FILE"  # Убираем Windows-строки
    echo "Список обновлён."
else
    echo "❌ Ошибка загрузки списка"
    exit 1
fi

# ----------------------------
# 2. Проверяем fzf
# ----------------------------
if ! command -v fzf >/dev/null 2>&1; then
    echo "❌ Установи fzf: sudo apt install fzf"
    exit 1
fi

# ----------------------------
# 3. Сортировка по категориям
# ----------------------------
echo "Сортируем по категориям из # INFO..."
> "$TMP_FILE"

declare -A CATEGORY_MAP
declare -a FILES_NO_INFO

while read -r FILEPATH; do
    [ -z "$FILEPATH" ] && continue
    FULL_URL="$BASE_URL/$FILEPATH"

    # Берём первые 20 строк, ищем # INFO:
    INFO=$(curl -fsSL "$FULL_URL" | head -n 20 | grep -m1 '^# INFO:' | sed 's/^# INFO: *//')

    CATEGORY=$(echo "$INFO" | grep -oP '\[\K[^\]]+')

    if [ -z "$CATEGORY" ]; then
        CATEGORY="OTHER"
        FILES_NO_INFO+=("$FILEPATH")
    fi

    CATEGORY_MAP["$CATEGORY"]+="$FILEPATH"$'\n'
done < "$LOCAL_FILE"

# Записываем в TMP файл по категориям (алфавитно)
for CAT in $(printf "%s\n" "${!CATEGORY_MAP[@]}" | sort); do
    echo "# ===== CATEGORY: $CAT =====" >> "$TMP_FILE"
    echo "${CATEGORY_MAP[$CAT]}" >> "$TMP_FILE"
done

# Добавляем файлы без INFO
if [ ${#FILES_NO_INFO[@]} -gt 0 ]; then
    echo "# ===== CATEGORY: OTHER =====" >> "$TMP_FILE"
    for f in "${FILES_NO_INFO[@]}"; do
        echo "$f" >> "$TMP_FILE"
    done
fi

mv "$TMP_FILE" "$LOCAL_FILE"
echo "Сортировка завершена."

# ----------------------------
# 4. Формируем меню fzf
# ----------------------------
echo
echo "===== ВЫБОР СКРИПТОВ ====="
echo "TAB — выбрать несколько, Enter — подтвердить"
echo

MENU=$(while read -r FILEPATH; do
    [ -z "$FILEPATH" ] && continue
    NAME=$(basename "$FILEPATH")
    FULL_URL="$BASE_URL/$FILEPATH"

    INFO=$(curl -fsSL "$FULL_URL" | head -n 20 | grep -m1 '^# INFO:' | sed 's/^# INFO: *//')
    CATEGORY=$(echo "$INFO" | grep -oP '\[\K[^\]]+')
    [ -z "$CATEGORY" ] && CATEGORY="OTHER"
    DESCRIPTION=$(echo "$INFO" | sed 's/\[[^]]*\] *//')

    printf "%-10s | %-25s | %s | %s\n" "$CATEGORY" "$NAME" "$DESCRIPTION" "$FILEPATH"
done < "$LOCAL_FILE")

# Выбор через fzf
SELECTED=$(echo "$MENU" | fzf -m --delimiter="|" --with-nth=1,2,3)
if [ -z "$SELECTED" ]; then
    echo "Ничего не выбрано. Выход."
    exit 0
fi

# ----------------------------
# 5. Скачивание выбранных скриптов
# ----------------------------
echo
echo "===== ЗАГРУЗКА ====="
while read -r LINE; do
    FILEPATH=$(echo "$LINE" | awk -F'|' '{print $4}' | xargs)
    NAME=$(basename "$FILEPATH")
    URL="$BASE_URL/$FILEPATH"

    echo "→ $NAME"
    if curl -fL "$URL" -o "$DOWNLOAD_DIR/$NAME"; then
        echo "   ✓ скачано"
    else
        echo "   ✗ ошибка: $URL"
    fi
done <<< "$SELECTED"

echo
echo "===== ГОТОВО ====="
echo "Файлы сохранены в: $DOWNLOAD_DIR"
