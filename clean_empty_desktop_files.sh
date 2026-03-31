#!/bin/bash
# INFO: [СИСТЕМА] пошук порожніх desktop-файлів

# 🧾 Лог-файл
LOG="$HOME/empty_desktop_files.log"
> "$LOG"

echo "🔍 Поиск пустых .desktop-файлов..."
echo "📁 Проверяем: /usr/share/applications и ~/.local/share/applications"

# 🔎 Поиск пустых файлов
find /usr/share/applications ~/.local/share/applications \
  -type f -name "*.desktop" -size 0 \
  -print | tee -a "$LOG"

COUNT=$(wc -l < "$LOG")

if [[ "$COUNT" -eq 0 ]]; then
  notify-send "Очистка .desktop" "✅ Пустых файлов не найдено"
  echo "✅ Пустых .desktop-файлов не найдено."
  exit 0
fi

echo -e "\n⚠️ Найдено $COUNT пустых .desktop-файлов. Список сохранён в: $LOG"
read -p "🗑 Переместить их в корзину? [y/N] " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "🚮 Перемещаем в корзину..."
  while IFS= read -r file; do
    gio trash "$file" && echo "🗂 В корзину: $file" || echo "❌ Ошибка: $file"
  done < "$LOG"
  notify-send "Очистка .desktop" "🗑 $COUNT файлов перемещено в корзину"
  echo "✅ Готово. Файлы можно восстановить через корзину XFCE."
else
  notify-send "Очистка .desktop" "🚫 Операция отменена"
  echo "🚫 Операция отменена. Файлы остались на месте."
fi

# Поиск пустых .desktop-файлов
