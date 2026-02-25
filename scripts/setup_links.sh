#!/bin/bash

# ОПРЕДЕЛЯЕМ ПУТИ
HANDLER_DIR="$HOME/.local/share/applications"
BIN_DIR="$HOME/bin"
SCRIPT_PATH="$BIN_DIR/open-folder-handler.sh"
DESKTOP_FILE="$HANDLER_DIR/folder-handler.desktop"

echo "--- Настройка протокола folder:// для Thunar ---"

# 1. Создаем папку для скрипта, если её нет
mkdir -p "$BIN_DIR"

# 2. Создаем сам скрипт-обработчик
cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/bash
URL="$1"
RAW_PATH="${URL#folder://}"
TARGET_PATH=$(printf '%b' "${RAW_PATH//%/\\x}")

if [ ! -e "$TARGET_PATH" ]; then
    notify-send "Ошибка" "Путь не найден: $TARGET_PATH"
    exit 1
fi

if [ -f "$TARGET_PATH" ]; then
    ABS_PATH=$(realpath "$TARGET_PATH")
    if command -v thunar >/dev/null; then
        dbus-send --session --dest=org.xfce.Thunar --print-reply /org/xfce/FileManager \
        org.xfce.FileManager.DisplayFolderAndSelect \
        string:"$(dirname "$ABS_PATH")" string:"$(basename "$ABS_PATH")" string:"" string:"" &
    elif command -v nautilus >/dev/null; then
        nautilus --select "$ABS_PATH" &
    else
        xdg-open "$(dirname "$ABS_PATH")"
    fi
else
    xdg-open "$TARGET_PATH"
fi
EOF

chmod +x "$SCRIPT_PATH"
echo "[+] Скрипт-обработчик установлен в $SCRIPT_PATH"

# 3. Создаем .desktop файл
mkdir -p "$HANDLER_DIR"
cat << EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=Folder Protocol Handler
Exec=$SCRIPT_PATH %u
Type=Application
Terminal=false
MimeType=x-scheme-handler/folder;
EOF

echo "[+] Файл десктопа создан в $DESKTOP_FILE"

# 4. Регистрируем протокол в системе
xdg-mime default folder-handler.desktop x-scheme-handler/folder
update-desktop-database "$HANDLER_DIR"

echo "--- Готово! Теперь ссылки folder:// будут работать. ---"
notify-send "Успех" "Протокол folder:// успешно зарегистрирован!"
