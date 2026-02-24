#!/bin/bash
# Bash-меню для ПКМ Thunar — адаптивне, з логами, звуком і відкриттям документів, працює тільки в меню ПКМ Thunar
source ~/SCRIPTS/actions/create_symlink.sh

# === Функція відкриття документів через MS Office (Wine) ===
open_office_file() {
  FILE="$1"
  WINEPREFIX="/home/minok/prefixes/MS_Office"
  EXT="${FILE##*.}"

  case "$EXT" in
    docx|rtf)
      EXE_PATH="$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Office/Office12/WINWORD.EXE"
      ;;
    doc|rtf)
      EXE_PATH="$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Office/Office12/WINWORD.EXE"
      ;;
    xls|xlsx)
      EXE_PATH="$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Office/Office12/EXCEL.EXE"
      ;;
    *)
      notify-send "Невідомий формат" "Файл не підтримується: .$EXT"
      return 1
      ;;
  esac

  if [[ -f "$FILE" && -f "$EXE_PATH" ]]; then
    WIN_PATH=$(env WINEPREFIX="$WINEPREFIX" winepath -w "$FILE")
    env WINEPREFIX="$WINEPREFIX" wine "$EXE_PATH" "$WIN_PATH" &
    notify-send "Документ відкрито" "$(basename "$FILE") через $(basename "$EXE_PATH")"
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga
  else
    notify-send "Помилка" "Файл або програма не знайдені"
  fi
}

# === Лог запуску ===
echo "Скрипт стартував: $(date)" >> ~/thunar_debug.log
{
  echo "=== Запуск скрипта ==="
  echo "Дата: $(date)"
  echo "DISPLAY: $DISPLAY"
  echo "USER: $USER"
  echo "Аргумент: '$1'"
  echo "Zenity: $(command -v zenity)"
} >> ~/thunar_debug.log

notify-send "Скрипт запущено" "Thunar передав: $(basename "$1")"

# === Перевірки ===
if [ -z "$DISPLAY" ]; then
  notify-send "Помилка" "Немає доступу до графіки. Zenity не спрацює."
  exit 1
fi

if ! command -v zenity &> /dev/null; then
  notify-send "Zenity не знайдено" "Встанови: sudo apt install zenity"
  exit 1
fi

if [ -z "$1" ]; then
  zenity --error --text="Файл не передано. Виділи файл перед викликом меню."
  exit 1
fi
#!/bin/bash

# === Функція створення симлінка ===
create_symlink() {
  FILE="$1"
  DEFAULT_NAME="Link to $(basename "$FILE")"

  # Запит імені симлінка
  LINK_NAME=$(zenity --entry \
    --title="Ім’я симлінка" \
    --text="Введи ім’я симлінка:" \
    --entry-text="$DEFAULT_NAME") || return

  # Вибір папки для симлінка
  LINK_DIR=$(zenity --file-selection \
    --directory \
    --title="Куди зберегти симлінк") || return

  TARGET="$LINK_DIR/$LINK_NAME"

  if ln -s "$FILE" "$TARGET"; then
    notify-send "🔗 Симлінк створено" "$TARGET"
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga
    xdg-open "$LINK_DIR"
  else
    notify-send "❌ Помилка" "Не вдалося створити симлінк"
  fi
}

# === Вибір дії ===
choice=$(zenity --list \
  --title="Thunar Bash Menu" \
  --text="Вибери дію для файлу: $(basename "$1")" \
  --width=600 --height=400 \
  --column="Дія" --column="Опис" \
  "Архівувати" "Створити .tar.gz з файлу" \
  "Конвертувати в PNG" "Зображення → PNG" \
  "Відкрити в терміналі" "Папка файлу в xfce4-terminal" \
  "Переіменувати в нижній регістр" "Ім’я файлу → малі літери" \
  "Відкрити документ" "Відкрити .docx/.rtf/.xls/.xlsx через MS Office"\
  "Створити симлінк" "Зв’язати файл у ~/Links")

if [ -z "$choice" ]; then
  notify-send "Скасовано" "Жодну дію не обрано"
  exit 0
fi

echo "Вибір: '$choice' для '$1'" >> ~/thunar_debug.log

# === Виконання дії ===
case "$choice" in
  "Архівувати")
    tar -czf "${1%.*}.tar.gz" "$1" && \
    notify-send "Готово" "Архів створено: ${1%.*}.tar.gz"
    ;;
  "Конвертувати в PNG")
    convert "$1" "${1%.*}.png" && \
    notify-send "Готово" "PNG створено: ${1%.*}.png"
    ;;
  "Відкрити в терміналі")
    xfce4-terminal --working-directory="$(dirname "$1")"
    ;;
  "Переіменувати в нижній регістр")
    newname="$(dirname "$1")/$(basename "$1" | tr 'A-Z' 'a-z')"
    mv "$1" "$newname" && \
    notify-send "Готово" "Файл переіменовано: $(basename "$newname")"
    ;;
  "Відкрити документ")
    open_office_file "$1"
    ;;
  "Створити симлінк")
  create_symlink "$1"
  ;;

esac
