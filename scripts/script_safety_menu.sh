#!/bin/bash
# INFO: [СИСТЕМА] аналіз скриптів


SCRIPT_PATH=""
QUARANTINE_DIR="$HOME/quarantine_scripts"
mkdir -p "$QUARANTINE_DIR"

highlight_danger() {
  echo "🔍 Анализ потенциально опасных команд:"
  grep -Eni 'rm |mv |dd |chmod |chown |curl |wget |scp |nc |shutdown|reboot|:(){:|:&};:' "$SCRIPT_PATH" || echo "✅ Ничего подозрительного не найдено"
}

show_stats() {
  echo "📊 Статистика:"
  echo "Всего строк: $(wc -l < "$SCRIPT_PATH")"
  echo "Уникальных команд: $(grep -Eo '^[^#]*' "$SCRIPT_PATH" | awk '{print $1}' | sort | uniq | wc -l)"
}

view_script() {
  echo "📄 Содержимое скрипта:"
  echo "----------------------------------"
  cat "$SCRIPT_PATH"
  echo "----------------------------------"
}

rename_script() {
  read -p "Введите новое имя: " newname
  mv "$SCRIPT_PATH" "$(dirname "$SCRIPT_PATH")/$newname"
  echo "✅ Переименовано в $newname"
}

quarantine_script() {
  mv "$SCRIPT_PATH" "$QUARANTINE_DIR/"
  echo "🚫 Скрипт перемещён в карантин: $QUARANTINE_DIR"
}

run_menu() {
  clear
  echo "========== 🛡️ Script Safety Menu =========="
  echo "Анализируем: $SCRIPT_PATH"
  echo "1. Просмотреть скрипт"
  echo "2. Подсветить опасные команды"
  echo "3. Показать статистику"
  echo "4. Переименовать"
  echo "5. Переместить в карантин"
  echo "6. Выйти"
  echo "==========================================="
  read -p "Выберите действие: " choice
  case $choice in
    1) view_script ;;
    2) highlight_danger ;;
    3) show_stats ;;
    4) rename_script ;;
    5) quarantine_script ;;
    6) exit 0 ;;
    *) echo "Неверный выбор"; sleep 1 ;;
  esac
  read -p "Нажмите Enter для возврата в меню..." ; run_menu
}

read -p "Введите путь к скрипту для анализа: " SCRIPT_PATH
if [[ ! -f "$SCRIPT_PATH" ]]; then
  echo "❌ Файл не найден!"
  exit 1
fi

run_menu

