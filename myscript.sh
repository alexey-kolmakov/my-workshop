#!/bin/bash
# INFO: [АРХІВ] копія /home (з вибором папки)


# Функция для проверки и вызова окна выбора папки
get_backup_path() {
    # 1. Проверяем, установлен ли zenity
    if ! command -v zenity &> /dev/null; then
        echo "-------------------------------------------------------"
        echo "ВНИМАНИЕ: Программа 'zenity' не установлена."
        echo "Для работы графического окна выполните: sudo apt install zenity"
        echo "-------------------------------------------------------"
        read -p "Введите путь для сохранения вручную (напр. /mnt/storage): " manual_path
        echo "$manual_path"
    else
        # 2. Если установлен, открываем окно выбора папки
        selected_path=$(zenity --file-selection --directory --title="Куда сохранить архив?")
        echo "$selected_path"
    fi
}

while true; do
  clear
  echo "=== МЕНЮ УПРАВЛЕНИЯ РАЗДЕЛАМИ ==="
  echo "1) Проверить наличие и статус разделов (lsblk)"  
  echo "2) Проверить статус разделов и их UUID (lsblk -f)"
  echo "3) Показать свободное место (df -h)"
  echo "4) Сделать резервную копию /home (с выбором папки)"
  echo "5) Выйти"
  echo "----------------------------------"
  read -p "Выбери действие: " choice

  case $choice in
    1)
      echo "--- Список разделов ---"
      lsblk
      read -p "Нажми Enter для продолжения"
      ;;
    2)
      echo "--- UUID и файловые системы ---"
      lsblk -f
      read -p "Нажми Enter для продолжения"
      ;;
    3)
      echo "--- Свободное место ---"
      df -h | grep -E '^/dev|Filesystem'
      read -p "Нажми Enter для продолжения"
      ;;
    4)
      # Получаем путь через нашу функцию
      DEST_DIR=$(get_backup_path)

      # Проверяем, не пустой ли путь (если нажали "Отмена") и существует ли папка
      if [ -n "$DEST_DIR" ] && [ -d "$DEST_DIR" ]; then
        # Создаем имя файла с текущей датой: home_backup_2024-05-20.tar.gz
        BACKUP_NAME="home_backup_$(date +%F).tar.gz"
        
        echo "Создаю резервную копию в $DEST_DIR/$BACKUP_NAME..."
        sudo tar -czvf "$DEST_DIR/$BACKUP_NAME" /home
        
        echo "----------------------------------"
        echo "ГОТОВО! Файл сохранен как: $BACKUP_NAME"
      else
        echo "Действие отменено: путь не выбран или папка не существует."
      fi
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
