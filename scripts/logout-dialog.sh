#!/bin/bash

choice=$(zenity --list \
  --title="Выход из системы" \
  --width=360 --height=260 \
  --column="Действие" \
  "Выход" "Перезагрузка" "Выключение")

case "$choice" in
  "Выход") xfce4-session-logout --logout ;;
  "Перезагрузка") systemctl reboot ;;
  "Выключение") systemctl poweroff ;;
  *) echo "Действие отменено или не выбрано." ;;
esac
