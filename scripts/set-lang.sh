#!/bin/bash
# INFO: [СИСТЕМА] Встановлює обрану локаль


echo "Текущие локали системы:"
locale | sed 's/^/  /'
echo

echo "Выбери язык интерфейса:"
echo "0) Оставить текущий язык"
echo "1) Русский (ru_RU.UTF-8)"
echo "2) Українська (uk_UA.UTF-8)"
echo "3) English (en_US.UTF-8)"
echo "4) Deutsch (de_DE.UTF-8)"
read -p "Введите номер (0-4): " choice

case "$choice" in
  0) echo "Текущий язык оставлен."; exit 0 ;;
  1) LANGCODE="ru_RU.UTF-8" ;;
  2) LANGCODE="uk_UA.UTF-8" ;;
  3) LANGCODE="en_US.UTF-8" ;;
  4) LANGCODE="de_DE.UTF-8" ;;
  *) echo "Неверный выбор."; exit 1 ;;
esac

echo "Устанавливаю язык: $LANGCODE"

# Кандидаты на установку (будут установлены только существующие)
CANDIDATES=(
  locales
  locales-all
  thunar-data
  thunar-volman
  xfce4-panel
  xfce4-settings
  xfdesktop4
)

INSTALL=()

# Проверяем, какие пакеты реально существуют
for pkg in "${CANDIDATES[@]}"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
        INSTALL+=("$pkg")
    else
        echo "Пропускаю отсутствующий пакет: $pkg"
    fi
done

sudo apt update
sudo apt install -y "${INSTALL[@]}"

# Генерация локали
sudo sed -i "s/^# *$LANGCODE/$LANGCODE/" /etc/locale.gen
sudo locale-gen

# Установка системной локали
sudo update-locale LANG=$LANGCODE LANGUAGE=${LANGCODE%%.*}

echo "Готово. Перезагрузись."
