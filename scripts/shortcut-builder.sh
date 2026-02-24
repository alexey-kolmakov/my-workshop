#!/bin/bash

# 🎯 Конструктор ярлыков с поддержкой drag’n’drop

# Если путь передан как аргумент — используем его
if [ -n "$1" ]; then
  target="$1"
else
  read -e -p "📁 Путь к файлу или папке: " target
fi

# Название ярлыка — по имени файла/папки
title=$(basename "$target")

# Папка для сохранения
location="$HOME/Стільниця"
mkdir -p "$location"

# Иконка по умолчанию
icon="text-x-generic"

# Автоопределение команды запуска
exec_cmd="xdg-open \"$target\""
[[ "$target" == *.exe ]] && exec_cmd="wine \"$target\""
[[ "$target" == *.sh ]] && exec_cmd="bash \"$target\""
[[ -d "$target" ]] && exec_cmd="xdg-open \"$target\""

# Имя .desktop-файла
desktop_file="${title// /_}.desktop"
desktop_path="$location/$desktop_file"

# Создание ярлыка
cat <<EOF > "$desktop_path"
[Desktop Entry]
Version=1.0
Type=Application
Name=$title
Exec=$exec_cmd
Icon=$icon
Terminal=false
#Terminal=true
# --- Категории ---
Categories=Application;
#Categories=Application;Game;
#Categories=Office;
StartupNotify=true
Comment=
Path=
EOF

chmod +x "$desktop_path"

echo -e "\n✅ Ярлык '$title' создан по пути: $Стільниця"
#echo -e "\n✅ Ярлык '$title' создан по пути: $desktop_path"
