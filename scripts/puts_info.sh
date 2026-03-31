#!/bin/bash
# INFO: [СОРТУВАННЯ] Вписуе "INFO" (Запускати там де скрипти)

for file in *.sh; do
# INFO: ТУТ ОПИСАНИЕ
    if ! grep -q "^# INFO:" "$file"; then
        # Вставляем метку на вторую строку файла
        sed -i '2i# INFO:[VENTOY][СИСТЕМА][WINE][АРХІВ][ЗАГАЛЬНЕ][THUNAR][СОРТУВАННЯ] ТУТ ОПИСАНИЕ' "$file"
        echo "Добавлена метка в: $file"
    else
        echo "Пропущено (уже есть): $file"
    fi
done
