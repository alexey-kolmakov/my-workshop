#!/bin/bash
# INFO:[WINE] установка шрифтов в $HOME/prefixes/


#Устанавливает шрифты в разные префиксы wine
# Папка со шрифтами
FONT_SOURCE="/usr/share/fonts/truetype/msttcorefonts"
FONT_DEST_RELATIVE="drive_c/windows/Fonts"
REQUIRED_MB=50

echo "🔍 Проверка наличия corefonts..."
if [ ! -d "$FONT_SOURCE" ]; then
  echo "⚠️ Шрифты corefonts не найдены. Устанавливаю..."
  sudo apt update
  sudo apt install -y ttf-mscorefonts-installer
else
  echo "✅ Шрифты уже установлены."
fi

echo ""
echo "📦 Поиск Wine-префиксов в $HOME/prefixes/..."
declare -A PREFIXES
for dir in "$HOME/prefixes"/*; do
  [ -d "$dir" ] && name=$(basename "$dir") && PREFIXES["$name"]="$dir"
done

echo ""
echo "📋 Выберите Wine-префиксы для установки шрифтов:"
SELECTED=()

for name in "${!PREFIXES[@]}"; do
  read -p "➡️ Установить шрифты в '$name'? [y/n]: " answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    SELECTED+=("$name")
  fi
done

echo ""
echo "📁 Копирование шрифтов..."
for name in "${SELECTED[@]}"; do
  PREFIX="${PREFIXES[$name]}"
  DEST="$PREFIX/$FONT_DEST_RELATIVE"
  BASE_DIR=$(dirname "$DEST")
  AVAILABLE_MB=$(df --output=avail "$BASE_DIR" | tail -1)
  AVAILABLE_MB=$((AVAILABLE_MB / 1024))

  if [ "$AVAILABLE_MB" -lt "$REQUIRED_MB" ]; then
    echo "❌ Недостаточно места в $BASE_DIR: нужно $REQUIRED_MB МБ, доступно $AVAILABLE_MB МБ. Пропускаю '$name'."
    continue
  fi

  echo "➡️ Обрабатываю: $name → $DEST"
  mkdir -p "$DEST"
  cp -u "$FONT_SOURCE"/*.ttf "$DEST"
done

echo ""
echo "🔄 Обновление кэша шрифтов..."
fc-cache -fv

echo ""
echo "🎉 Готово! Шрифты скопированы в выбранные Wine-префиксы."
echo "💡 Запусти winecfg для проверки отображения, если хочешь."
