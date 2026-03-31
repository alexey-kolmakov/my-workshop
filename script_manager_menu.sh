#!/bin/bash
# INFO: [СИСТЕМА] менеджер скриптов

# менеджер скриптов
SCRIPT_DIR="$HOME/SCRIPTS"

choose_directory() {
  read -p "Введите путь к папке со скриптами: " newdir
  if [[ -d "$newdir" ]]; then
    SCRIPT_DIR="$newdir"
    echo -e "\e[32m✅ Папка установлена: $SCRIPT_DIR\e[0m"
  else
    echo -e "\e[31m❌ Папка не найдена!\e[0m"
  fi
}

list_scripts() {
  echo -e "\e[36m📜 Список скриптов в $SCRIPT_DIR:\e[0m"
  for f in "$SCRIPT_DIR"/*.sh; do
    [[ -f "$f" ]] || continue
    desc=$(grep -m1 '^#' "$f" | sed 's/^# *//')
    echo -e "\e[33m$(basename "$f")\e[0m — $desc"
  done
}

add_description() {
  read -p "Введите имя скрипта: " name
  path="$SCRIPT_DIR/$name"
  if [[ -f "$path" ]]; then
    read -p "Введите описание: " desc
    sed -i "1i# $desc" "$path"
    echo -e "\e[32m✅ Описание добавлено!\e[0m"
  else
    echo -e "\e[31m❌ Скрипт не найден!\e[0m"
  fi
}

rename_with_tag() {
  read -p "Введите имя скрипта: " name
  path="$SCRIPT_DIR/$name"
  if [[ -f "$path" ]]; then
    read -p "Введите тег (например: BACKUP, ICONS): " tag
    newname="${name%.sh}_$tag.sh"
    mv "$path" "$SCRIPT_DIR/$newname"
    echo -e "\e[32m✅ Переименовано в $newname\e[0m"
  else
    echo -e "\e[31m❌ Скрипт не найден!\e[0m"
  fi
}

search_scripts() {
  read -p "Введите ключевое слово: " keyword
  echo -e "\e[36m🔍 Поиск по описаниям:\e[0m"
  grep -i "$keyword" "$SCRIPT_DIR"/*.sh | grep '^#' | while read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    desc=$(echo "$line" | cut -d: -f2- | sed 's/^# *//')
    echo -e "\e[33m$(basename "$file")\e[0m — $desc"
  done
}

menu() {
  clear
  echo -e "\e[36m========== 📜 Script Manager ==========\e[0m"
  echo "Текущая папка: $SCRIPT_DIR"
  echo "0. Изменить папку скриптов"
  echo "1. Просмотреть все скрипты с описанием"
  echo "2. Добавить описание к скрипту"
  echo "3. Переименовать с тегом"
  echo "4. Найти по ключевому слову"
  echo "5. Выйти"
  echo -e "\e[36m======================================\e[0m"
  read -p "Выберите действие: " choice
  case $choice in
    0) choose_directory ;;
    1) list_scripts ;;
    2) add_description ;;
    3) rename_with_tag ;;
    4) search_scripts ;;
    5) exit 0 ;;
    *) echo -e "\e[31mНеверный выбор!\e[0m"; sleep 1 ;;
  esac
  read -p "Нажмите Enter для возврата в меню..." ; menu
}

menu

