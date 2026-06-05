#!/bin/bash

# INFO: [СИСТЕМА] Универсальный конструктор ярлыков MiniOS Edition
# Поддержка: AppImage (встроенный .desktop), иконки, категории, меню XFCE

# 1. Получение цели
if [ -n "$1" ]; then
  target="$1"
else
  read -e -p "📁 Путь к файлу или папке: " target
fi

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

# 3. Если AppImage — извлекаем встроенный desktop и иконку
if [[ "$abs_target" == *.AppImage ]]; then
  chmod +x "$abs_target"

  tmpdir=$(mktemp -d)
  (cd "$tmpdir" && "$abs_target" --appimage-extract &>/dev/null)

  # Ищем встроенный .desktop
  embedded_desktop=$(find "$tmpdir/squashfs-root" -name "*.desktop" | head -n 1)

  if [ -n "$embedded_desktop" ]; then
    # Копируем desktop в память
    desktop_content=$(cat "$embedded_desktop")

    # Исправляем Exec= на реальный путь
    desktop_content=$(echo "$desktop_content" | sed "s|Exec=.*|Exec=$abs_target|")

    # Ищем иконку
    embedded_icon=$(find "$tmpdir/squashfs-root" -name "*.png" | head -n 1)

    if [ -n "$embedded_icon" ]; then
      cp "$embedded_icon" "$icon_dir/"
      icon="$icon_dir/$(basename "$embedded_icon")"
      desktop_content=$(echo "$desktop_content" | sed "s|Icon=.*|Icon=$icon|")
    else
      icon="application-x-executable"
      desktop_content=$(echo "$desktop_content" | sed "s|Icon=.*|Icon=$icon|")
    fi

    # Категория (если нет)
    if ! echo "$desktop_content" | grep -q "Categories="; then
      category=$(zenity --list \
        --title="Категория" \
        --text="Выберите категорию для '$title'" \
        --column="Категория" \
        Internet Utility System Graphics AudioVideo Office Development \
        2>/dev/null)

      [ -z "$category" ] && category="Utility"
      desktop_content="$desktop_content"$'\n'"Categories=$category;"
    fi

    # Терминал
    if zenity --question --title="Терминал" --text="Запускать '$title' в терминале?" --no-wrap 2>/dev/null; then
      desktop_content="$desktop_content"$'\n'"Terminal=true"
    else
      desktop_content="$desktop_content"$'\n'"Terminal=false"
    fi

    # Сохраняем ярлык
    desktop_path="$menu_dir/${title// /_}.desktop"
    echo "$desktop_content" > "$desktop_path"
    chmod +x "$desktop_path"

    rm -rf "$tmpdir"

    echo -e "\n✅ Ярлык создан из встроенного .desktop: $desktop_path"
    exit 0
  fi

  rm -rf "$tmpdir"
fi

# 4. Если НЕ AppImage — обычная логика (автопоиск иконки)
icon_guess=$(grep -Rsl "$mime_type" /usr/share/icons/hicolor/*/mimetypes 2>/dev/null | head -n 1)

if [ -n "$icon_guess" ]; then
  cp "$icon_guess" "$icon_dir/"
  icon="$icon_dir/$(basename "$icon_guess")"
else
  icon="application-x-executable"
fi

# 5. Категория
category=$(zenity --list \
  --title="Категория" \
  --text="Выберите категорию для '$title'" \
  --column="Категория" \
  Internet Utility System Graphics AudioVideo Office Development \
  2>/dev/null)

[ -z "$category" ] && category="Utility"

# 6. Терминал
if zenity --question --title="Терминал" --text="Запускать '$title' в терминале?" --no-wrap 2>/dev/null; then
  terminal_mode="true"
else
  terminal_mode="false"
fi

# 7. Exec
if [[ "$abs_target" == *.exe ]]; then
  exec_cmd="wine $abs_target"
elif [[ "$abs_target" == *.sh ]]; then
  exec_cmd="bash $abs_target"
else
  exec_cmd="xdg-open $abs_target"
fi

# 8. Создание .desktop
desktop_path="$menu_dir/${title// /_}.desktop"

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

echo -e "\n✅ Ярлык создан: $desktop_path"
