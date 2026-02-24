#!/bin/bash

# Папка мастерской-исходников
SRC="$HOME/my-workshop"

# Выбираем файл через графику
FILE=$(zenity --file-selection --title="Выберите файл для загрузки на GitHub")

if [[ -z "$FILE" ]]; then
    zenity --warning --text="Файл не выбран"
    exit 1
fi

# Копируем файл в scripts/
cp "$FILE" "$SRC/scripts/"
BASENAME=$(basename "$FILE")

# Делаем исполняемым
chmod +x "$SRC/scripts/$BASENAME"

cd "$SRC"

# Добавляем в Git
git add "scripts/$BASENAME"
git commit -m "Добавлен модуль $BASENAME"
git push

zenity --info --text="Файл $BASENAME загружен на GitHub!"
