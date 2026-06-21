#!/bin/bash
# INFO: [СИСТЕМА] відновлює_ярлики_в_applications


SRC="$HOME/.local/share/applications"
BACKUP="$HOME/.local/share/applications_backup_smart_$(date +%Y%m%d_%H%M%S)"
LOG="$HOME/restore_desktop.log"

mkdir -p "$BACKUP"
cp "$SRC"/*.desktop "$BACKUP"/

echo "=== ВОССТАНОВЛЕНИЕ .desktop ФАЙЛОВ ===" > "$LOG"
echo "Резервная копия: $BACKUP" >> "$LOG"
echo "" >> "$LOG"

for f in "$SRC"/*.desktop; do
    echo ">>> Обработка: $f" | tee -a "$LOG"

    TMP="$f.tmp"
    cp "$f" "$TMP"

    FIXED=0

    # Удаляем BOM
    sed -i '1s/^\xEF\xBB\xBF//' "$TMP"

    # Удаляем пустые строки в начале
    sed -i '1{/^$/d}' "$TMP"

    # Удаляем вредную секцию GkPackage
    sed -i '/

\[Desktop_GkPackageRunAppImage_Entry\]

/,/^

\[/d' "$TMP"

    # Исправляем первую строку
    FIRST=$(head -n1 "$TMP")
    if [ "$FIRST" != "[Desktop Entry]" ]; then
        sed -i '1s/.*/[Desktop Entry]/' "$TMP"
    fi

    # Удаляем дублирующиеся строки
    awk '!seen[$0]++' "$TMP" > "$TMP.clean"
    mv "$TMP.clean" "$TMP"

    # Исправляем Exec с одинарными кавычками
    sed -i 's/Exec='\''\([^'\'']*\)'\''/Exec=\1/' "$TMP"

    # Исправляем Categories
    sed -i 's/Categories=.*/Categories=Utility;/' "$TMP"

    # Удаляем битые action-группы
    sed -i '/^

\[Desktop Action /,/^$/d' "$TMP"

    # Проверка
    desktop-file-validate "$TMP" 2> "$TMP.err"

    if [ -s "$TMP.err" ]; then
        echo " - Ошибки после исправления:" | tee -a "$LOG"
        sed 's/^/   /' "$TMP.err" | tee -a "$LOG"
        echo " - Файл НЕ удалось полностью восстановить" | tee -a "$LOG"
    else
        echo " - Файл исправлен успешно" | tee -a "$LOG"
        mv "$TMP" "$f"
    fi

    rm -f "$TMP" "$TMP.err"
    echo "" | tee -a "$LOG"
done

echo "=== ГОТОВО ===" | tee -a "$LOG"
echo "Отчёт: $LOG"
