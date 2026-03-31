#!/bin/bash
# INFO: [АРХІВ] створює снапшот /mnt/NDD

SNAPSHOT_DEVICE="/dev/sdb2"
MOUNT_POINT="/mnt/NDD_ARCHIVAL/MEGA/timeshift_ssd"
MIN_FREE_GB=5

# Монтируем, если не смонтировано
if ! mountpoint -q "$MOUNT_POINT"; then
    sudo mount "$SNAPSHOT_DEVICE" "$MOUNT_POINT"
fi

# Получаем свободное место в ГБ
FREE_GB=$(df -BG "$MOUNT_POINT" | awk 'NR==2 {gsub("G","",$4); print $4}')

# Проверка свободного места
if (( FREE_GB < MIN_FREE_GB )); then
    notify-send "Timeshift" "Недостаточно места на $MOUNT_POINT: осталось ${FREE_GB} ГБ"
    echo "Недостаточно места: ${FREE_GB} ГБ. Снапшот не создан."
    exit 1
fi

# Создание снапшота
sudo timeshift --create --snapshot-device "$SNAPSHOT_DEVICE" --comments "System snapshot" --tags D

# Удаление старых снапшотов, оставляя только последние 3
sudo timeshift --list | tail -n +2 | head -n -3 | awk '{print $1}' | xargs -I{} sudo timeshift --delete --snapshot "{}"

# Уведомление об успехе
notify-send "Timeshift" "Снапшот успешно создан. Остались только последние 3."
echo "Снапшот создан. Остались только последние 3."

# Скрипт формирующий снапшот системы
