#!/bin/bash
# INFO: [СИСТЕМА] зміна мови (Debian;LMDE;PeppermintOS;Ubuntu)

echo "Выбери язык интерфейса:"
echo "0) Оставить текущий язык"
echo "1) Русский (ru_RU.UTF-8)"
echo "2) Українська (uk_UA.UTF-8)"
echo "3) English (en_US.UTF-8)"
echo "4) Deutsch (de_DE.UTF-8)"
read -p "Введите номер (0-4): " choice

case "$choice" in
  0)
    echo "Текущий язык оставлен."
    exit 0
    ;;
  1)
    LANGCODE="ru_RU.UTF-8"
    ;;
  2)
    LANGCODE="uk_UA.UTF-8"
    ;;
  3)
    LANGCODE="en_US.UTF-8"
    ;;
  4)
    LANGCODE="de_DE.UTF-8"
    ;;
  *)
    echo "Неверный выбор."
    exit 1
    ;;
esac

echo "Устанавливаю язык: $LANGCODE"

# Полный набор переводов для XFCE/Thunar
XFCE_PACKS="xfce4-panel-l10n xfce4-settings-l10n xfdesktop4-l10n thunar-data thunar-volman thunar-volman-data"

sudo apt update
sudo apt install -y locales locales-all $XFCE_PACKS

# Генерация локали
sudo sed -i "s/^# $LANGCODE/$LANGCODE/" /etc/locale.gen
sudo locale-gen

# Установка системной локали
sudo update-locale LANG=$LANGCODE LANGUAGE=${LANGCODE%%.*}

echo "Готово! Перезагрузись."
