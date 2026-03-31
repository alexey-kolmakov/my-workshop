#!/bin/bash
# INFO: [СИСТЕМА] встановлення протоколу folder://..

# --- НАСТРОЙКИ ПУТЕЙ ---
# Куда положим исполняемый скрипт
BIN_DIR="$HOME/bin"
# Путь к самому скрипту-обработчику
SCRIPT_PATH="$BIN_DIR/open-folder-handler.sh"
# Путь к файлу регистрации в системе (Desktop Entry)
DESKTOP_FILE="$HOME/.local/share/applications/folder-handler.desktop"

echo "Начинаю установку протокола folder://..."

# Создаем папку bin, если её еще нет (-p не выдаст ошибку, если папка существует)
mkdir -p "$BIN_DIR"

# --- СОЗДАНИЕ СКРИПТА-ОБРАБОТЧИКА ---
cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/bash
# Переменная $1 содержит всю ссылку, например folder:///home/user/file.txt
URL="$1"

# Отрезаем префикс 'folder://'
RAW_PATH="${URL#folder://}"

# Декодируем URL-символы (превращаем %20 обратно в пробелы)
TARGET_PATH=$(printf '%b' "${RAW_PATH//%/\\x}")

# Проверяем: существует ли такой файл или папка вообще?
if [ ! -e "$TARGET_PATH" ]; then
    notify-send "Ошибка" "Путь не найден: $TARGET_PATH"
    exit 1
fi

# Если это файл (-f), будем открывать его папку и выделять сам файл
if [ -f "$TARGET_PATH" ]; then
    ABS_PATH=$(realpath "$TARGET_PATH") # Получаем полный путь
    
    # Пытаемся отправить команду через D-Bus специально для Thunar
    if command -v thunar >/dev/null; then
        dbus-send --session --dest=org.xfce.Thunar --print-reply /org/xfce/FileManager \
        org.xfce.FileManager.DisplayFolderAndSelect \
        string:"$(dirname "$ABS_PATH")" string:"$(basename "$ABS_PATH")" string:"" string:"" &
    else
        # Если Thunar не найден, открываем просто папку через стандартный xdg-open
        xdg-open "$(dirname "$ABS_PATH")"
    fi
else
    # Если это просто ПАПКА, открываем её стандартным способом
    xdg-open "$TARGET_PATH"
fi
EOF

# Даем права на запуск скрипту
chmod +x "$SCRIPT_PATH"

# --- РЕГИСТРАЦИЯ В СИСТЕМЕ ---
# Создаем файл, который скажет системе: "Ссылки folder:// — это к нам!"
cat << EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=Folder Protocol Handler
Exec=$SCRIPT_PATH %u
Type=Application
Terminal=false
MimeType=x-scheme-handler/folder;
EOF

# Обновляем базу данных типов файлов, чтобы система увидела изменения
xdg-mime default folder-handler.desktop x-scheme-handler/folder
update-desktop-database "$HOME/.local/share/applications"

echo "Установка завершена! Можно пользоваться."
