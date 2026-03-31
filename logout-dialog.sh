#!/bin/bash
# INFO:[СИСТЕМА] діалог вимикання (zenity)


choice=$(zenity --list \
  --title="Выход из системы" \
  --width=400 --height=300 \
  --column="Действие" \
  "Выход" "Перезагрузка" "Выключение")

case "$choice" in
  "Выход") xfce4-session-logout --logout ;;
  "Перезагрузка") systemctl reboot ;;
  "Выключение") systemctl poweroff ;;
  *) echo "Действие отменено или не выбрано." ;;
esac
