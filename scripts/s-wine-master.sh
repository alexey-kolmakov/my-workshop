#!/bin/bash
# === Wine Master: универсальный инструмент для управления Wine-префиксами ===

PREFIX_DIR="/mnt/EXT_WINE/wine"
DESKTOP_DIR="$HOME/.local/share/applications"
BIN_DIR="$HOME/bin"

mkdir -p "$BIN_DIR" "$DESKTOP_DIR"

echo "=== Wine Master — управление Wine-префиксами ==="

if [ ! -d "$PREFIX_DIR" ]; then
    zenity --error --text="Папка с префиксами не найдена: $PREFIX_DIR"
    exit 1
fi

# Выбор префикса
PREFIX=$(zenity --file-selection --directory --title="Выберите Wine-префикс" --filename="$PREFIX_DIR/")
[ -z "$PREFIX" ] && exit

# Меню действий
ACTION=$(zenity --list --title="Выберите действие" \
    --column="Действие" \
    "Открыть winecfg" \
    "Открыть regedit" \
    "Создать ярлык программы" \
    "Выход")

[ -z "$ACTION" ] && exit

case "$ACTION" in
    "Открыть winecfg")
        WINEPREFIX="$PREFIX" winecfg
        exit 0
        ;;
    "Открыть regedit")
        WINEPREFIX="$PREFIX" wine regedit
        exit 0
        ;;
    "Создать ярлык программы")
        EXE=$(zenity --file-selection --title="Выберите .exe-файл для ярлыка" --filename="$PREFIX/drive_c/")
        [ -z "$EXE" ] && exit

        NAME=$(zenity --entry --title="Имя ярлыка" --text="Введите имя программы (например, Total Commander):")
        [ -z "$NAME" ] && exit

        ICON=$(zenity --file-selection --title="Выберите иконку (можно пропустить)" --file-filter="*.png *.ico" 2>/dev/null)

        SCRIPT_PATH="$BIN_DIR/${NAME// /_}.sh"
        cat > "$SCRIPT_PATH" <<EOL
#!/bin/bash
env WINEPREFIX="$PREFIX" wine start /unix "$EXE"
EOL
        chmod +x "$SCRIPT_PATH"

        DESKTOP_FILE="$DESKTOP_DIR/${NAME// /_}.desktop"
        cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=$NAME
Exec=$SCRIPT_PATH
Type=Application
Icon=$ICON
Categories=Utility;
Terminal=false
EOL
        chmod +x "$DESKTOP_FILE"

        zenity --info --text="✅ Ярлык создан:\n$DESKTOP_FILE"
        ;;
    "Выход")
        exit 0
        ;;
esac
