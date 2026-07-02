#!/bin/bash
# INFO: [СИСТЕМА] Скрипт оптимізує підключення Wi-Fi (MX-Linux; MiniOS)

sudo modprobe -r rtw88_8822ce
sudo modprobe rtw88_8822ce


LOG="$HOME/rtl8822ce-optimize.log"
echo "=== Оптимизация RTL8822CE ===" > "$LOG"

notify-send "Wi‑Fi" "🚀 Запуск оптимизации RTL8822CE"

# 1. Проверка адаптера
echo "[1] Проверка адаптера..." >> "$LOG"
ADAPTER=$(lspci | grep -i "8822ce")
echo "Адаптер: $ADAPTER" >> "$LOG"

# 2. Создание файла параметров драйвера
echo "[2] Настройка драйвера rtw88..." >> "$LOG"

sudo bash -c 'cat > /etc/modprobe.d/rtl8822ce.conf <<EOF
options rtw88_pci disable_aspm=1
options rtw88_core disable_lps=1
options rtw88_core disable_lps_deep=1
EOF'

echo "Файл /etc/modprobe.d/rtl8822ce.conf создан." >> "$LOG"

# 3. Отключение энергосбережения адаптера
echo "[3] Отключение power saving..." >> "$LOG"
sudo iw dev wlan0 set power_save off
echo "Power save отключён." >> "$LOG"

# 4. Отключение power saving в NetworkManager
echo "[4] Настройка NetworkManager..." >> "$LOG"

CONN=$(nmcli -t -f NAME connection show | head -n 1)
sudo nmcli connection modify "$CONN" 802-11-wireless.powersave 2

echo "NM powersave отключён для подключения: $CONN" >> "$LOG"

# 5. Перезагрузка модуля rtw88
echo "[5] Перезагрузка модуля rtw88..." >> "$LOG"

sudo modprobe -r rtw88_pci rtw88_8822ce rtw88_core
sudo modprobe rtw88_pci

echo "Модуль rtw88 перезагружен." >> "$LOG"

# 6. Диагностика сигнала
echo "[6] Диагностика сигнала..." >> "$LOG"

RSSI=$(nmcli -t -f IN-USE,SIGNAL dev wifi | grep "*" | awk -F: '{print $2}')
FREQ=$(nmcli -t -f IN-USE,FREQ dev wifi | grep "*" | awk -F: '{print $2}')

echo "RSSI: $RSSI%" >> "$LOG"
echo "Частота: $FREQ MHz" >> "$LOG"

# 7. Рекомендации
echo "[7] Рекомендации:" >> "$LOG"

if [[ "$RSSI" -lt 50 ]]; then
    echo "Сигнал слабый (<50%). Рекомендуется использовать 2.4 GHz." >> "$LOG"
    notify-send "Wi‑Fi" "⚠ Слабый сигнал (<50%). Лучше использовать 2.4 GHz."
else
    echo "Сигнал нормальный." >> "$LOG"
fi

# 8. Завершение
notify-send "Wi‑Fi" "✅ Оптимизация RTL8822CE завершена"
zenity --text-info --title="RTL8822CE Оптимизация" --filename="$LOG"
