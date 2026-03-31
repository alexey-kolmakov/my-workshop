#!/bin/bash
# INFO: [СИСТЕМА] конструктор ярликів (виправлений)


# 🎯 Конструктор ярлыков (Исправленный)

if [ -n "$1" ]; then
  target="$1"
else
  read -e -p "📁 Путь к файлу или папке: " target
fi

# Убираем возможные лишние кавычки, если путь вставили как 'path'
target="${target//\'/}"
target="${target//\"/}"

if [ ! -e "$target" ]; then
  echo "❌ Указанный путь не существует: $target"
  exit 1
fi

# Получаем абсолютный путь (важно для ярлыков)
abs_target=$(realpath "$target")
title=$(basename "$target")
location="$(xdg-user-dir DESKTOP)"
mkdir -p "$location"
icon="application-x-executable"

# Логика определения команды запуска
if [[ "$abs_target" == *.exe ]]; then
  exec_cmd="wine \"$abs_target\""
elif [[ "$abs_target" == *.sh ]]; then
  exec_cmd="bash \"$abs_target\""
else
  # Для папок и обычных файлов
  exec_cmd="xdg-open \"$abs_target\""
fi

# Формируем имя файла (заменяем пробелы на подчеркивания)
desktop_file="${title// /_}.desktop"
desktop_path="$location/$desktop_file"

# Записываем файл (используем кавычки вокруг EOF, чтобы не экранировать внутри)
cat <<EOF > "$desktop_path"
[Desktop Entry]
Version=1.0
Type=Application
Name=$title
Comment=Запуск $title
Exec=$exec_cmd
Icon=$icon
Terminal=false
Path=$(dirname "$abs_target")
StartupNotify=true
Categories=Utility;
EOF

chmod +x "$desktop_path"
echo -e "\n✅ Ярлык '$title' создан: $desktop_path"
