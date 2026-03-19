#!/bin/bash

# Файл со списком скриптов
LIST_FILE="files.txt"

echo "------------------------------------------"
echo " ДОСТУПНЫЕ СКРИПТЫ:"
echo "------------------------------------------"

# Массив для хранения только имен файлов
declare -a file_names
count=1

# Читаем files.txt построчно
while IFS='|' read -r filename description; do
    # Убираем лишние пробелы (trim)
    filename=$(echo $filename | xargs)
    description=$(echo $description | xargs)
    
    # Сохраняем имя в массив
    file_names[$count]=$filename
    
    # Выводим пользователю номер, имя и описание
    printf "%2d) %-15s — %s\n" "$count" "$filename" "$description"
    
    ((count++))
done < "$LIST_FILE"

echo "------------------------------------------"
read -p "Введите номер нужного скрипта: " choice

# Проверка выбора
if [[ -n "${file_names[$choice]}" ]]; then
    selected_file="${file_names[$choice]}"
    echo "Вы выбрали: $selected_file. Запускаю..."
    
    # Здесь команда запуска. Если скрипты на GitHub, 
    # тут будет твой curl или bash.
    bash "$selected_file"
else
    echo "Ошибка: Скрипта под таким номером нет."
fi
