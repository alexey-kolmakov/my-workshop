#!/bin/bash
# INFO: [СИСТЕМА] Wi-Fi підключення з zenity


# Wi-Fi подключение с zenity: прогресс + лог в $HOME + честная проверка

#LOGFILE="$HOME/wifi-connect.log"
#> "$LOGFILE"

# Проверка root
if [[ $EUID -ne 0 ]]; then
    zenity --error --text="❌ Запусти скрипт через sudo."
    exit 1
fi

# Автоопределение интерфейса (берём первый wl*)
IFACE=$(ip link | awk -F: '/wl/{print $2; exit}' | tr -d ' ')
if [[ -z "$IFACE" ]]; then
    echo "❌ Не найден Wi-Fi интерфейс" >> "$LOGFILE"
    zenity --text-info --title="Wi-Fi лог" --filename="$LOGFILE"
    exit 1
fi

# Ввод SSID
SSID=$(zenity --entry --title="Wi-Fi" --text="Введите имя сети (SSID):")
[[ -z "$SSID" ]] && echo "❌ Имя сети не указано" >> "$LOGFILE" && zenity --text-info --title="Wi-Fi лог" --filename="$LOGFILE" && exit 1

# Ввод пароля
PASSWORD=$(zenity --entry --hide-text --title="Wi-Fi" --text="Введите пароль для $SSID:")
[[ -z "$PASSWORD" ]] && echo "❌ Пароль не указан" >> "$LOGFILE" && zenity --text-info --title="Wi-Fi лог" --filename="$LOGFILE" && exit 1

# Запускаем лог-окно параллельно
tail -f "$LOGFILE" | zenity --text-info --title="Wi-Fi лог" --width=600 --height=400 &

(
echo "10"; echo "# Останавливаю старые процессы..."
echo "Останавливаю старые процессы..." >> "$LOGFILE"
killall wpa_supplicant dhclient 2>>"$LOGFILE"

echo "30"; echo "# Удаляю старый конфиг..."
rm -f "$HOME/wpa.conf" 2>>"$LOGFILE"

echo "50"; echo "# Настраиваю wpa_supplicant..."
wpa_passphrase "$SSID" "$PASSWORD" > "$HOME/wpa.conf" 2>>"$LOGFILE"
wpa_supplicant -B -i "$IFACE" -c "$HOME/wpa.conf" >> "$LOGFILE" 2>&1

echo "70"; echo "# Сброс IP..."
dhclient -r "$IFACE" >> "$LOGFILE" 2>&1

echo "80"; echo "# Получаю новый IP..."
dhclient "$IFACE" >> "$LOGFILE" 2>&1

echo "90"; echo "# Проверяю интернет..."
# Проверка маршрута
if ! ip route | grep -q '^default'; then
    echo "❌ Нет маршрута по умолчанию — интернет недоступен." >> "$LOGFILE"
else
    # Проверка DNS
    if ping -c 2 google.com >> "$LOGFILE" 2>&1; then
        echo "✅ Интернет работает!" >> "$LOGFILE"
    else
        echo "❌ Нет доступа к интернету (DNS/маршрут)." >> "$LOGFILE"
    fi
fi

echo "100"; echo "# Завершено."
) | zenity --progress --title="Wi-Fi подключение" --percentage=0 --auto-close
