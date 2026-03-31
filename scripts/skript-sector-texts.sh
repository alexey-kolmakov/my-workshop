#!/bin/bash
# INFO: [АРХИВ] помічник у розборі документів


# 📚 Скрипт-разбиральщик документального хаоса
# Автор: Олексій & Copilot

echo -e "\n========== 📁 Розбір документів ==========\n"

# 📍 Выбор папки
read -p "📍 Введи путь к папке для разбора (напр. ~/Downloads): " folder
[[ ! -d "$folder" ]] && echo "🚫 Папка не найдена!" && exit 1

# 🔍 Поиск файлов
echo -e "\n🔍 Ищем .doc, .docx и .pdf файлы..."
mapfile -t files < <(find "$folder" -type f \( -iname "*.doc" -o -iname "*.docx" -o -iname "*.pdf" \))

if [[ ${#files[@]} -eq 0 ]]; then
  echo "📭 Файлы не найдены."
  exit 0
fi

while true; do
  # 📋 Показ списка
  echo -e "\n📋 Найдено ${#files[@]} файлов:\n"
  for i in "${!files[@]}"; do
    size=$(du -h "${files[$i]}" | cut -f1)
    mod=$(date -r "${files[$i]}" "+%Y-%m-%d %H:%M")
    echo "$i) ${files[$i]}  [$size, $mod]"
  done

  # 🧙‍♂️ Выбор действия
  echo -e "\n🧙‍♂️ Действия:"
  echo "1. Открыть файл"
  echo "2. Переименовать"
  echo "3. Переместить"
  echo "4. Удалить"
  echo "5. Завершить"

  was_modified=false

  read -p "👉 Введи номер действия: " action
  read -p "📄 Введи номер файла из списка: " index
  file="${files[$index]}"

  case $action in
    1) xdg-open "$file" ;;  # Только просмотр
    2) read -p "✏️ Новое имя (без пути): " newname
       mv "$file" "$(dirname "$file")/$newname"
       file="$(dirname "$file")/$newname"
       was_modified=true ;;
    3) read -p "📦 Куда переместить? Введи путь: " target
       [[ ! -d "$target" ]] && echo "🚫 Папка не найдена!" && continue
       mv "$file" "$target/"
       file="$target/$(basename "$file")"
       was_modified=true ;;
    4) read -p "❗ Удалить файл $file? (yes/no): " confirm
       [[ "$confirm" == "yes" ]] && rm "$file" && echo "🗑️ Удалено."
       was_modified=true ;;
    5) echo "👋 Завершаем разбор." && break ;;
    *) echo "⚠️ Неверный выбор." ;;
  esac

  # 🏷️ Добавляем метку, если файл был изменён и существует
  if [[ "$was_modified" == true && -f "$file" ]]; then
    newname="обработано_$(basename "$file")"
    mv "$file" "$(dirname "$file")/$newname"
    echo "🏷️ Метка добавлена: $newname"
  fi

  echo -e "\n🔁 Возвращаемся к списку...\n"
done

