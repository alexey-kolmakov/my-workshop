#!/bin/bash

# INFO: [СИСТЕМА] Универсальный конструктор ярлыков MiniOS Edition
# Поддержка: drag’n’drop, AppImage, автопоиск иконок, категории, меню XFCE


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
menu_dir="$HOME/.local/share/applications"
icon_dir="$HOME/.local/share/icons"

mkdir -p "$menu_dir"
mkdir -p "$icon_dir"

# 2. Определение MIME-типа
mime_type=$(xdg-mime query filetype "$abs_target")

# 3. Автопоиск иконки (для обычных файлов)
icon_guess=$(grep -Rsl "$mime_type" /usr/share/icons/hicolor/*/mimetypes 2>/dev/null | head -n 1)

# 4. Обработка AppImage
if [[ "$abs_target" == *.AppImage ]]; then
  chmod +x "$abs_target"

  # Извлечение иконки
  tmpdir=$(mktemp -d)
  "$abs_target" --appimage-extract "*.png" &>/dev/null

  extracted_icon=$(find squashfs-root -name "*.png" | head -n 1)

  if [ -n "$extracted_icon" ]; then
    cp "$extracted_icon" "$icon_dir/"
    icon="$icon_dir/$(basename "$extracted_icon")"
  else
    icon="application-x-executable"
  fi

  rm -rf squashfs-root "$tmpdir"

else
  # Если не AppImage — используем найденную иконку
  if [ -n "$icon_guess" ]; then
    cp "$icon_guess" "$icon_dir/"
    icon="$icon_dir/$(basename "$icon_guess")"
  else
    icon="application-x-executable"
  fi
fi

# 5. Выбор категории
category=$(zenity --list \
  --title="Категория ярлыка" \
  --text="Выберите категорию для '$title'" \
  --column="Категория" \
  Internet Utility System Graphics AudioVideo Office Development \
  2>/dev/null)

if [ -z "$category" ]; then
  category="Utility"
fi

# 6. Терминал
if zenity --question --title="Терминал" --text="Запускать '$title' в терминале?" --no-wrap 2>/dev/null; then
  terminal_mode="true"
else
  terminal_mode="false"
fi

# 7. Логика Exec
if [[ "$abs_target" == *.exe ]]; then
  exec_cmd="wine $abs_target"
elif [[ "$abs_target" == *.sh ]]; then
  exec_cmd="bash $abs_target"
elif [[ "$abs_target" == *.AppImage ]]; then
  exec_cmd="$abs_target"
else
  exec_cmd="xdg-open $abs_target"
fi

# 8. Создание .desktop
desktop_file="${title// /_}.desktop"
desktop_path="$menu_dir/$desktop_file"

cat <<EOF > "$desktop_path"
[Desktop Entry]
Version=1.0
Type=Application
Name=$title
Exec=$exec_cmd
Icon=$icon
Terminal=$terminal_mode
StartupNotify=true
Categories=$category;
Path=$(dirname "$abs_target")
EOF

chmod +x "$desktop_path"

echo -e "\n✅ Готово! Ярлык создан в меню: $desktop_path"
