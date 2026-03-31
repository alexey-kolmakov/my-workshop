#!/bin/bash
# INFO: [СОРТУВАННЯ] сортування в /mnt/storage/Backup

RECUP_BASE="/mnt/storage/Backup"
SORTED_DIR="$RECUP_BASE/sorted"
DUPES_LOG="$RECUP_BASE/dupes.log"

mkdir -p "$SORTED_DIR"

show_menu() {
  clear
  echo "========== 📦 Recovery Sort Menu =========="
  echo "1. Сортировать файлы по типу"
  echo "2. Удалить дубликаты (fdupes)"
  echo "3. Показать статистику"
  echo "4. Выход"
  echo "==========================================="
  read -p "Выберите действие: " choice
  case $choice in
    1) sort_files ;;
    2) remove_duplicates ;;
    3) show_stats ;;
    4) exit 0 ;;
    *) echo "Неверный выбор"; sleep 1; show_menu ;;
  esac
}

sort_files() {
  echo "🔍 Сортировка файлов..."
  find "$RECUP_BASE"/recup_dir.* -type f | while read -r file; do
    ext="${file##*.}"
    ext="${ext,,}"  # в нижний регистр
    mkdir -p "$SORTED_DIR/$ext"
    cp "$file" "$SORTED_DIR/$ext/"
  done
  echo "✅ Сортировка завершена!"
  read -p "Нажмите Enter для возврата в меню..." ; show_menu
}

remove_duplicates() {
  echo "🧹 Удаление дубликатов..."
  if ! command -v fdupes &>/dev/null; then
    echo "❌ fdupes не установлен. Установите: sudo apt install fdupes"
  else
    fdupes -r "$SORTED_DIR" | tee "$DUPES_LOG"
    echo "📄 Список дубликатов сохранён в $DUPES_LOG"
  fi
  read -p "Нажмите Enter для возврата в меню..." ; show_menu
}

show_stats() {
  echo "📊 Статистика:"
  find "$SORTED_DIR" -type f | wc -l | xargs echo "Всего файлов:"
  find "$SORTED_DIR" -type f -exec du -ch {} + | grep total$
  read -p "Нажмите Enter для возврата в меню..." ; show_menu
}

show_menu

