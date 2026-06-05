#!/bin/bash
# INFO: [СИСТЕМА] Конструктор ярлыков MiniOS Edition (drag’n’drop совместимый)

# 1. Получение цели
if [ -n "$1" ]; then
  target="$1"
else
  read -e -p "📁 Путь к файлу или папке: " target
fi

# Очистка кавычек
target="${target//\'/}"
target="${target//\"/}"

if [ ! -e "$target" ]; then
  echo "❌ Указанный путь не существует: $target"
  exit 1
fi

abs_target=$(realpath "$target")
title=$(basename "$abs_target")
location="$(xdg-user-dir DESKTOP)"

# 2. Выбор иконки
icon_path=$(zenity --file-selection --title="Выберите иконку для $title" --filename=/usr/share/icons/ 2>/dev/null)
if [ -z "$icon_path" ]; then
  icon="application-x-executable"
else
  icon="$icon_path"
fi

# 3. Терминал
if zenity --question --title="Настройка терминала" --text="Запускать '$title' в терминале?" --no-wrap 2>/dev/null; then
  terminal_mode="true"
else
  terminal_mode="false"
fi

# 4. Логика Exec
if [[ "$abs_target" == *.exe ]]; then
  exec_cmd="wine $abs_target"
elif [[ "$abs_target" == *.sh ]]; then
  exec_cmd="bash $abs_target"
else
  exec_cmd="xdg-open $abs_target"
fi

# 5. Создание .desktop
desktop_file="${title// /_}.desktop"
desktop_path="$location/$desktop_file"

cat <<EOF > "$desktop_path"
[Desktop Entry]
Version=1.0
Type=Application
Name=$title
Exec=$exec_cmd
Icon=$icon
Terminal=$terminal_mode
StartupNotify=true
Categories=Utility;
EOF

chmod +x "$desktop_path"

echo -e "\n✅ Готово! Ярлык создан: $desktop_path"
