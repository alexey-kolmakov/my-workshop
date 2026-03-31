#!/bin/bash
# INFO: [СИСТЕМА] підключення/вимкнення зовнішнього диска

UUID_NDD="58b7861d-3f99-4f35-abb4-1e3487519560"
UUID_ARCH="3366803b-acfd-480a-8357-23512116fcc4"

MP_NDD="/mnt/NDD"
MP_ARCH="/mnt/NDD_ARCHIVAL"

# 1. Если диски смонтированы — отключаем
if mount | grep -q "$MP_NDD"; then
    sudo umount "$MP_NDD"
    sudo umount "$MP_ARCH"
    notify-send "Внешние диски" "Оба раздела (NDD и ARCHIVAL) отключены"
    exit 0
fi

# 2. Если нет — подключаем
sudo mkdir -p "$MP_NDD" "$MP_ARCH"

sudo mount "/dev/disk/by-uuid/$UUID_NDD" "$MP_NDD"
sudo mount "/dev/disk/by-uuid/$UUID_ARCH" "$MP_ARCH"

# Сообщаем об успехе
notify-send "Внешние диски" "Разделы подключены. Открываю проводник..."

# 3. Открываем оба раздела в Thunar
# Это откроет два отдельных окна, чтобы ты видел всё содержимое диска
thunar "$MP_NDD" &
thunar "$MP_ARCH" &
