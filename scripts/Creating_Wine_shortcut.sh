#!/bin/bash
# Создание Wine-ярлыка для префиксов на внешнем диске
# + запуск winecfg перед созданием ярлыка

EXT_WINE="/home/minok/prefixes"
DESKTOP_DIR="$HOME/.local/share/applications"
BIN_DIR="$HOME/bin"
USER_NAME=$(logname)

mkdir -p "$BIN_DIR" "$DESKTOP_DIR"

echo "=== Создание нового Wine-ярлыка ==="

# ----------------------
# 1️⃣ Выбор префикса
prefixes=()
while IFS= read -r dir; do
    prefixes+=("$(basename "$dir")")
done < <(find "$EXT_WINE" -mindepth 1 -maxdepth 1 -type d)

if [ ${#prefixes[@]} -eq 0 ]; then
    echo "Нет префиксов на внешнем диске ($EXT_WINE)."
    exit 1
fi

echo "Выберите префикс:"
select PREFIX_CHOICE in "${prefixes[@]}"; do
    if [ -n "$PREFIX_CHOICE" ]; then
        PREFIX="$EXT_WINE/$PREFIX_CHOICE"
        echo "Выбран префикс: $PREFIX"
        break
    else
        echo "Неверный выбор. Попробуйте ещё раз."
    fi
done

# ----------------------
# 2️⃣ Запуск winecfg перед созданием ярлыка
zenity --info --title="Wine Configuration" --text="Сейчас откроется winecfg для настройки префикса $PREFIX_CHOICE..."
WINEPREFIX="$PREFIX" winecfg

# ----------------------
# 3️⃣ Сканируем exe-файлы в префиксе
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

# ----------------------
# 4️⃣ Имя ярлыка и иконка
read -p "Введите имя ярлыка (например, Total Commander): " NAME
read -p "Если есть иконка, введите путь к ней, иначе Enter: " ICON

# ----------------------
# 5️⃣ Создание обёртки-скрипта
SCRIPT_PATH="$BIN_DIR/${NAME// /_}.sh"

cat > "$SCRIPT_PATH" <<EOL
#!/bin/bash
env WINEPREFIX="$PREFIX" wine start /unix "$EXE"
EOL
chmod +x "$SCRIPT_PATH"
echo "Создан исполняемый скрипт: $SCRIPT_PATH"

# ----------------------
# 6️⃣ Создание .desktop ярлыка
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

# ----------------------
# 7️⃣ Проверка меню на битые Wine-ярлыки
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
