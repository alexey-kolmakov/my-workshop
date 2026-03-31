#!/bin/bash
# INFO: [WINE] встановлення wine


echo "=== Шаг 1: Очистка старых пакетов Wine ==="
sudo apt remove --purge -y wine* libwine* winehq* 2>/dev/null
sudo apt autoremove -y
sudo apt autoclean

echo "=== Шаг 2: Исправление зависимостей ==="
sudo dpkg --configure -a
sudo apt --fix-broken install -y

echo "=== Шаг 3: Добавление архитектуры i386 ==="
sudo dpkg --add-architecture i386

echo "=== Шаг 4: Обновление системы ==="
sudo apt update

echo "=== Шаг 5: Установка зависимостей ==="
sudo apt install -y software-properties-common wget apt-transport-https ca-certificates gnupg2

echo "=== Шаг 6: Добавление ключа WineHQ ==="
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

echo "=== Шаг 7: Добавление репозитория WineHQ ==="
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources

echo "=== Шаг 8: Обновление списка пакетов ==="
sudo apt update

echo "=== Шаг 9: Установка Wine ==="
sudo apt install --install-recommends -y winehq-stable

echo "=== Шаг 10: Проверка версии ==="
wine --version

echo "=== ГОТОВО! Wine установлен ==="
