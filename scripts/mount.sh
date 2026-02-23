#!/bin/bash
# mount.sh — интерактивный модуль для монтирования устройства.

DEVICE="$1"
MOUNTPOINT="$2"

# Если устройство не указано — спрашиваем
if [ -z "$DEVICE" ]; then
    read -p "Введите путь к устройству (например, /dev/sdb1): " DEVICE
fi

# Если точка монтирования не указана — спрашиваем
if [ -z "$MOUNTPOINT" ]; then
    read -p "Введите точку монтирования (например, /mnt/usb): " MOUNTPOINT
fi

# Проверяем устройство
if [ ! -b "$DEVICE" ]; then
    echo "Ошибка: $DEVICE не является блочным устройством."
    exit 1
fi

# Проверяем точку монтирования
if [ ! -d "$MOUNTPOINT" ]; then
    echo "Точка монтирования $MOUNTPOINT не существует. Создаю..."
    mkdir -p "$MOUNTPOINT" || { echo "Не удалось создать $MOUNTPOINT"; exit 1; }
fi

echo "Монтирую $DEVICE в $MOUNTPOINT..."

if mount "$DEVICE" "$MOUNTPOINT"; then
    echo "Готово: $DEVICE смонтирован в $MOUNTPOINT"
    exit 0
else
    echo "Ошибка: не удалось смонтировать $DEVICE"
    exit 1
fi

