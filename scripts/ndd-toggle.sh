#!/bin/bash
# INFO: [СИСТЕМА] підключення/вимкнення зовнішнього диска


# === НАСТРОЙКИ ===
UUID_NDD="58b7861d-3f99-4f35-abb4-1e3487519560"
UUID_ARCH="3366803b-acfd-480a-8357-23512116fcc4"

MP_NDD="/mnt/NDD"
MP_ARCH="/mnt/NDD_ARCHIVAL"

DEV_NDD="/dev/disk/by-uuid/$UUID_NDD"
DEV_ARCH="/dev/disk/by-uuid/$UUID_ARCH"

notify-send "NDD" "Проверяю диск..."

# Проверка: есть ли устройство вообще
if [ ! -e "$DEV_NDD" ]; then
    notify-send "NDD" "Диск не подключён"
    exit 1
fi

# Определяем базовый диск (/dev/sdb)
DISK=$(lsblk -no pkname "$DEV_NDD" | head -n1)
DISK="/dev/$DISK"

# Проверяем: смонтирован ли
if mount | grep -q "$MP_NDD"; then
    notify-send "NDD" "Отключение..."

    # Закрываем окна файлового менеджера (важно!)
    pkill -f "$MP_NDD"
    pkill -f "$MP_ARCH"

    # Размонтирование
    udisksctl unmount -b "$DEV_NDD"
    udisksctl unmount -b "$DEV_ARCH"

    # Отключение питания
    udisksctl power-off -b "$DISK"

    notify-send "NDD" "Диск можно извлекать"
    exit 0
fi

# === ПОДКЛЮЧЕНИЕ ===

notify-send "NDD" "Подключение..."

mkdir -p "$MP_NDD" "$MP_ARCH"

udisksctl mount -b "$DEV_NDD"
udisksctl mount -b "$DEV_ARCH"

# Небольшая пауза, чтобы система успела смонтировать
sleep 1

# Открываем именно нужные папки
thunar "$MP_NDD" &
thunar "$MP_ARCH" &

notify-send "NDD" "Разделы подключены"
