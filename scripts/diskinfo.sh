#!/bin/bash
# INFO: [СИСТЕМА] експрес-діагностика підключених дисків
report=""

report+="=== USB мосты ===\n"
report+="Если мост есть — корпус не пустой.\n"
report+="$(lsusb | grep -Ei 'JMicron|ASMedia|Realtek|Genesys|SATA|NVMe')\n\n"

report+="=== Найденные USB-диски ===\n"
report+="MODEL — модель диска, SIZE — объём, ROTA=0 — SSD, ROTA=1 — HDD.\n"
report+="$(lsblk -o NAME,MODEL,SIZE,ROTA,TRAN | grep usb)\n\n"

report+="=== SMART информация ===\n"

declare -A disk_health
declare -A disk_temp

for disk in $(lsblk -ndo NAME,TRAN | awk '$2=="usb"{print $1}'); do
    dev="/dev/$disk"
    smart=$(sudo smartctl -a "$dev")

    model=$(echo "$smart" | grep -Ei "Device Model" | awk -F: '{print $2}')
    serial=$(echo "$smart" | grep -Ei "Serial Number" | awk -F: '{print $2}')

    # Тип диска
    if echo "$smart" | grep -q "Solid State Device"; then
        type="SSD"
    else
        type="HDD"
    fi

    # Температура (последнее поле)
    temp=$(echo "$smart" | grep -E "Temperature" | awk '{print $NF}')

    # SMART состояние
    if echo "$smart" | grep -q "PASSED"; then
        health="OK"
    else
        health="FAIL"
    fi

    disk_health[$disk]=$health
    disk_temp[$disk]=$temp

    report+="--- $dev ---\n"
    report+="Модель: $model\n"
    report+="Серийный номер: $serial\n"
    report+="Тип диска: $type\n"
    report+="Температура: ${temp}°C\n"
    report+="SMART состояние: $health\n\n"
done

report+="=== Диагностика ===\n"

problem_found=0

for disk in "${!disk_health[@]}"; do
    temp=${disk_temp[$disk]}
    health=${disk_health[$disk]}

    report+="Диск /dev/$disk:\n"

    # SMART
    if [[ "$health" == "FAIL" ]]; then
        report+="  SMART сообщает о проблемах.\n"
        problem_found=1
    else
        report+="  SMART: без ошибок.\n"
    fi

    # Температура
    if [[ $temp -gt 55 ]]; then
        report+="  Температура высокая (${temp}°C).\n"
        problem_found=1
    elif [[ $temp -gt 45 ]]; then
        report+="  Температура повышенная (${temp}°C).\n"
    else
        report+="  Температура нормальная (${temp}°C).\n"
    fi

    report+="\n"
done

if [[ $problem_found -eq 0 ]]; then
    report+="Проблем не обнаружено. Все внешние диски работают нормально.\n"
else
    report+="Есть проблемы. Рекомендуется проверить диски подробнее.\n"
fi

# Вывод через Zenity
zenity --text-info --width=700 --height=600 --title="Информация о внешних дисках" --filename=<(echo -e "$report")
