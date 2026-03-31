#!/bin/bash
# INFO: [WINE] інструмент для роботи з Wine-префіксами


# Поддерживает: winecfg, regedit, создание ярлыков

# Пути
PREFIX_DIR="/home/minok/prefixes"
DESKTOP_DIR="$HOME/.local/share/applications"
BIN_DIR="$HOME/bin"

mkdir -p "$BIN_DIR" "$DESKTOP_DIR"

echo "=== Работа с Wine-префиксами ==="

# 1️⃣ Проверяем наличие папки с префиксами
if [ ! -d "$PREFIX_DIR" ]; then
    echo "❌ Папка с префиксами не найдена: $PREFIX_DIR"
    exit 1
fi

# 2️⃣ Выбор префикса
echo
echo "Выберите Wine-префикс:"
select PREFIX in "$PREFIX_DIR"/*; do
    if [ -n "$PREFIX" ]; then
        echo "✅ Выбран префикс: $PREFIX"
        break
    else
        echo "Неверный выбор. Попробуйте снова."
    fi
done

# 3️⃣ Выбор действия
echo
echo "Что хотите сделать с этим префиксом?"
select ACTION in "Открыть winecfg" "Открыть regedit" "Создать ярлык программы" "Выход"; do
    case $ACTION in
        "Открыть winecfg")
            echo "Запуск winecfg для $PREFIX..."
            WINEPREFIX="$PREFIX" winecfg
            exit 0
            ;;
        "Открыть regedit")
            echo "Запуск regedit для $PREFIX..."
            WINEPREFIX="$PREFIX" wine regedit
            exit 0
            ;;
        "Создать ярлык программы")
            echo "→ Переходим к созданию ярлыка..."
            break
            ;;
        "Выход")
            echo "Выход из скрипта."
            exit 0
            ;;
        *)
            echo "Пожалуйста, выберите действие из списка."
            ;;
    esac
done

# 4️⃣ Поиск exe-файлов
echo
echo "Сканируем .exe внутри \"$PREFIX/drive_c\" ..."
EXE_FILES=($(find "$PREFIX/drive_c" -maxdepth 6 -type f -iname "*.exe" \
    | grep -viE "unins|setup|update|autorun|install"))
EXE_FILES+=("Указать путь вручную")

echo
echo "Выберите исполняемый файл для ярлыка:"
select EXE in "${EXE_FILES[@]}"; do
    if [ -n "$EXE" ]; then
        if [ "$EXE" == "Указать путь вручную" ]; then
            read -p "Введите полный путь к .exe: " EXE
        fi
        echo "✅ Выбран .exe: $EXE"
        break
    else
        echo "Неверный выбор. Попробуйте снова."
    fi
done

# 5️⃣ Имя ярлыка и иконка
echo
read -p "Введите имя ярлыка (например, Total Commander): " NAME
read -p "Если есть иконка, введите путь к ней (или Enter, чтобы пропустить): " ICON

# 6️⃣ Создаём исполняемый скрипт
SCRIPT_PATH="$BIN_DIR/${NAME// /_}.sh"
cat > "$SCRIPT_PATH" <<EOL
#!/bin/bash
env WINEPREFIX="$PREFIX" wine start /unix "$EXE"
EOL
chmod +x "$SCRIPT_PATH"
echo "✅ Создан исполняемый файл: $SCRIPT_PATH"

# 7️⃣ Создаём .desktop ярлык
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
echo "✅ Ярлык создан: $DESKTOP_FILE"

# 8️⃣ Проверка битых ярлыков (необязательно)
echo
echo "=== Проверка ярлыков на битые пути ==="
for file in "$DESKTOP_DIR"/*.desktop; do
    EXEC_LINE=$(grep '^Exec=' "$file")
    if [[ $EXEC_LINE =~ WINEPREFIX=([^[:space:]]+) ]]; then
        PREFIX_CHECK="${BASH_REMATCH[1]}"
        if [ ! -d "$PREFIX_CHECK" ]; then
            echo "⚠️  Битый ярлык: $file (префикс $PREFIX_CHECK не найден)"
        fi
    fi
done

echo
echo "🎉 Всё готово!"
