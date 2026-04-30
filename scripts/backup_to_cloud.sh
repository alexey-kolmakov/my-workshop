#!/bin/bash
# INFO: [АРХІВ] копирование в https://ua.files.fm


# ЧТО бэкапим (проверь путь к своей папке!)
SOURCE="/home/minok/My_warehouse"

# КУДА бэкапим (filesfm — это имя твоего конфига)
# Мы создадим там папку "MyArchive"
DEST="filesfm:warehouse"

echo "Сверяю файлы... Это может занять время, если файлов много."

# Команда 'copy' допишет только новые/измененные файлы.
# Если хочешь, чтобы в облаке удалялось то, что ты удалил на ПК — используй 'sync'
rclone copy "$SOURCE" "$DEST" --progress
#rclone sync "$SOURCE" "$DEST" --progress

echo "Синхронизация завершена!"/home/minok/My_warehouse
