#!/bin/bash
# INFO: [WINE] установка програм в wine-префікс


echo "📦 Менеджер установки програм в Wine-префікс"

# 🔍 Проверка наличия wine
if ! command -v wine &> /dev/null; then
  zenity --error --text="❌ Wine не встановлено. Установка неможлива."
  exit 1
fi

# 📝 Ввод имени префикса
read -p "📝 Введіть ім’я префікса: " PREFIX_NAME
PREFIX_PATH="$HOME/prefixes/$PREFIX_NAME"

if [ ! -d "$PREFIX_PATH" ]; then
  zenity --error --text="❌ Префікс не знайдено:\n$PREFIX_PATH"
  exit 1
fi

# 📁 Получаем список .exe-файлов
PROGRAMS=()
for FILE in "$HOME/installers/"*.exe; do
  [ -e "$FILE" ] || continue
  NAME=$(basename "$FILE" .exe)
  PROGRAMS+=("$NAME")
done

# 🧩 Проверка наличия программ
if [ ${#PROGRAMS[@]} -eq 0 ]; then
  zenity --error --text="❌ У каталозі installers немає .exe-файлів."
  exit 1
fi

# 🎛️ Меню выбора программы
CHOICE=$(zenity --list \
  --title="Виберіть програму для установки" \
  --column="Програма" \
  --width=400 --height=250 \
  "${PROGRAMS[@]}")

# 🔊 Звук выбора
paplay /usr/share/sounds/freedesktop/stereo/dialog-question.oga 2>/dev/null

if [ -z "$CHOICE" ]; then
  echo "🚫 Скасовано."
  exit 0
fi

# 📦 Путь к установщику
INSTALLER="$HOME/installers/$CHOICE.exe"

# ⏳ Анимация прогресса
(
  echo "10"; sleep 1
  echo "# Запуск інсталятора..."; echo "30"; sleep 1
  echo "# Очікування завершення..."; echo "70"; sleep 2
  echo "# Завершення..."; echo "100"; sleep 1
) | zenity --progress \
  --title="Установка $CHOICE" \
  --text="⏳ Будь ласка, зачекайте..." \
  --percentage=0 \
  --auto-close

# 🚀 Запуск установщика
WINEPREFIX="$PREFIX_PATH" prefixes "$INSTALLER"

# 🔍 Поиск установленных программ
find "$PREFIX_PATH/drive_c/Program Files" "$PREFIX_PATH/drive_c/Program Files (x86)" \
  -type f -iname "*.exe" > /tmp/program_list.txt

if [ -s /tmp/program_list.txt ]; then
  zenity --info --title="✅ Установка завершена" \
    --text="Програма <b>$CHOICE</b> успішно встановлена в префікс:\n$PREFIX_NAME"
  paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null

  zenity --text-info \
    --title="🔍 Знайдені програми" \
    --filename=/tmp/program_list.txt \
    --width=600 --height=400
else
  zenity --warning --title="⚠️ Перевірка завершена" \
    --text="Установка завершена, але не знайдено .exe-файлів.\nПеревірте вручну: $PREFIX_PATH/drive_c"
fi
