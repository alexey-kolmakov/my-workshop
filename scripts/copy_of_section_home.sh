#!/bin/bash

while true; do
  clear
  echo "=== МЕНЮ УПРАВЛЕНИЯ РАЗДЕЛАМИ ==="
  echo "1) Проверить наличие и статус разделов (lsblk)"  
  echo "2) Проверить статус разделов и их UUID(lsblk -f)"
  echo "3) Показать свободное место (df -h)"
  echo "4) Сделать резервную копию /home → storage"
  echo "5) Выйти"
  echo "----------------------------------"
  read -p "Выбери действие: " choice

  case $choice in
    1)
      echo "Проверяю количество разделов"
      lsblk
      read -p "Нажми Enter для продолжения"
      ;;
    2)
      echo "Статус разделов и их UUID:"
      lsblk -f
      read -p "Нажми Enter для продолжения"
      ;;
    3)
      echo "Свободное место:"
      df -h | grep '^/dev'
      read -p "Нажми Enter для продолжения"
      ;;
    4)
      echo "Создаю резервную копию /home → /mnt/storage/home_backup.tar.gz..."
      sudo tar -czvf /mnt/storage/home_backup.tar.gz /home
      echo "Готово!"
      read -p "Нажми Enter для продолжения"
      ;;
    5)
      echo "Выход из меню. До встречи!"
      break
      ;;
    *)
      echo "Неверный выбор. Попробуй снова."
      read -p "Нажми Enter для продолжения"
      ;;
  esac
done

# Сделать резервную копию /home → storage
