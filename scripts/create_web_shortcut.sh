#!/bin/bash
# INFO: [СИСТЕМА] створення ярлика для сайту


TARGET_DIR="$(xdg-user-dir DESKTOP)"
#TARGET_DIR="$HOME/Мои_ярлыки"

echo "🔹 Введите название ярлыка:"
read name

echo "🔹 Введите ссылку на сайт (например, https://example.com):"
read url

echo "🔹 Введите команду браузера (например, firefox, google-chrome, brave-browser):"
read browser
echo "🔹 Куда сохранить ярлык? (оставь пустым для рабочего стола)"
read custom_dir

if [ -z "$custom_dir" ]; then
  TARGET_DIR="$(xdg-user-dir DESKTOP)"
else
  TARGET_DIR="$custom_dir"
fi

# Удалим пробелы и спецсимволы из имени файла
filename="$(echo "$name" | tr -cd '[:alnum:]_-').desktop"

cat <<EOF > "$TARGET_DIR/$filename"
[Desktop Entry]
Name=$name
Exec=$browser $url
Icon=web-browser
Type=Application
Terminal=false
Categories=
EOF

chmod +x "$TARGET_DIR/$filename"
echo "✅ Ярлык создан: $TARGET_DIR/$filename"
