#!/bin/bash
# INFO:[СИСТЕМА] створення ярлика



if [ -n "$1" ]; then
  target="$1"
else
  read -e -p "📁 Путь к файлу или папке: " target
fi

# Очистка пути от кавычек
target="${target//\'/}"
target="${target//\"/}"

if [ ! -e "$target" ]; then
  echo "❌ Указанный путь не существует: $target"
  exit 1
fi

abs_target=$(realpath "$target")
title=$(basename "$target")
location="$(xdg-user-dir DESKTOP)"

# 🖼️ 1. ВЫБОР ИКОНКИ
icon_path=$(zenity --file-selection --title="Выберите иконку для $title" --filename=/usr/share/icons/ 2>/dev/null)
if [ -z "$icon_path" ]; then
  icon="application-x-executable"
else
  icon="$icon_path"
fi

# 🖥️ 2. ВЫБОР РЕЖИМА ТЕРМИНАЛА
if zenity --question --title="Настройка терминала" --text="Запускать '$title' в окне терминала?\n(Обычно нужно только для скриптов или консольных утилит)" --no-wrap 2>/dev/null; then
  terminal_mode="true"
else
  terminal_mode="false"
fi

# ⚙️ 3. ЛОГИКА КОМАНДЫ
if [[ "$abs_target" == *.exe ]]; then
  exec_cmd="wine \"$abs_target\""
elif [[ "$abs_target" == *.sh ]]; then
  exec_cmd="bash \"$abs_target\""
else
  exec_cmd="xdg-open \"$abs_target\""
fi

desktop_file="${title// /_}.desktop"
desktop_path="$location/$desktop_file"

# 📝 4. ЗАПИСЬ ФАЙЛА
cat <<EOF > "$desktop_path"
[Desktop Entry]
Version=1.0
Type=Application
Name=$title
Exec=$exec_cmd
Icon=$icon
Terminal=$terminal_mode
Path=$(dirname "$abs_target")
StartupNotify=true
Categories=Utility;
EOF

chmod +x "$desktop_path"
echo -e "\n✅ Все готово! Ярлык создан и настроен."
