#!/bin/bash
# INFO: [СИСТЕМА] очищення_сміттєвих_.desktop

SRC="$HOME/.local/share/applications"
LOG="$HOME/cleanup_desktop.log"

echo "=== ОЧИСТКА МУСОРНЫХ .desktop ===" > "$LOG"
echo "" >> "$LOG"

for f in "$SRC"/*.desktop; do
    echo ">>> Проверка: $f" | tee -a "$LOG"

    # 1. Проверяем Exec
    EXEC=$(grep "^Exec=" "$f" | head -n1 | cut -d= -f2-)

    if [ -z "$EXEC" ]; then
        echo " - Нет Exec → удалён" | tee -a "$LOG"
        rm "$f"
        continue
    fi

    # 2. Если Exec указывает на файл, которого нет
    CMD=$(echo "$EXEC" | awk '{print $1}')
    CMD=${CMD//\"/}

    if [[ "$CMD" == /* ]] && [ ! -e "$CMD" ]; then
        echo " - Exec указывает на несуществующий файл ($CMD) → удалён" | tee -a "$LOG"
        rm "$f"
        continue
    fi

    # 3. Удаляем ярлыки userapp-* (браузерные)
    if [[ "$(basename "$f")" == userapp-* ]]; then
        echo " - Временный ярлык браузера → удалён" | tee -a "$LOG"
        rm "$f"
        continue
    fi

    # 4. Удаляем ярлыки GkPackage
    if grep -q "GkPackage" "$f"; then
        echo " - Остатки GkPackage → удалён" | tee -a "$LOG"
        rm "$f"
        continue
    fi

    # 5. Удаляем AppImage-ярлыки без AppImage
    if grep -q "\.AppImage" "$f"; then
        APP=$(grep "\.AppImage" "$f" | head -n1 | grep -o "/.*\.AppImage")
        if [ ! -e "$APP" ]; then
            echo " - AppImage отсутствует ($APP) → ярлык удалён" | tee -a "$LOG"
            rm "$f"
            continue
        fi
    fi

    echo " - OK" | tee -a "$LOG"
    echo "" >> "$LOG"
done

echo "=== ГОТОВО ===" | tee -a "$LOG"
echo "Отчёт: $LOG"
