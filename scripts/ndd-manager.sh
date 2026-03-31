#!/bin/bash
# INFO: [СИСТЕМА] NDD-менеджер


#NDD-менеджер
# Кольори
RED="\e[31m"
YELLOW="\e[33m"
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

# notify-send
HAS_NOTIFY=false
command -v notify-send >/dev/null && HAS_NOTIFY=true

send_notify() {
    if [ "$HAS_NOTIFY" = true ]; then
        notify-send "$1" "$2"
    fi
}

# Пошук пристрою з меткою NDD
DEVICE=$(blkid | grep 'LABEL="NDD"' | cut -d: -f1)
LABEL=$(blkid -o value -s LABEL "$DEVICE" 2>/dev/null)

get_mountpoint() {
    MOUNTPOINT=$(lsblk -no MOUNTPOINT "$DEVICE" | head -n 1)
}

check_status() {
    get_mountpoint
    if [ -n "$MOUNTPOINT" ]; then
        DF_OUTPUT=$(df "$MOUNTPOINT")
        USED_PERCENT=$(echo "$DF_OUTPUT" | awk 'NR==2 {gsub("%", "", $5); print $5}')
        if [ "$USED_PERCENT" -ge 90 ]; then
            COLOR=$RED
        elif [ "$USED_PERCENT" -ge 70 ]; then
            COLOR=$YELLOW
        else
            COLOR=$GREEN
        fi
        echo -e "📦 Статус: ${COLOR}Смонтовано в $MOUNTPOINT${RESET}"
        echo "$DF_OUTPUT" | awk 'NR==1 {printf "%-15s %-10s %-10s %-10s %-10s\n",$1,$2,$3,$4,$5}
                                 NR==2 {printf "Використано: %s (%s)\n",$3,$5}'
    else
        echo -e "📦 Статус: ${RED}Не смонтовано${RESET}"
    fi
} # ← Закриваюча дужка функції check_status

# Автоматичний статус при запуску
if [ -n "$DEVICE" ]; then
    echo -e "${CYAN}=== Менеджер диска $LABEL ($DEVICE) ===${RESET}"
    check_status
else
    echo -e "${RED}❌ Диск з меткою NDD не знайдено.${RESET}"
    echo -e "${YELLOW}💡 Можливо, диск було відключено. Перепідключіть його або оберіть пункт 5 для оновлення.${RESET}"
    send_notify "Менеджер диска" "❌ Диск NDD не знайдено. Спробуйте оновити список."
fi

# Меню
while true; do
    echo
    echo "1) Смонтувати"
    echo "2) Розмонтувати"
    echo "3) Вимкнути (unmount + power off)"
    echo "4) Перевірити статус"
    echo "5) Оновити список пристроїв"
    echo "0) Вийти"
    echo -n "Вибір: "
    read choice

    case $choice in
        1)
            get_mountpoint
            if [ -n "$MOUNTPOINT" ]; then
                echo -e "${GREEN}✅ Вже смонтовано: $MOUNTPOINT${RESET}"
                send_notify "Диск $LABEL" "✅ Вже смонтовано"
            else
                echo "🔄 Монтування..."
                udisksctl mount -b "$DEVICE"
                send_notify "Диск $LABEL" "✅ Смонтовано успішно"
            fi
            check_status
            ;;
        2)
            get_mountpoint
            if [ -n "$MOUNTPOINT" ]; then
                echo "🔄 Розмонтування..."
                udisksctl unmount -b "$DEVICE"
                send_notify "Диск $LABEL" "🔄 Розмонтовано"
            else
                echo -e "${RED}❌ Вже не смонтовано${RESET}"
            fi
            check_status
            ;;
        3)
            get_mountpoint
            if [ -n "$MOUNTPOINT" ]; then
                echo "🔄 Розмонтування..."
                udisksctl unmount -b "$DEVICE"
                sleep 1
            fi
            echo "⚡ Вимкнення живлення..."
            udisksctl power-off -b "$DEVICE"
            sleep 1
            echo -e "${GREEN}✅ Диск вимкнено.${RESET}"
            send_notify "Диск $LABEL" "⚡ Живлення вимкнено"
            echo -e "${YELLOW}💡 Щоб знову використовувати диск, перепідключіть його фізично.${RESET}"
            send_notify "Диск $LABEL" "💡 Перепідключіть диск, щоб використовувати знову"
            ;;
        4)
            check_status
            ;;
        5)
            echo "🔍 Оновлення списку пристроїв..."
            sudo partprobe
            DEVICE=$(blkid | grep 'LABEL="NDD"' | cut -d: -f1)
            LABEL=$(blkid -o value -s LABEL "$DEVICE" 2>/dev/null)
            if [ -n "$DEVICE" ]; then
                echo -e "${GREEN}✅ Диск знайдено: $DEVICE ($LABEL)${RESET}"
                send_notify "Менеджер диска" "✅ Диск NDD знайдено після оновлення"
            else
                echo -e "${RED}❌ Диск все ще не знайдено.${RESET}"
                send_notify "Менеджер диска" "❌ Диск NDD не знайдено після оновлення"
            fi
            ;;
        0)
            echo "👋 Вихід..."
            break
            ;;
        *)
            echo -e "${RED}❗ Невірний вибір${RESET}"
            send_notify "Менеджер диска" "❗ Невірний вибір у меню"
            ;;
    esac
done
