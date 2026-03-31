#!/bin/bash
# INFO: [WINE] генератор wine-ярлыка


echo "🔧 Генератор Wine-ярлыка"

# 📁 Куда сохранить
read -p "📂 Куда сохранить ярлык? (оставь пустым для рабочего стола): " custom_dir
if [ -z "$custom_dir" ]; then
  TARGET_DIR="$(xdg-user-dir DESKTOP)"
else
  TARGET_DIR="$custom_dir"
fi

# 📝 Название
read -p "🔹 Название программы: " NAME

# 📦 Префикс
read -p "🔹 Wine-префикс (полный путь): " PREFIX
if [ ! -d "$PREFIX" ]; then
  echo "❌ Префикс не найден: $PREFIX"
  exit 1
fi

# 🧩 Путь к .exe
read -p "🔹 Путь к .exe (Wine-формат или Linux-путь): " EXE
EXE_LINUX=$(WINEPREFIX="$PREFIX" winepath -u "$EXE" 2>/dev/null)
if [ ! -f "$EXE_LINUX" ]; then
  echo "❌ Файл не найден: $EXE_LINUX"
  exit 1
fi

# 🖼️ Иконка
read -p "🔹 Путь к иконке (.ico или .png, можно оставить пустым): " ICON

# 📂 Категория
echo "🔹 Выбери категорию:"
echo "1) Office"
echo "2) Utility"
echo "3) Graphics"
echo "4) Network"
read -p "👉 Введи номер категории: " CAT
case "$CAT" in
  1) CATEGORY="Office";;#Офис
  2) CATEGORY="Utility";;#Система
  3) CATEGORY="Graphics";;#Графика
  4) CATEGORY="Network";;#Сеть, интернет
  5) CATEGORY="Education";;#Разные скрипты
  6) CATEGORY="Utility";;#Инструменты
  *) CATEGORY="menulibre-приложения-wine";;#по умолчанию
esac

# 🧠 Имя файла
filename="${NAME// /_}.desktop"
filepath="$TARGET_DIR/$filename"

# 📄 Создание ярлыка
cat <<EOF > "$filepath"
[Desktop Entry]
Name=$NAME
Exec=env WINEPREFIX=$PREFIX wine "$EXE"
Type=Application
Icon=$ICON
Categories=$CATEGORY;
StartupNotify=true
EOF

chmod +x "$filepath"
echo "✅ Ярлык создан: $filepath"
