#!/bin/bash
#ВЫБОРОЧНОЕ СОЗДАНИЕ БЕКАПА
# 📍 Папки для копирования
INCLUDE=(
  "$HOME/scripts"
  "$HOME/Pictures"
  "$HOME/PDF"
  "$HOME/pCloudDrive"
  "$HOME/Obsidian"
  "$HOME/icons"
  "$HOME/bin"
  "$HOME/Чаты"  
  "$HOME/Збережені_MS_Office"
  "$HOME/.local/share/applications"
  )

# ❌ Что исключаем
EXCLUDE=(
  "--exclude=.cache"
  "--exclude=.local/share/Trash"
  "--exclude=.wine"
  "--exclude=Downloads"
)

# 📂 Цель
DEST="/mnt/NTFS_58GB/BACKUP_IMPORTANT"

LOG="$HOME/scripts/smart_backup_log.txt"

echo "📦 Начинаем умное резервное копирование..." | tee -a "$LOG"

# Проверка подключения диска
if [ ! -d "$DEST" ]; then
  echo "❗ Целевая папка '$DEST' не найдена. Возможно, диск не подключен." | tee -a "$LOG"
  exit 1
fi

echo "✅ Диск найден. Копирование начинается..." | tee -a "$LOG"

# Основное копирование с фильтрами
for DIR in "${INCLUDE[@]}"; do
  rsync -avh --delete "${EXCLUDE[@]}" "$DIR" "$DEST" | tee -a "$LOG"
done

# Завершение
if [ $? -eq 0 ]; then
  echo "🟢 Всё сохранено успешно: $(date)" | tee -a "$LOG"
  zenity --info --title="Готово" --text="✅ Всё, что нужно, скопировано!"
else
  echo "🔴 Ошибка при копировании: $(date)" | tee -a "$LOG"
  zenity --error --title="Ошибка" --text="❌ Что-то пошло не так!"
fi

