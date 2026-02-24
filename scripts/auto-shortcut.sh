#!/bin/bash

# 🎯 Конструктор ярлыков с поддержкой drag’n’drop

# Проверка аргумента
if [ -n "$1" ]; then
  target="$1"
else
  read -e -p "📁 Путь к файлу или папке: " target
fi

# Проверка существования файла/папки
if [ ! -e "$target" ]; then
  echo "❌ Указанный путь не существует: $target"
  exit 1
fi

# Название ярлыка
title=$(basename "$target")

# Папка рабочего стола (универсально)
location="$(xdg-user-dir DESKTOP)"
mkdir -p "$location"

# Иконка по умолчанию
icon="application-x-executable"

# Команда запуска
if [[ "$target" == *.exe ]]; then
  exec_cmd="wine $target"
elif [[ "$target" == *.sh ]]; then
  exec_cmd="bash $target"
elif [[ -d "$target" ]]; then
  exec_cmd="xdg-open $target"
else
  exec_cmd="xdg-open $target"
fi

# Путь к .desktop-файлу
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
Categories=Utility;
StartupNotify=true
EOF

chmod +x "$desktop_path"

echo -e "\n✅ Ярлык '$title' создан по пути: $desktop_path"

