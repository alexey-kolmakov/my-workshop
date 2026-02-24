#!/bin/bash
#Создание wine-ярлыка

PREFIX_DIR=~/prefixes
DESKTOP_DIR=~/.local/share/applications
BIN_DIR=~/bin

mkdir -p "$BIN_DIR" "$DESKTOP_DIR"

echo "=== Создание нового Wine-ярлыка ==="

# 1️⃣ Выбор префикса
if [ ! -d "$PREFIX_DIR" ]; then
    echo "Папка с префиксами не найдена: $PREFIX_DIR"
    exit 1
fi

echo "Выберите префикс:"
select PREFIX in "$PREFIX_DIR"/*; do
    if [ -n "$PREFIX" ]; then
        echo "Выбран префикс: $PREFIX"
        break
    else
        echo "Неверный выбор. Попробуйте ещё раз."
    fi
done

# 2️⃣ Сканируем exe-файлы
echo "Сканируем .exe внутри \"$PREFIX/drive_c\" ..."
EXE_FILES=($(find "$PREFIX/drive_c" -maxdepth 6 -iname "*.exe" \
    | grep -viE "unins|setup|update|autorun|install"))

# Добавляем пункт ручного ввода
EXE_FILES+=("Указать путь вручную")

echo "Выберите программу для ярлыка:"
select EXE in "${EXE_FILES[@]}"; do
    if [ -n "$EXE" ]; then
        if [ "$EXE" == "Указать путь вручную" ]; then
            read -p "Введите полный путь к .exe: " EXE
        fi
        echo "Выбран .exe: $EXE"
        break
    else
        echo "Неверный выбор. Попробуйте ещё раз."
    fi
done

# 3️⃣ Имя ярлыка и иконка
read -p "Введите имя ярлыка (например, Total Commander): " NAME
read -p "Если есть иконка, введите путь к ней, иначе Enter: " ICON

# 4️⃣ Создание обёртки-скрипта
SCRIPT_PATH="$BIN_DIR/${NAME// /_}.sh"

cat > "$SCRIPT_PATH" <<EOL
#!/bin/bash
env WINEPREFIX="$PREFIX" wine start /unix "$EXE"
EOL
chmod +x "$SCRIPT_PATH"
echo "Создан исполняемый скрипт: $SCRIPT_PATH"

# 5️⃣ Создание .desktop ярлыка
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
echo "Ярлык создан: $DESKTOP_FILE"

# 6️⃣ Проверка меню на битые Wine-ярлыки
echo "=== Проверка меню на битые Wine-ярлыки ==="
for file in "$DESKTOP_DIR"/*.desktop; do
    EXEC_LINE=$(grep '^Exec=' "$file")
    if [[ $EXEC_LINE =~ WINEPREFIX=([^[:space:]]+) ]]; then
        PREFIX_CHECK="${BASH_REMATCH[1]}"
        if [ ! -d "$PREFIX_CHECK" ]; then
            echo "⚠ Битый ярлык найден: $file (префикс $PREFIX_CHECK не существует)"
            read -p "Удалить этот ярлык? [y/N]: " RESP
            if [[ $RESP == [yY] ]]; then
                rm -f "$file"
                echo "Удалено: $file"
            fi
        else
            EXE_PATH=$(echo "$EXEC_LINE" | sed 's/.*"\(.*\)".*/\1/')
            if [ ! -f "$EXE_PATH" ]; then
                echo "⚠ Битый ярлык найден: $file (exe $EXE_PATH не найден)"
                read -p "Удалить этот ярлык? [y/N]: " RESP
                if [[ $RESP == [yY] ]]; then
                    rm -f "$file"
                    echo "Удалено: $file"
                fi
            fi
        fi
    fi
done

echo "✅ Всё готово!"
