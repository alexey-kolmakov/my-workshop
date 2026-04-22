#!/bin/bash
# INFO: [СИСТЕМА] прибрати тачпад якщо є миша 

# Имя твоего устройства (основная часть)
ID_PART="ELAN0709"
# Полное имя для команды отключения
FULL_NAME="ELAN0709:00 04F3:31BF Touchpad"

while true; do
    # Ищем мыши, но исключаем ВСЁ, что связано с ELAN0709 и виртуальный XTEST
    MOUSE_COUNT=$(xinput list --name-only | grep -i 'mouse' | grep -vE "$ID_PART|XTEST" | wc -l)

    if [ "$MOUSE_COUNT" -gt 0 ]; then
        # Если нашлась реально КУПЛЕННАЯ мышь (USB или Bluetooth)
        xinput set-prop "$FULL_NAME" "Device Enabled" 0 2>/dev/null
    else
        # Если в списке остались только «внутренние» компоненты ELAN
        xinput set-prop "$FULL_NAME" "Device Enabled" 1 2>/dev/null
    fi
    
    sleep 2
done
