#!/bin/bash
# INFO: [СИСТЕМА] автоматично створює ярлики до будь-яких файлів (в т.ч. Thunar)


TARGET="$1"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
mkdir -p "$DESKTOP_DIR" "$ICON_DIR"

if [ -z "$TARGET" ]; then
    echo "Использование: $0 <файл|папка|URL>"
    exit 1
fi

# Определяем имя
NAME=$(basename "$TARGET")
NAME_NOEXT="${NAME%.*}"
DESKTOP_FILE="$DESKTOP_DIR/$NAME_NOEXT.desktop"

# Определяем тип
if [[ "$TARGET" =~ ^https?:// ]]; then
    TYPE="url"
elif [[ -d "$TARGET" ]]; then
    TYPE="folder"
elif [[ "$TARGET" == *.AppImage ]]; then
    TYPE="appimage"
elif [[ "$TARGET" == *.exe ]]; then
    TYPE="wine"
elif [[ -x "$TARGET" ]]; then
    TYPE="binary"
elif [[ "$TARGET" == *.sh || "$TARGET" == *.py || "$TARGET" == *.pl ]]; then
    TYPE="script"
else
    TYPE="document"
fi

ICON="$ICON_DIR/$NAME_NOEXT.png"

# Генерация ярлыка по типу
case "$TYPE" in

appimage)
    "$TARGET" --appimage-extract *.png >/dev/null 2>&1
    ICON_SRC=$(find squashfs-root -name "*.png" | head -n1)
    [ -n "$ICON_SRC" ] && cp "$ICON_SRC" "$ICON"
    rm -rf squashfs-root

    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$NAME_NOEXT
Exec=$TARGET
Icon=$ICON
Terminal=false
Categories=Utility;
Path=$(dirname "$TARGET")
EOF
;;

script)
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$NAME_NOEXT
Exec=$TARGET
Icon=utilities-terminal
Terminal=true
Categories=Utility;
EOF
;;

binary)
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$NAME_NOEXT
Exec=$TARGET
Icon=application-x-executable
Terminal=false
Categories=Utility;
EOF
;;

wine)
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$NAME_NOEXT
Exec=wine "$TARGET"
Icon=wine
Terminal=false
Categories=WindowsApps;
EOF
;;

url)
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$NAME_NOEXT
Exec=xdg-open "$TARGET"
Icon=internet-web-browser
Terminal=false
Categories=Network;
EOF
;;

folder)
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$NAME_NOEXT
Exec=thunar "$TARGET"
Icon=folder
Terminal=false
Categories=FileManager;
EOF
;;

document)
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$NAME_NOEXT
Exec=xdg-open "$TARGET"
Icon=text-x-generic
Terminal=false
Categories=Office;
EOF
;;

esac

gio set "$DESKTOP_FILE" metadata::trusted true
desktop-file-validate "$DESKTOP_FILE" 2>/dev/null

echo "Ярлык создан: $DESKTOP_FILE"
