#!/bin/bash
# INFO: [СИСТЕМА] Очищення та реставрація пакетів системи


echo "Очистка и реставрация пакетов системы"

# 1️⃣ Удаляем мусор и старые пакеты
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean

# 2️⃣ Проверяем и обновляем индексы пакетов
sudo apt update -y

# 3️⃣ Оптимизируем зеркала (ищет самое быстрое и надёжное)
if command -v mintupdate >/dev/null 2>&1; then
  sudo mintupdate-cli relaunch
else
  echo "mintupdate не найден, можно вручную запустить 'Software Sources' → 'Official Repositories' → 'Main' → 'Mirror' для выбора быстрого зеркала."
fi
echo "Очистка завершена!"
read -p "Нажмите Enter для выхода..."
# Очистка и реставрация пакетов системы
