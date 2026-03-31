#!/bin/bash
# INFO: [СИСТЕМА] примонтує iPhone

MOUNTPOINT="$HOME/iphone"

# Проверка, есть ли папка для монтирования
if [ ! -d "$MOUNTPOINT" ]; then
    mkdir -p "$MOUNTPOINT"
fi

# Проверка, подключён ли iPhone
if ideviceinfo >/dev/null 2>&1; then
    # Если уже смонтирован — размонтируем
    if mountpoint -q "$MOUNTPOINT"; then
        fusermount -u "$MOUNTPOINT"
        notify-send "iPhone" "Устройство размонтировано из $MOUNTPOINT"
    else
        # Монтируем
        ifuse "$MOUNTPOINT"
        notify-send "iPhone" "Устройство смонтировано в $MOUNTPOINT"
    fi
else
    notify-send "iPhone" "Устройство не обнаружено. Подключи кабель и доверь компьютер."
fi

