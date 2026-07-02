#!/bin/bash
# INFO: [СИСТЕМА] Налаштовує та здійснює підключення Wi-Fi


sudo nmcli device wifi connect "Vokamlok-5" password "..."

APPDIR="$(dirname "$(readlink -f "$0")")/../.."

# Определяем интерфейс Wi-Fi через NetworkManager
IFACE=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1}' | head -n 1)

if [[ -z "$IFACE" ]]; then
    notify-send "Wi‑Fi" "❌ Интерфейс Wi‑Fi не найден"
    zenity --error --text="Wi-Fi интерфейс не найден!"
    exit 1
fi

# Выбор сети
SSID=$(nmcli -t -f SSID dev wifi | grep -v '^$' | sort -u | \
    zenity --list --title="Выбор сети" --column="SSID")

if [[ -z "$SSID" ]]; then
    notify-send "Wi‑Fi" "❌ Сеть не выбрана"
    zenity --error --text="Сеть не выбрана."
    exit 1
fi

# Пароль
PASSWORD=$(zenity --password --title="Пароль для $SSID")

if [[ -z "$PASSWORD" ]]; then
    notify-send "Wi‑Fi" "❌ Пароль не введён"
    zenity --error --text="Пароль не введён."
    exit 1
fi
# -----------------------------
# Выбор лучшей точки по скорости канала (RATE) и сигналу (RSSI)
# -----------------------------
BEST_ENTRY=$(nmcli -t -f SSID,BSSID,FREQ,SIGNAL,RATE dev wifi | \
    awk -F: -v target="$SSID" '$1==target {print $0}' | \
    sort -t: -k5 -nr -k4 -nr | head -n 1)

if [[ -z "$BEST_ENTRY" ]]; then
    notify-send "Wi‑Fi" "❌ Не удалось найти сеть $SSID"
    zenity --error --text="Сеть $SSID не найдена."
    exit 1
fi

BEST_BSSID=$(echo "$BEST_ENTRY" | awk -F: '{print $2}')
BEST_FREQ=$(echo "$BEST_ENTRY" | awk -F: '{print $3}')
BEST_SIGNAL=$(echo "$BEST_ENTRY" | awk -F: '{print $4}')
BEST_RATE=$(echo "$BEST_ENTRY" | awk -F: '{print $5}')

notify-send "Wi‑Fi" "🚀 Выбрана самая быстрая точка:\nBSSID: $BEST_BSSID\nЧастота: $BEST_FREQ MHz\nСигнал: $BEST_SIGNAL%\nСкорость: $BEST_RATE Мбит/с"
echo "Лучшая точка: $BEST_BSSID ($BEST_FREQ MHz, $BEST_SIGNAL%, $BEST_RATE Мбит/с)" >> "$LOGFILE"

# -----------------------------
# Уведомления после подключения
# -----------------------------
if ping -c 1 google.com >/dev/null 2>&1; then
    notify-send "Wi‑Fi" "✅ Подключено к $SSID"
else
    notify-send "Wi‑Fi" "❌ Нет доступа к интернету"
fi

zenity --text-info --title="Wi-Fi лог" --filename="$LOGFILE"

# -----------------------------
# Монитор потери сети + авто‑переподключение
# -----------------------------
(
    LAST_STATE="online"

    while true; do
        if ping -c 1 google.com >/dev/null 2>&1; then
            if [[ "$LAST_STATE" == "offline" ]]; then
                notify-send "Wi‑Fi" "🔄 Интернет восстановлен"
                LAST_STATE="online"
            fi
        else
            if [[ "$LAST_STATE" == "online" ]]; then
                notify-send "Wi‑Fi" "❌ Интернет пропал"
                LAST_STATE="offline"
            fi

            # Авто‑переподключение
            nmcli device wifi connect "$SSID" password "$PASSWORD" bssid "$BEST_BSSID"

            # Проверка после попытки переподключения
            if ping -c 1 google.com >/dev/null 2>&1; then
                notify-send "Wi‑Fi" "🔄 Интернет восстановлен"
                LAST_STATE="online"
            fi
        fi

        sleep 5
    done
) &
