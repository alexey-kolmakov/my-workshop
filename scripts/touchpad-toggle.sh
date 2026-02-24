#!/bin/bash

# Находим ID тачпада по ключевому слову "touchpad"
TP_ID=$(xinput list | grep -i "touchpad" | grep -Eo "id=[0-9]+" | cut -d= -f2 | head -n1)

# Если тачпад не найден — выходим
[ -z "$TP_ID" ] && exit 1

# Узнаём текущее состояние
STATE=$(xinput list-props "$TP_ID" | grep "Device Enabled" | awk '{print $NF}')

# Переключаем
if [ "$STATE" -eq 1 ]; then
    xinput disable "$TP_ID"
else
    xinput enable "$TP_ID"
fi
