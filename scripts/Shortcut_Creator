#!/bin/bash
# INFO: [СИСТЕМА] створює ярлик для сайту або програми (вибір)

# Определяем папку рабочего стола
get_desktop_dir() {
    local dir
    dir="$(xdg-user-dir DESKTOP)"
    if [ -z "$dir" ] || [ ! -d "$dir" ]; then
        dir="$HOME/Desktop"
        mkdir -p "$dir"
    fi
    echo "$dir"
}

# -------------------------------
# МЕНЮ ВЫБОРА РЕЖИМА
# -------------------------------
echo "🔹 Что вы хотите создать?"
echo "1) Ярлык для сайта"
echo "2) Ярлык для приложения"
read -p "Введите номер: " mode

# -------------------------------
# РЕЖИМ 1 — ЯРЛЫК ДЛЯ САЙТА
# -------------------------------
if [ "$mode" = "1" ]; then

    TARGET_DIR="$(get_desktop_dir)"

    echo "🔹 Введите название ярлыка:"
    read name

    echo "🔹 Введите ссылку на сайт:"
    read url

    # -----------------------------------------
# ПОИСК БРАУЗЕРОВ + КРАСИВОЕ МЕНЮ ZENITY
# -----------------------------------------

# Список возможных браузеров (включая редкие)
BROWSER_CANDIDATES=(
    firefox firefox-esr
    chromium chromium-browser
    google-chrome google-chrome-stable
    brave brave-browser
    vivaldi vivaldi-stable
    opera opera-stable opera-developer
    falkon midori slimjet tor-browser
)

FOUND_BROWSERS=()

# Ищем браузеры в PATH
for b in "${BROWSER_CANDIDATES[@]}"; do
    if command -v "$b" >/dev/null 2>&1; then
        FOUND_BROWSERS+=("$b")
    fi
done

# Ищем браузеры по .desktop файлам (категория WebBrowser)
DESKTOP_BROWSERS=$(grep -ril "Categories=.*WebBrowser" \
    /usr/share/applications ~/.local/share/applications 2>/dev/null)

# Добавляем Exec из .desktop
while IFS= read -r file; do
    exec_line=$(grep -m1 "^Exec=" "$file" | sed 's/^Exec=//' | awk '{print $1}')
    [ -n "$exec_line" ] && FOUND_BROWSERS+=("$exec_line")
done <<< "$DESKTOP_BROWSERS"

# Убираем дубликаты
FOUND_BROWSERS=($(printf "%s\n" "${FOUND_BROWSERS[@]}" | sort -u))

# Если браузеров нет — ошибка
if [ ${#FOUND_BROWSERS[@]} -eq 0 ]; then
    zenity --error --text="Не найдено ни одного браузера!"
    exit 1
fi

# Формируем список для zenity
ZENITY_LIST=()
for b in "${FOUND_BROWSERS[@]}"; do
    ZENITY_LIST+=("$b" "")
done

# Показываем красивое меню
browser=$(zenity --list \
    --modal \
    --title="Выберите браузер" \
    --column="Браузер" \
    --column="" \
    "${ZENITY_LIST[@]}")

# Если пользователь нажал отмену
if [ -z "$browser" ]; then
    zenity --error --text="Браузер не выбран!"
    exit 1
fi


    # Выбор иконки
    echo "🔹 Выберите иконку (PNG/SVG/JPG). Если отменить — будет стандартная."
    icon_path=$(zenity --file-selection \
        --title="Выберите иконку" \
        --file-filter="Иконки | *.png *.svg *.jpg *.jpeg" \
        --file-filter="Все файлы | *")

    if [ -z "$icon_path" ]; then
        icon_path="web-browser"
    fi

    echo "🔹 Куда сохранить ярлык? (Enter = $TARGET_DIR)"
    read custom_dir
    if [ -n "$custom_dir" ]; then
        TARGET_DIR="$custom_dir"
        mkdir -p "$TARGET_DIR"
    fi

    filename="$(echo "$name" | tr ' ' '_' ).desktop"
    if [ "$filename" = ".desktop" ]; then
        filename="shortcut_$(date +%s).desktop"
    fi

    cat <<EOF > "$TARGET_DIR/$filename"
[Desktop Entry]
Name=$name
Exec=$browser $url
Icon=$icon_path
Type=Application
Terminal=false
#Terminal=true
#Categories=Office;
#Categories=Education;
#Categories=TextEditor;Utility;
#Categories=Application;
EOF

    chmod +x "$TARGET_DIR/$filename"
    gio set "$TARGET_DIR/$filename" metadata::trusted true 2>/dev/null

    echo "✅ Ярлык создан: $TARGET_DIR/$filename"
    exit 0
fi

# -------------------------------
# РЕЖИМ 2 — ЯРЛЫК ДЛЯ ПРИЛОЖЕНИЯ
# -------------------------------
if [ "$mode" = "2" ]; then

    TARGET_DIR="$(get_desktop_dir)"

    echo "🔹 Введите название ярлыка:"
    read name

    echo "🔹 Выберите исполняемый файл (приложение, скрипт, AppImage):"
    exec_path=$(zenity --file-selection \
        --title="Выберите приложение" \
        --file-filter="Исполняемые | *.sh *.py *.AppImage" \
        --file-filter="Все файлы | *")

    if [ -z "$exec_path" ]; then
        echo "❌ Исполняемый файл не выбран."
        exit 1
    fi

    echo "🔹 Выберите иконку (PNG/SVG/JPG). Если отменить — будет стандартная."
    icon_path=$(zenity --file-selection \
        --title="Выберите иконку" \
        --file-filter="Иконки | *.png *.svg *.jpg *.jpeg" \
        --file-filter="Все файлы | *")

    if [ -z "$icon_path" ]; then
        icon_path="application-x-executable"
    fi

    echo "🔹 Куда сохранить ярлык? (Enter = $TARGET_DIR)"
    read custom_dir
    if [ -n "$custom_dir" ]; then
        TARGET_DIR="$custom_dir"
        mkdir -p "$custom_dir"
    fi

    filename="$(echo "$name" | tr ' ' '_' ).desktop"
    if [ "$filename" = ".desktop" ]; then
        filename="app_$(date +%s).desktop"
    fi

    cat <<EOF > "$TARGET_DIR/$filename"
[Desktop Entry]
Name=$name
Exec="$exec_path"
Icon=$icon_path
Type=Application
Terminal=false
#Terminal=true
#Categories=Office;
#Categories=Education;
#Categories=TextEditor;Utility;
#Categories=Application;
EOF

    chmod +x "$TARGET_DIR/$filename"
    gio set "$TARGET_DIR/$filename" metadata::trusted true 2>/dev/null

    echo "✅ Ярлык создан: $TARGET_DIR/$filename"
    exit 0
fi

echo "❌ Неизвестный режим."
