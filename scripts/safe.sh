#!/bin/bash
# INFO: [LOCAL] Графічний помічник для шифрування та розшифровки (GPG + Zenity)

# 1. Головне меню: вибір дії
ACTION=$(zenity --list \
    --title="Безпека GPG" \
    --text="Виберіть дію:" \
    --radiolist \
    --column="" --column="Дія" \
    TRUE "Зашифрувати (Файл або Папку)" \
    FALSE "Розшифрувати (gpg)" \
    --width=400 --height=220)

# Якщо користувач натиснув "Скасувати", виходимо
if [ $? -ne 0 ] || [ -z "$ACTION" ]; then
    exit 0
fi

# --- СЦЕНАРІЙ 1: ШИФРУВАННЯ---
if [[ "$ACTION" == "Зашифрувати"* ]]; then

    # Вибір типу об'єкта (Файл або Папка)
    TYPE=$(zenity --list \
        --title="Що шифруємо?" \
        --text="Виберіть тип об'єкта:" \
        --radiolist \
        --column="" --column="Тип" \
        TRUE "Папку" \
        FALSE "Окремий файл" \
        --width=350 --height=200)

    if [ $? -ne 0 ]; then exit 0; fi

    if [[ "$TYPE" == "Папку" ]]; then
        TARGET=$(zenity --file-selection --directory --title="Виберіть папку для шифрування")
    else
        TARGET=$(zenity --file-selection --title="Виберіть файл для шифрування")
    fi

    if [ -z "$TARGET" ]; then exit 0; fi

    # Запит та підтвердження пароля
    PASS1=$(zenity --password --title="Шифрування: $TARGET" --text="Введіть секретний пароль:")
    if [ $? -ne 0 ] || [ -z "$PASS1" ]; then exit 0; fi

    PASS2=$(zenity --password --title="Підтвердження" --text="Повторіть пароль:")
    if [ "$PASS1" != "$PASS2" ]; then
        zenity --error --text="Паролі не збігаються!"
        exit 1
    fi

    # Процес шифрування
    if [ -d "$TARGET" ]; then
        ARCHIVE="${TARGET%/}.tar.gz"

        (
            echo "10"; echo "# Пакуємо папку в архів..."
            tar -czf "$ARCHIVE" -C "$(dirname "$TARGET")" "$(basename "$TARGET")"

            echo "60"; echo "# Шифруємо архів..."
            echo "$PASS1" | gpg --batch --yes --passphrase-fd 0 -c --cipher-algo AES256 "$ARCHIVE"
            rm "$ARCHIVE"
            echo "100"; echo "# Готово!"
        ) | zenity --progress --title="Обробка" --text="Підготовка..." --percentage=0 --pulsate --auto-close

        zenity --info --text="Папка зашифрована:\n<b>${ARCHIVE}.gpg</b>"
    else
        (
            echo "50"; echo "# Шифруємо файл..."
            echo "$PASS1" | gpg --batch --yes --passphrase-fd 0 -c --cipher-algo AES256 "$TARGET"
            echo "100"; echo "# Готово!"
        ) | zenity --progress --title="Обробка" --text="Шифрування..." --percentage=0 --pulsate --auto-close

        zenity --info --text="Файл зашифрований:\n<b>${TARGET}.gpg</b>"
    fi

# --- СЦЕНАРІЙ 2: РОЗШИФРУВАННЯ ---
elif [[ "$ACTION" == "Розшифрувати"* ]]; then

    TARGET=$(zenity --file-selection --title="Виберіть зашифрований файл (.gpg)" --file-filter="GPG файлы | *.gpg")
    if [ -z "$TARGET" ]; then exit 0; fi

    PASS=$(zenity --password --title="Розшифровка" --text="Введіть пароль від файлу:")
    if [ $? -ne 0 ] || [ -z "$PASS" ]; then exit 0; fi

    if [[ "$TARGET" == *.tar.gz.gpg ]]; then
        INTERMEDIATE="${TARGET%.gpg}"

        (
            echo "30"; echo "# Розшифровуємо архів..."
            if ! echo "$PASS" | gpg --batch --yes --passphrase-fd 0 -d "$TARGET" > "$INTERMEDIATE" 2>/dev/null; then
                rm -f "$INTERMEDIATE"
                exit 1
            fi

            echo "70"; echo "# Розпаковуємо папку..."
            tar -xzf "$INTERMEDIATE" -C "$(dirname "$TARGET")"
            rm "$INTERMEDIATE"
            echo "100"; echo "# Готово!"
        ) | zenity --progress --title="Обробка" --text="Відновлення папки..." --percentage=0 --auto-close

        if [ $? -eq 0 ]; then
            zenity --info --text="Папка успішно розшифрована та розгорнута!"
        else
            zenity --error --text="Не вдалося розшифрувати. Можливо, вказано неправильний пароль!"
        fi

    else
        OUT_FILE="${TARGET%.gpg}"

        (
            echo "50"; echo "# Розшифровуємо файл..."
            if ! echo "$PASS" | gpg --batch --yes --passphrase-fd 0 -o "$OUT_FILE" -d "$TARGET" 2>/dev/null; then
                exit 1
            fi
            echo "100"; echo "# Готово!"
        ) | zenity --progress --title="Обработка" --text="Розшифрування файлу..." --percentage=0 --auto-close

        if [ $? -eq 0 ]; then
            zenity --info --text="Файл збережено як:\n<b>$OUT_FILE</b>"
        else
            zenity --error --text="Не вдалося розшифрувати. Можливо, вказано неправильний пароль!"
        fi
    fi
fi
