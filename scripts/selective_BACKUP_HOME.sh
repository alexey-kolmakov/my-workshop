#!/bin/bash
# 📦 Умное резервное копирование

# 📂 Целевая папка и лог
BASE_DEST="/mnt/NDD/BACKUP_HOME"
DATE=$(date +"%Y-%m-%d")
DEST="$BASE_DEST/$DATE"
LOG="$HOME/scripts/smart_backup_log.txt"
ERROR=0

# 📍 Папки для резервного копирования
INCLUDE=(
  "$HOME/.local/share/applications"
  "$HOME/Збережені_MS_Office"
  "$HOME/Чаты"
  "$HOME/bin"
  "$HOME/icons"
  "$HOME/scripts"
  "$HOME/PDF"
)

# ❌ Исключения для rsync
EXCLUDE=(
  "--exclude=.cache"
  "--exclude=.local/share/Trash"
  "--exclude=Downloads"
)

# 🍷 Wine-префиксы для архивации
WINE_PREFIXES=(
  "$HOME/wine/WinRAR"
  "$HOME/wine/tcmd"
  "$HOME/wine/Seamonkey"
  "$HOME/wine/MS_Office"
)

# 📡 Проверка подключения диска
echo "📦 Начинаем умное резервное копирование..." | tee -a "$LOG"
echo "📅 Дата: $DATE" | tee -a "$LOG"
echo "👤 Текущий HOME: $HOME" | tee -a "$LOG"
echo "🎯 Целевая папка: $DEST" | tee -a "$LOG"

if [ ! -d "$BASE_DEST" ]; then
  echo "❗ Базовая папка '$BASE_DEST' не найдена. Возможно, диск не подключен." | tee -a "$LOG"
  zenity --error --title="Ошибка" --text="❌ Диск не подключен или путь неверен."
  exit 1
fi

mkdir -p "$DEST"

echo "✅ Диск найден. Копирование начинается..." | tee -a "$LOG"

# 📁 Копируем основные папки
for DIR in "${INCLUDE[@]}"; do
  if [ -d "$DIR" ]; then
    echo "📂 Копируем: $DIR" | tee -a "$LOG"
    rsync -avh --delete "${EXCLUDE[@]}" "$DIR" "$DEST" | tee -a "$LOG" || ERROR=1
  else
    echo "📁 Папка $DIR не найдена, пропускаем." | tee -a "$LOG"
  fi
done

# 🍷 Архивируем Wine-префиксы
for PREFIX in "${WINE_PREFIXES[@]}"; do
  NAME=$(basename "$PREFIX")
  if [ -d "$PREFIX" ]; then
    echo "📦 Архивируем Wine-префикс: $NAME" | tee -a "$LOG"
    tar -czf "$DEST/${NAME}_backup.tar.gz" "$PREFIX" | tee -a "$LOG" || ERROR=1
  else
    echo "🍷 Wine-префикс $NAME не найден, пропускаем." | tee -a "$LOG"
  fi
done

# ✅ Завершение
if [ "$ERROR" -eq 0 ]; then
  echo "🟢 Всё сохранено успешно: $(date)" | tee -a "$LOG"
  zenity --info --title="Готово" --text="✅ Всё, что нужно, скопировано!"
else
  echo "🔴 Ошибка при копировании: $(date)" | tee -a "$LOG"
  zenity --error --title="Ошибка" --text="❌ Что-то пошло не так!"
fi
