#!/bin/bash
# INFO: [СИСТЕМА] скрипт_исправляет_ярлыки_для_.appimage

APPDIRS=(
    "$HOME/Apps"
    "$HOME/Applications"
    "$HOME/Portable"
    "$HOME/.local/bin"
)

DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
LOG="$HOME/rebuild_appimage_desktop.log"

mkdir -p "$DESKTOP_DIR" "$ICON_DIR"

echo "=== ПЕРЕСОЗДАНИЕ ЯРЛЫКОВ APPIMAGE ===" > "$LOG"
echo "" >> "$LOG"

for DIR in "${APPDIRS[@]}"; do
    [ -d "$DIR" ] || continue

    for APP in "$DIR"/*.AppImage; do
        [ -e "$APP" ] || continue

        BASENAME=$(basename "$APP" .AppImage)
        DESKTOP_FILE="$DESKTOP_DIR/$BASENAME.AppImage.desktop"
        ICON_FILE="$ICON_DIR/$BASENAME.png"

        echo ">>> Обработка: $APP" | tee -a "$LOG"

        # Извлекаем иконку
        "$APP" --appimage-extract *.png >/dev/null 2>&1
        ICON_SRC=$(find squashfs-root -name "*.png" | head -n1)

        if [ -n "$ICON_SRC" ]; then
            cp "$ICON_SRC" "$ICON_FILE"
            echo " - Иконка извлечена" | tee -a "$LOG"
        else
            echo " - Иконка не найдена, будет стандартная" | tee -a "$LOG"
        fi

        rm -rf squashfs-root

        # Создаём ярлык
        cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$BASENAME
Exec=$APP
Icon=$ICON_FILE
Terminal=false
Categories=Utility;
Path=$(dirname "$APP")
EOF

        # Делаем trusted
        gio set "$DESKTOP_FILE" metadata::trusted true

        # Проверка
        desktop-file-validate "$DESKTOP_FILE" 2> "$DESKTOP_FILE.err"

        if [ -s "$DESKTOP_FILE.err" ]; then
            echo " - Ошибки:" | tee -a "$LOG"
            sed 's/^/   /' "$DESKTOP_FILE.err" | tee -a "$LOG"
        else
            echo " - Ярлык создан успешно" | tee -a "$LOG"
        fi

        rm -f "$DESKTOP_FILE.err"
        echo "" >> "$LOG"
    done
done

echo "=== ГОТОВО ===" | tee -a "$LOG"
echo "Отчёт: $LOG"
