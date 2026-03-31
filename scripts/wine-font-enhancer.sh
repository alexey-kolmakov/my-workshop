#!/bin/bash
# INFO: [WINE] встановлення шрифтів у кожен префікс

# Папка с основными шрифтами
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
echo "📐 Выберите масштаб интерфейса (DPI):"
echo "1) 96 DPI (по умолчанию)"
echo "2) 120 DPI (рекомендуется)"
echo "3) 144 DPI (максимальный)"

read -p "➡️ Ваш выбор [1/2/3]: " dpi_choice
case "$dpi_choice" in
  2) LOGPIXELS=120 ;;
  3) LOGPIXELS=144 ;;
  *) LOGPIXELS=96 ;;
esac

echo ""
echo "📁 Копирование шрифтов и настройка визуала..."
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

  # Копируем альтернативные шрифты
  for family in liberation dejavu; do
    SRC="/usr/share/fonts/truetype/$family"
    [ -d "$SRC" ] && cp -u "$SRC"/*.ttf "$DEST"
  done

  # Включаем сглаживание и DPI
  WINEPREFIX="$PREFIX" wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f
  WINEPREFIX="$PREFIX" wine reg add "HKCU\\Control Panel\\Desktop" /v LogPixels /t REG_DWORD /d "$LOGPIXELS" /f

  # Добавляем gdiplus как native
  WINEPREFIX="$PREFIX" winecfg -v gdiplus=native
done

echo ""
echo "🔄 Обновление кэша шрифтов..."
fc-cache -fv

echo ""
echo "🎉 Готово! Шрифты и визуальные параметры применены."
echo "💡 Запусти winecfg или нужное приложение, чтобы оценить результат."
