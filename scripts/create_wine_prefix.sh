#!/bin/bash
# INFO: [WINE] створення нового wine-префіксу


echo "📦 Создание нового Wine-префикса"

# 🔍 Проверка наличия winecfg
if ! command -v winecfg &> /dev/null; then
  zenity --error --text="❌ winecfg не найден. Убедитесь, что Wine установлен."
  exit 1
fi

# 📝 Запрос имени префикса
read -p "📝 Введите имя нового префикса (например, photoshop, excel): " PREFIX_NAME
PREFIX_PATH="$HOME/prefixes/$PREFIX_NAME"
mkdir -p "$HOME/prefixes"

# 🛡️ Защита от системных путей
if [[ "$PREFIX_PATH" == /tmp/* || "$PREFIX_PATH" == /var/* || "$PREFIX_PATH" == /etc/* || "$PREFIX_PATH" == /usr/* ]]; then
  zenity --error --text="🚫 Нельзя использовать системные каталоги для Wine-префикса:\n$PREFIX_PATH"
  exit 1
fi

# 🏗️ Выбор архитектуры
read -p "🏗️ Выберите архитектуру (32 или 64): " ARCH
if [[ "$ARCH" == "32" ]]; then
  WINEARCH="win32"
elif [[ "$ARCH" == "64" ]]; then
  WINEARCH="win64"
else
  zenity --error --text="❌ Неверный выбор архитектуры. Используйте 32 или 64."
  exit 1
fi

# 📦 Проверка существования префикса
if [ -d "$PREFIX_PATH" ]; then
  zenity --question --title="Префикс уже существует" \
    --text="⚠️ Префикс уже существует:\n$PREFIX_PATH\n\nАрхивировать и перезаписать?"
  if [[ $? -ne 0 ]]; then
    echo "🚫 Отмена."
    exit 0
  fi

  # 📁 Архивирование
  ARCHIVE="$HOME/wine_archives/${PREFIX_NAME}_$(date +%Y%m%d_%H%M%S).tar.gz"
  mkdir -p "$HOME/wine_archives"
  tar -czf "$ARCHIVE" "$PREFIX_PATH"
  zenity --info --text="📦 Префикс архивирован:\n$ARCHIVE"

  # 🧹 Удаление
  rm -rf "$PREFIX_PATH"
fi

# ⏳ Прогресс создания
(
  echo "10"; sleep 1
  echo "# Инициализация префикса..."; echo "40"; sleep 1
  echo "# Запуск winecfg..."; echo "70"; sleep 1
  echo "# Завершение..."; echo "100"; sleep 1
) | zenity --progress \
  --title="Создание префикса $PREFIX_NAME" \
  --text="⏳ Пожалуйста, подождите..." \
  --percentage=0 \
  --auto-close

# 🚀 Создание префикса
WINEARCH=$WINEARCH WINEPREFIX=$PREFIX_PATH winecfg

# ✅ Подтверждение
if [ $? -eq 0 ]; then
  zenity --info --title="Префикс создан" \
    --window-icon="info" \
    --text="🎉 Префикс <b>$PREFIX_NAME</b> успешно создан в:\n$PREFIX_PATH"
 # paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null
#else
  #zenity --error --text="❌ Ошибка при создании префикса."
fi
