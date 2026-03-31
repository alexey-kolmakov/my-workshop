#!/bin/bash
# INFO: [АРХІВ] створює копію /home

# Меню управления разделами
while true; do
  clear
  echo "=== МЕНЮ УПРАВЛЕНИЯ РАЗДЕЛАМИ ==="
  echo "1) Примонтировать /dev/sda3 как /home"
  echo "2) Примонтировать /dev/sda4 как /mnt/storage"
  echo "3) Проверить статус разделов (lsblk)"
  echo "4) Показать свободное место (df -h)"
  echo "5) Сделать резервную копию /home → storage"
  echo "6) Выйти"
  echo "----------------------------------"
  read -p "Выбери действие: " choice

  case $choice in
    1)
      echo "Монтирую /dev/sda3 как /home..."
      sudo mount /dev/sda3 /home
      read -p "Нажми Enter для продолжения"
      ;;
    2)
      echo "Монтирую /dev/sda4 как /mnt/storage..."
      sudo mount /dev/sda4 /mnt/storage
      read -p "Нажми Enter для продолжения"
      ;;
    3)
      echo "Статус разделов:"
      lsblk -f
      read -p "Нажми Enter для продолжения"
      ;;
    4)
      echo "Свободное место:"
      df -h | grep '^/dev'
      read -p "Нажми Enter для продолжения"
      ;;
    5)
      echo "Создаю резервную копию /home → /mnt/storage/home_backup.tar.gz..."
      sudo tar -czvf /mnt/storage/home_backup.tar.gz /home
      echo "Готово!"
      read -p "Нажми Enter для продолжения"
      ;;
    6)
      echo "Выход из меню. До встречи!"
      break
      ;;
    *)
      echo "Неверный выбор. Попробуй снова."
      read -p "Нажми Enter для продолжения"
      ;;
  esac
done
