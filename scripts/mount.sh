#!/bin/bash
# mount.sh — простой модуль для монтирования устройства в указанную точку.
# Использование:
#   ./mount.sh /dev/sdXN /mnt/point
#
# Пример:
#   ./mount.sh /dev/sdb1 /mnt/usb

DEVICE="$1"
MOUNTPOINT="$2"

if [ -z "$DEVICE" ] || [ -z "$MOUNTPOINT" ]; then
    echo "Использование: $0 /dev/DEVICE /mount/point"
    exit 1
fi

if [ ! -b "$DEVICE" ]; then
    echo "Ошибка: $DEVICE не является блочным устройством."
    exit 1
fi

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
