#!/bin/bash
# INFO: [СИСТЕМА] розширений техогляд системи Linux

# 🧰 system-checkup-plus.sh — расширенный техосмотр системы Linux

echo "=============================="
echo "🔧 Расширенное обслуживание системы"
echo "=============================="
echo

# 1️⃣ Проверка свободного места
echo "1️⃣ Проверка свободного места:"
df -h | grep -E '^/|Filesystem'
echo
sleep 1

# 2️⃣ Очистка кеша apt и старых пакетов
echo "2️⃣ Очистка системного мусора..."
sudo apt clean -y
sudo apt autoremove --purge -y
echo "✅ Очистка завершена."
echo
sleep 1

# 3️⃣ Очистка журнала systemd
if command -v journalctl &>/dev/null; then
    echo "3️⃣ Очистка старых логов journalctl..."
    sudo journalctl --vacuum-time=5d
    echo "✅ Логи старше 5 дней удалены."
    echo
fi

# 4️⃣ Обновление списка пакетов
echo "4️⃣ Обновление списка пакетов..."
sudo apt update
echo
sleep 1

# 5️⃣ Исправление поломанных пакетов
echo "5️⃣ Проверка и исправление зависимостей..."
sudo apt -f install -y
echo "✅ Проверка завершена."
echo
sleep 1

# 6️⃣ Проверка обновлений ядра
echo "6️⃣ Проверка наличия обновлений ядра..."
if dpkg -l | grep -q linux-image; then
    sudo apt list --upgradable 2>/dev/null | grep linux-image || echo "Обновлений ядра не найдено."
else
    echo "❗ Пакеты ядра не найдены (возможно, нестандартная сборка)."
fi
echo
sleep 1

# 7️⃣ Проверка SMART-диска
if command -v smartctl &>/dev/null; then
    echo "7️⃣ Проверка состояния диска (SMART)..."
    DISK=$(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print "/dev/"$1; exit}')
    if [ -n "$DISK" ]; then
        sudo smartctl -H "$DISK" | grep "SMART overall-health" || echo "❗ Не удалось получить статус SMART."
    else
        echo "❗ Не найден ни один диск."
    fi
    echo
else
    echo "❗ Утилита smartctl не установлена (пакет smartmontools)."
    echo
fi

# 8️⃣ Проверка температуры
if command -v sensors &>/dev/null; then
    echo "8️⃣ Температура системы:"
    sensors | grep -E 'temp1|CPU|Core'
    echo
else
    echo "❗ Утилита sensors не установлена (пакет lm-sensors)."
    echo
fi

# 9️⃣ Перезапуск Thunar
if pgrep -x "thunar" >/dev/null; then
    echo "9️⃣ Перезапуск Thunar и очистка его кэша..."
    thunar -q
    rm -rf ~/.cache/Thunar
    nohup thunar >/dev/null 2>&1 &
    echo "✅ Thunar перезапущен."
    echo
fi

echo "=============================="
echo "✅ Обслуживание завершено!"
echo "=============================="

