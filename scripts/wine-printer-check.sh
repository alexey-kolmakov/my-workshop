#!/bin/bash

# === Настройки ===
WINEPREFIX="/home/minok/prefixes/MS_Office"
WINECMD="wine"

echo "🔍 Проверка CUPS..."
if systemctl is-active --quiet cups; then
  echo "✅ CUPS работает"
else
  echo "⚠️ CUPS не запущен. Запускаю..."
  sudo systemctl start cups
fi

echo "🔍 Проверка libcups2:i386..."
if dpkg -l | grep -q libcups2.*:i386; then
  echo "✅ libcups2:i386 установлен"
else
  echo "⚠️ libcups2:i386 не найден. Устанавливаю..."
  sudo apt install -y libcups2:i386
fi

echo "🔄 Обновление конфигурации Wine-префикса..."
WINEPREFIX="$WINEPREFIX" $WINECMD winecfg &>/dev/null

echo "🖨️ Проверка принтеров через Notepad..."
WINEPREFIX="$WINEPREFIX" $WINECMD notepad &

sleep 2
echo "✅ Если Notepad видит принтер — Word тоже сможет печатать!"
