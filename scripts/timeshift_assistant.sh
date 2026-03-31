#!/bin/bash
# INFO: [СИСТЕМА] Перенос снапшотов на флешку и обратно



# Пути
SNAPSHOT_DIR="/mnt/timeshift_ssd/timeshift/snapshots"
USB_MOUNT="/mnt/TIMESHIFT_BACKUP"

# Обработка Ctrl+C
trap 'echo -e "\n⛔ Копирование прервано вручную. Операция отменена."; exit 130' INT

# Проверка флешки
if ! mountpoint -q "$USB_MOUNT"; then
    notify-send "Timeshift Assistant" "❌ Флешка не подключена: $USB_MOUNT"
    echo "❌ Флешка не подключена: $USB_MOUNT"
    exit 1
fi

# Выбор действия
echo "🔧 Что делаем?"
echo "1 — Скопировать последний снапшот на флешку"
echo "2 — Восстановить снапшот с флешки"
read -p "Ваш выбор (1/2): " CHOICE

if [ "$CHOICE" == "1" ]; then
    # Копирование на флешку
    LATEST=$(ls -1t "$SNAPSHOT_DIR" | head -n 1)
    SRC="$SNAPSHOT_DIR/$LATEST/"
    DST="$USB_MOUNT/$LATEST/"

    if [ -z "$LATEST" ] || [ ! -d "$SRC" ]; then
        notify-send "Timeshift Assistant" "❌ Снапшот не найден: $SRC"
        echo "❌ Снапшот не найден: $SRC"
        exit 1
    fi

    # Проверка на наличие /home
    if [ -d "$SRC/localhost/home" ]; then
        HOMESIZE=$(du -sh "$SRC/localhost/home" 2>/dev/null | cut -f1)
        echo "⚠️ Внимание: снапшот содержит /home (~$HOMESIZE)"
    else
        echo "✅ /home не включён в снапшот"
    fi

    echo "📦 Копирую '$LATEST' на флешку..."
    if sudo rsync -ah --info=progress2 "$SRC" "$DST"; then
        notify-send "Timeshift Assistant" "✅ Снапшот '$LATEST' скопирован на флешку"
        echo "✅ Снапшот '$LATEST' скопирован на флешку."
    else
        notify-send "Timeshift Assistant" "❌ Ошибка при копировании снапшота"
        echo "❌ Ошибка при копировании снапшота."
        exit 1
    fi

elif [ "$CHOICE" == "2" ]; then
    # Восстановление с флешки
    SNAP_NAME=$(ls -1 "$USB_MOUNT" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}' | head -n 1)
    SRC_PATH="$USB_MOUNT/$SNAP_NAME"
    DST_PATH="$SNAPSHOT_DIR/$SNAP_NAME"

    if [ -z "$SNAP_NAME" ] || [ ! -d "$SRC_PATH" ]; then
        notify-send "Timeshift Assistant" "❌ Снапшот не найден на флешке"
        echo "❌ Снапшот не найден на флешке."
        exit 1
    fi

    # Проверка на существование
    if [ -d "$DST_PATH" ]; then
        echo "⚠️ Снапшот '$SNAP_NAME' уже существует в целевой папке."
        read -p "Перезаписать его? (y/n): " OVERWRITE
        if [ "$OVERWRITE" != "y" ]; then
            echo "❌ Восстановление отменено."
            exit 1
        fi
        echo "🔁 Перезаписываю существующий снапшот..."
    fi

    echo "🔁 Восстанавливаю снапшот '$SNAP_NAME'..."

    # Проверка вложенности
    if [ -d "$SRC_PATH/$SNAP_NAME" ]; then
        echo "📦 Обнаружена лишняя вложенность. Копирую содержимое..."
        sudo rsync -ah --info=progress2 "$SRC_PATH/$SNAP_NAME/" "$DST_PATH/"
    else
        echo "📦 Структура корректна. Копирую напрямую..."
        sudo rsync -ah --info=progress2 "$SRC_PATH/" "$DST_PATH/"
    fi

    # Проверка результата
    if [ -d "$DST_PATH/localhost" ]; then
        notify-send "Timeshift Assistant" "✅ Снапшот '$SNAP_NAME' восстановлен. Открой Timeshift и нажми Restore."
        echo "✅ Снапшот '$SNAP_NAME' восстановлен."
        echo "🚀 Открой Timeshift и нажми Restore."
    else
        notify-send "Timeshift Assistant" "❌ Копирование не удалось."
        echo "❌ Копирование не удалось."
        exit 1
    fi

else
    echo "❌ Неверный выбор. Завершаю."
    exit 1
fi
