#!/bin/bash
# INFO: [СИСТЕМА] скрипт відновлення стабільності системи


# 🧰 system-checkup.sh — универсальный скрипт для восстановления стабильности системы

echo "=============================="
echo "🔧 Проверка и обслуживание системы"
echo "=============================="
echo

# Проверка свободного места
echo "1️⃣ Проверка свободного места:"
df -h | grep -E '^/|Filesystem'
echo
sleep 1

# Очистка кеша apt и старых пакетов
echo "2️⃣ Очистка системного мусора..."
sudo apt clean -y
sudo apt autoremove --purge -y
echo "✅ Очистка завершена."
echo
sleep 1

# Очистка журнала systemd (если он есть)
if command -v journalctl &>/dev/null; then
    echo "3️⃣ Очистка старых логов journalctl..."
    sudo journalctl --vacuum-time=5d
    echo "✅ Логи старше 5 дней удалены."
    echo
fi

# Обновление списка пакетов
echo "4️⃣ Обновление индекса пакетов..."
sudo apt update
echo
sleep 1

# Исправление поломанных пакетов
echo "5️⃣ Проверка и исправление зависимостей..."
sudo apt -f install -y
echo "✅ Проверка завершена."
echo
sleep 1

# Проверка файлового менеджера Thunar
if pgrep -x "thunar" >/dev/null; then
    echo "6️⃣ Перезапуск Thunar и очистка его кэша..."
    thunar -q
    rm -rf ~/.cache/Thunar
    nohup thunar >/dev/null 2>&1 &
    echo "✅ Thunar перезапущен."
    echo
fi

echo "=============================="
echo "✅ Обслуживание завершено!"
echo "=============================="

