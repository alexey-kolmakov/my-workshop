#!/bin/bash
# INFO:[АРХІВ] завантажує скрипти по tab
set -e

# ----------------------------
# Настройки
# ----------------------------
BASE_URL="https://raw.githubusercontent.com/alexey-kolmakov/my-workshop/main"
DOWNLOAD_DIR="$HOME/Downloads/scripts"

# Твои новые пути к кэшу
WORKSHOP_DIR="/home/minok/my-workshop"
LOCAL_LIST="$WORKSHOP_DIR/files.txt"
CACHE_FILE="$WORKSHOP_DIR/files_cache.txt"

# Создаем папки, если их еще нет
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$WORKSHOP_DIR"

mkdir -p "$DOWNLOAD_DIR"

# Проверяем, передан ли флаг принудительного обновления (--force или -f)
FORCE_UPDATE=false
if [[ "$1" == "--force" || "$1" == "-f" ]]; then
    FORCE_UPDATE=true
fi

echo "====================================="
echo "   SMART DOWNLOADER (С КЭШИРОВАНИЕМ)"
echo "====================================="
# Добавляем строку-напоминалку ярким цветом или просто текстом:
echo "💡 Подсказка: для обновления кэша запусти с флагом -f или --force"
echo "------------------------------------="

# ----------------------------
# Проверка fzf
# ----------------------------
if ! command -v fzf >/dev/null 2>&1; then
    echo "❌ Установи fzf: sudo apt install fzf"
    exit 1
fi

# ----------------------------
# Шаг 1 & 2. Загрузка списка и создание кэша меню
# ----------------------------
# Кэш создается, только если его нет, ИЛИ если пользователь вызвал обновление
if [ ! -f "$CACHE_FILE" ] || [ "$FORCE_UPDATE" = true ]; then
    echo "Обновляем список файлов с GitHub и строим кэш меню..."

    if ! curl -fSL "$BASE_URL/files.txt" -o "$LOCAL_LIST.tmp"; then
        echo "❌ Ошибка загрузки списка files.txt с GitHub"
        exit 1
    fi
    mv "$LOCAL_LIST.tmp" "$LOCAL_LIST"
    sed -i 's/\r$//' "$LOCAL_LIST"

    echo "Парсим категории и описания (это займет немного времени)..."
    > "$CACHE_FILE"

    declare -A CATEGORY_MAP
    declare -a FILES_NO_INFO

    # Собираем информацию о файлах по сети
    while read -r FILEPATH; do
        [[ -z "$FILEPATH" || "$FILEPATH" =~ ^# ]] && continue

        FULL_URL="$BASE_URL/$FILEPATH"
        INFO=$(curl -fsSL "$FULL_URL" | head -n 20 | grep -m1 '^# INFO:' | sed 's/^# INFO: *//' || true)

        NAME=$(basename "$FILEPATH")
        CATEGORY=$(echo "$INFO" | grep -oP '\[\K[^\]]+' || true)
        [ -z "$CATEGORY" ] && CATEGORY="OTHER"
        DESCRIPTION=$(echo "$INFO" | sed 's/\[[^]]*\] *//' || true)

        # Формируем готовую строчку для меню fzf
        MENU_LINE=$(printf "%-12s | %-25s | %-45s | %s\n" "$CATEGORY" "$NAME" "$DESCRIPTION" "$FILEPATH")

        if [ "$CATEGORY" = "OTHER" ]; then
            FILES_NO_INFO+=("$MENU_LINE")
        else
            CATEGORY_MAP["$CATEGORY"]+="$MENU_LINE"$'\n'
        fi
    done < "$LOCAL_LIST"

    # Записываем упорядоченно в файл кэша
    for CAT in $(printf "%s\n" "${!CATEGORY_MAP[@]}" | sort); do
        echo "# ===== CATEGORY: $CAT =====" >> "$CACHE_FILE"
        echo -n "${CATEGORY_MAP[$CAT]}" >> "$CACHE_FILE"
    done

    if [ ${#FILES_NO_INFO[@]} -gt 0 ]; then
        echo "# ===== CATEGORY: OTHER =====" >> "$CACHE_FILE"
        for line in "${FILES_NO_INFO[@]}"; do
            echo "$line" >> "$CACHE_FILE"
        done
    fi
    echo "✨ Кэш успешно обновлен и сохранен!"
else
    echo "🚀 Используем локальный кэш (для принудительного обновления запусти: $0 --force)"
fi

# ----------------------------
# 3. Выбор через fzf (теперь мгновенный!)
# ----------------------------
echo
echo "===== ВЫБОР СКРИПТОВ ====="
echo "TAB — выбрать несколько, Enter — подтвердить"
echo

# Читаем меню прямо из кэша, отсекая заголовки-комментарии
MENU=$(grep -v '^#' "$CACHE_FILE" || true)

if [ -z "$MENU" ]; then
    echo "Ошибка: Список меню пуст. Попробуй запустить с флагом --force"
    exit 1
fi

SELECTED=$(echo "$MENU" | fzf -m --delimiter="|" --with-nth=1,2,3)
if [ -z "$SELECTED" ]; then
    echo "Ничего не выбрано. Выход."
    exit 0
fi

# ----------------------------
# 4. Скачивание выбранных скриптов
# ----------------------------
echo
echo "===== ЗАГРУЗКА ====="
while read -r LINE; do
    [ -z "$LINE" ] && continue

    FILEPATH=$(echo "$LINE" | awk -F'|' '{print $4}' | xargs)
    NAME=$(basename "$FILEPATH")
    URL="$BASE_URL/$FILEPATH"

    echo "→ $NAME"
    if curl -fL "$URL" -o "$DOWNLOAD_DIR/$NAME"; then
        echo "   ✓ скачано"
    else
        echo "   ✗ ошибка скачивания: $URL"
    fi
done <<< "$SELECTED"

echo
echo "===== ГОТОВО ====="
echo "Файлы сохранены в: $DOWNLOAD_DIR"
