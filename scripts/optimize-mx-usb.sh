#!/bin/bash

#INFO: [СИСТЕМА] Оптимизирует MX_Linux (через USB)


echo "=== Отключение лишних служб ==="

# Bluetooth
sudo systemctl disable --now bluetooth.service
sudo systemctl disable --now blueman-mechanism.service

# Принтеры (CUPS)
sudo systemctl disable --now cups.service
sudo systemctl disable --now cups-browsed.service

# Avahi (Bonjour)
sudo systemctl disable --now avahi-daemon.service

# Speech dispatcher
sudo systemctl disable --now speech-dispatcherd.service

# ModemManager (если нет 3G/4G модема)
sudo systemctl disable --now ModemManager.service

# Samba (если не используешь сетевые шары)
sudo systemctl disable --now smbd.service
sudo systemctl disable --now nmbd.service

# SMART (бесполезен на USB-SSD)
sudo systemctl disable --now smartmontools.service

echo "=== Настройка I/O под USB-SSD ==="

# Оптимальный планировщик
for disk in /sys/block/sd*/queue/scheduler; do
    echo mq-deadline | sudo tee $disk
done

# Добавление noatime в fstab
if ! grep -q "noatime" /etc/fstab; then
    sudo sed -i 's/errors=remount-ro/errors=remount-ro,noatime/' /etc/fstab
fi

echo "=== Настройка swappiness ==="
sudo sysctl -w vm.swappiness=15
echo "vm.swappiness=15" | sudo tee /etc/sysctl.d/99-swappiness.conf

echo "=== Включение zram ==="
sudo apt install -y zram-tools
echo "ALGO=lz4" | sudo tee /etc/default/zramswap
echo "PERCENT=50" | sudo tee -a /etc/default/zramswap
sudo systemctl restart zramswap

echo "=== Готово! Рекомендуется перезагрузить систему ==="
