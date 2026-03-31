#!/bin/bash
# INFO:[СИСТЕМА] журнал системи (діагностика та мережа)


echo "====================================================="
echo "   БОРТОВОЙ ЖУРНАЛ СИСТЕМЫ (Диагностика и Сеть)      "
echo "====================================================="

# 1. ТЕМПЕРАТУРА И ЖЕЛЕЗО
echo "--- СОСТОЯНИЕ ЖЕЛЕЗА ---"
# Пытаемся достать температуру через acpi или sensors
TEMP=$(acpi -t 2>/dev/null | awk '{print $4 "°C"}')
[ -z "$TEMP" ] && TEMP=$(sensors | grep -m1 "Core 0" | awk '{print $3}')

echo "[!] Температура процессора: $TEMP"

# Проверка зарядки (актуально для ноутбука)
acpi -b 2>/dev/null || echo "Батарея не обнаружена"

echo ""

# 2. ПОИСК МОДЕЛИ WI-FI
WIFI_MODEL=$(lspci | grep -i network)
echo "--- СЕТЕВОЙ АДАПТЕР ---"
echo "[i] Найдено устройство: $WIFI_MODEL"

# 3. ЛОГИКА ДЛЯ INTEL 4965
if echo "$WIFI_MODEL" | grep -q "4965"; then
    echo ">>> Применяю спец-настройки для Intel 4965..."
    [ -f /etc/modprobe.d/blacklist-wl.conf ] || echo "blacklist wl" | sudo tee /etc/modprobe.d/blacklist-wl.conf
    sudo modprobe -r wl 2>/dev/null
    
    CONF="/etc/modprobe.d/iwl4965.conf"
    SETTINGS="options iwl4965 dma_check=1 swcrypto=1 11n_disable=1"
    if [ ! -f "$CONF" ]; then
        echo "$SETTINGS" | sudo tee $CONF
    fi
fi

# 4. ОБЩИЕ КОМАНДЫ РЕАНИМАЦИИ
echo "[...] Сброс программных блокировок (rfkill)..."
sudo rfkill unblock all
echo "[...] Перезапуск сетевой службы..."
sudo systemctl restart NetworkManager

echo ""
echo "--- ОПЕРАТИВНАЯ ПАМЯТЬ ---"
free -h

echo ""
echo "====================================================="
echo " Диагностика завершена. Нажмите Enter для выхода.    "
echo "====================================================="
