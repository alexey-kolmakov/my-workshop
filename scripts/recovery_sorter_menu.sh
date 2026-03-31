#!/bin/bash
# INFO: [СОРТУВАННЯ] сортування за типом файлів

SORT_DIR="$HOME/RecoveredSorted"
RECUP_DIRS=("/mnt/storage/Backup")  # початковий список, можна змінити

mkdir -p "$SORT_DIR"/{images,docs,video,archives,other}

add_multiple_dirs() {
  RECUP_DIRS=()
  echo -e "\e[36m📥 Введи кілька шляхів до recup_dir.* (по одному, завершити — порожній рядок):\e[0m"
  while true; do
    read -p "➤ " path
    [[ -z "$path" ]] && break
    if [[ -d "$path" ]]; then
      RECUP_DIRS+=("$path")
      echo -e "\e[32m✅ Додано: $path\e[0m"
    else
      echo -e "\e[31m❌ Не знайдено: $path\e[0m"
    fi
  done
}

show_stats() {
  echo -e "\e[36m📊 Статистика типів файлів:\e[0m"
  for dir in "${RECUP_DIRS[@]}"; do
    echo -e "\n📁 $dir"
    find "$dir" -type f -exec file {} \; | cut -d: -f2 | sort | uniq -c
  done
}

sort_files() {
  echo -e "\e[33m📂 Сортування файлів...\e[0m"
  for dir in "${RECUP_DIRS[@]}"; do
    find "$dir" -type f -iname "*.jpg" -exec mv -n {} "$SORT_DIR/images/" \;
    find "$dir" -type f -iname "*.png" -exec mv -n {} "$SORT_DIR/images/" \;
    find "$dir" -type f -iname "*.pdf" -exec mv -n {} "$SORT_DIR/docs/" \;
    find "$dir" -type f -iname "*.docx" -exec mv -n {} "$SORT_DIR/docs/" \;
    find "$dir" -type f -iname "*.zip" -exec mv -n {} "$SORT_DIR/archives/" \;
    find "$dir" -type f -iname "*.mp4" -exec mv -n {} "$SORT_DIR/video/" \;
    find "$dir" -type f ! -iname "*.jpg" ! -iname "*.png" ! -iname "*.pdf" ! -iname "*.docx" ! -iname "*.zip" ! -iname "*.mp4" -exec mv -n {} "$SORT_DIR/other/" \;
  done
  echo -e "\e[32m✅ Сортування завершено!\e[0m"
}

biggest_files() {
  echo -e "\e[36m🔍 Найбільші файли:\e[0m"
  for dir in "${RECUP_DIRS[@]}"; do
    echo -e "\n📁 $dir"
    find "$dir" -type f -exec du -h {} + | sort -hr | head -n 10
  done
}

archive_sorted() {
  echo -e "\e[33m📦 Архівація...\e[0m"
  tar -czf "$HOME/recovered_sorted.tar.gz" -C "$SORT_DIR" .
  echo -e "\e[32m✅ Архів створено: ~/recovered_sorted.tar.gz\e[0m"
}

clean_empty_dirs() {
  echo -e "\e[33m🧹 Видалення порожніх папок...\e[0m"
  for dir in "${RECUP_DIRS[@]}"; do
    find "$dir" -type d -empty -delete
  done
  echo -e "\e[32m✅ Порожні папки видалено!\e[0m"
}

list_blocks() {
  echo -e "\e[36m📁 Блоки папок (по 10):\e[0m"
  for base in "${RECUP_DIRS[@]}"; do
    echo -e "\n📁 $base"
    find "$base" -maxdepth 1 -type d -name "recup_dir.*" | sort | awk '
      { dirs[NR] = $0 }
      END {
        block = 1
        for (i = 1; i <= NR; i += 10) {
          printf "[%d] %s → %s\n", block, dirs[i], dirs[i+9] ? dirs[i+9] : dirs[NR]
          block++
        }
      }
    '
  done
}

fix_permissions() {
  read -p "🔧 Введи шлях до recup_dir.* (наприклад: /mnt/storage/Backup/recup_dir.420): " target
  if [[ -d "$target" ]]; then
    echo -e "\e[33m🛠️ Виправляю права доступу...\e[0m"
    sudo chown -R "$USER:$USER" "$target"
    sudo chmod -R u+rw "$target"
    sudo chattr -i "$target"/* 2>/dev/null
    echo -e "\e[32m✅ Готово! Права доступу оновлено.\e[0m"
  else
    echo -e "\e[31m❌ Папка не знайдена!\e[0m"
  fi
}

quick_doc_preview() {
  read -p "📄 Введи путь к .docx или .doc файлу: " docfile
  if [[ -f "$docfile" ]]; then
    if [[ "$docfile" == *.docx ]]; then
      echo -e "\e[36m👀 Предпросмотр .docx:\e[0m"
      unzip -p "$docfile" word/document.xml 2>/dev/null | sed 's/<[^>]*>//g' | less
    elif [[ "$docfile" == *.doc ]]; then
      if command -v catdoc &>/dev/null; then
        echo -e "\e[36m👀 Предпросмотр .doc:\e[0m"
        catdoc "$docfile" | less
      else
        echo -e "\e[33m⚠️ Утилита catdoc не установлена. Установи её командой:\e[0m"
        echo "sudo apt install catdoc"
      fi
    else
      echo -e "\e[31m❌ Это не .docx или .doc файл!\e[0m"
    fi
  else
    echo -e "\e[31m❌ Файл не найден!\e[0m"
  fi
}

menu() {
  clear
  echo -e "\e[36m========== 📂 Recovery Sorter ==========\e[0m"
  echo "Вибрані папки:"
  for d in "${RECUP_DIRS[@]}"; do echo "📁 $d"; done
  echo "---------------------------------------"
  echo "0. Додати кілька recup_dir.* для обробки"
  echo "1. Показати статистику типів файлів"
  echo "2. Сортувати по типу (jpg, pdf, zip…)"
  echo "3. Знайти найбільші файли"
  echo "4. Архівувати відсортоване"
  echo "5. Видалити порожні recup_dir.*"
  echo "6. Показати блоки папок по 10"
  echo "7. Виправити права доступу до recup_dir.*"
  echo "8. 👀 Быстрый просмотр .docx/.doc без Word"
  echo "9. Вийти"
  echo -e "\e[36m=======================================\e[0m"
  read -p "Вибери дію: " choice
  case $choice in
    0) add_multiple_dirs ;;
    1) show_stats ;;
    2) sort_files ;;
    3) biggest_files ;;
    4) archive_sorted ;;
    5) clean_empty_dirs ;;
    6) list_blocks ;;
    7) fix_permissions ;;
    8) quick_doc_preview ;;
    9) exit 0 ;;
    *) echo -e "\e[31mНевірний вибір!\e[0m"; sleep 1 ;;
  esac
  read -p "Натисни Enter для повернення в меню..." ; menu
}

menu

