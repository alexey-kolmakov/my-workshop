#!/bin/bash
# INFO:[GitHub] с поиском скачивает скрипт из репозитория GitHub

# --- НАСТРОЙКИ ---
USER="alexey-kolmakov"
REPO="my-workshop"
BRANCH="main"
BASE_RAW="https://raw.githubusercontent.com/$USER/$REPO/$BRANCH"

# 1. Синхронизация списка с GitHub
(
echo "10" ; sleep 1.5
echo "# Подключаюсь к серверу..." ; sleep 1.5
curl -s "$BASE_RAW/files.txt" -o /tmp/gh_files.txt
echo "60" ; echo "# Читаю список файлов..." ; sleep 1.3
echo "100" ; echo "# Готово!" ; sleep 1.0
) | zenity --progress --title="Синхронизация" --text="Подготовка..." --auto-close --width=400

# 2. ОКНО ПОИСКА
SEARCH_QUERY=$(zenity --entry --title="Поиск в Мастерской" --text="Введите название или категорию (например: WINE):\n(Оставьте пустым, чтобы показать все)" --width=400)

# Если нажали "Отмена" в поиске — выходим
if [ $? -ne 0 ]; then rm -f /tmp/gh_files.txt; exit; fi

# 3. Сбор и ФИЛЬТРАЦИЯ данных
RAW_DATA=$(mktemp)

while IFS= read -r filepath || [ -n "$filepath" ]; do
    [ -z "$filepath" ] && continue
    filepath=$(echo "$filepath" | tr -d '\r')
    filename=$(basename "$filepath")
    
    # Получаем описание
    desc=$(curl -s "$BASE_RAW/$filepath" | grep -m 1 -i "^# \?INFO" | sed -E 's/^#[[:space:]]?INFO:?[[:space:]]?//I')
    [ -z "$desc" ] && desc="[БЕЗ КАТЕГОРИИ] $filename"
    
    # ПРОВЕРКА ПОИСКА: если слово из поиска есть в имени или описании — добавляем
    if echo "$filename $desc" | grep -iq "$SEARCH_QUERY"; then
        echo "$desc|$filepath|$filename" >> "$RAW_DATA"
    fi
done < /tmp/gh_files.txt

# 4. Сортировка и вывод в таблицу
TABLE_DATA=()
while IFS='|' read -r s_desc s_path s_name; do
    TABLE_DATA+=("$s_name" "$s_desc")
done < <(sort "$RAW_DATA")

# Если после поиска ничего не найдено
if [ ${#TABLE_DATA[@]} -eq 0 ]; then
    zenity --error --text="По запросу '$SEARCH_QUERY' ничего не найдено!"
    rm -f "$RAW_DATA" /tmp/gh_files.txt
    exit
fi

# 5. Графическое меню выбора
SELECTED_NAME=$(zenity --list \
    --title="Результаты поиска: $SEARCH_QUERY" \
    --column="Файл" --column="Категория и описание" \
    --width=900 --height=550 \
    "${TABLE_DATA[@]}")

if [ -z "$SELECTED_NAME" ]; then rm -f "$RAW_DATA" /tmp/gh_files.txt; exit; fi

# Путь для загрузки
SELECTED_PATH=$(grep "|$SELECTED_NAME$" "$RAW_DATA" | cut -d'|' -f2)

# 6. Куда сохраняем?
TARGET_DIR=$(zenity --file-selection --directory --title="Куда сохранить $SELECTED_NAME?")
if [ -z "$TARGET_DIR" ]; then rm -f "$RAW_DATA" /tmp/gh_files.txt; exit; fi

# 7. Загрузка
curl -s -L "$BASE_RAW/$SELECTED_PATH" -o "$TARGET_DIR/$SELECTED_NAME"
chmod +x "$TARGET_DIR/$SELECTED_NAME"

zenity --info --text="Готово! Скрипт загружен." --timeout=2
rm -f "$RAW_DATA" /tmp/gh_files.txt
