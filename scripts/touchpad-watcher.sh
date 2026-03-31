#!/bin/bash
# INFO: [СИСТЕМА] прибрати тачпад якщо є миша 


TOUCHPAD_NAME="SynPS/2 Synaptics TouchPad"

while true; do
    # Проверяем наличие подключённых мышей
    if xinput list | grep -i 'mouse' >/dev/null; then
        # Если мышь есть — отключаем тачпад
        xinput disable "$TOUCHPAD_NAME" 2>/dev/null
    else
        # Если мыши нет — включаем тачпад
        xinput enable "$TOUCHPAD_NAME" 2>/dev/null
    fi
    sleep 1
done
