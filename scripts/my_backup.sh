#!/bin/bash
# INFO: [СИСТЕМА] Створює backup папки у pCloud

# Магия для работы уведомлений в Cron
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
# 1. ПУТИ (Проверь каждую букву!)
SOURCE="/home/minok/pCloud_Local/copy"
DEST="/home/minok/pCloudDrive/MyBackup"
LOG="/home/minok/pCloud_Local/backup_log.txt"

# 2. ПРОВЕРКА И СОЗДАНИЕ ПАПОК
# Создаем локальную папку, если её вдруг нет
mkdir -p "$SOURCE"

# 3. ОСНОВНОЙ ЦИКЛ
if [ -d "/home/minok/pCloudDrive" ]; then
    # Создаем папку в облаке, если она еще не появилась
    mkdir -p "$DEST"
    
    echo "$(date): Погнали! Копирую из $SOURCE в $DEST" >> "$LOG"
    
    # Копируем (без --delete, как договаривались)
    rsync -av "$SOURCE/" "$DEST/" >> "$LOG" 2>&1
    
    # Копируем файлы
    rsync -av "$SOURCE/" "$DEST/" >> "$LOG" 2>&1
    
    echo "$(date): Готово. Всё в сейфе." >> "$LOG"

    # ОТПРАВЛЯЕМ УВЕДОМЛЕНИЕ НА ЭКРАН
    # -i - добавляет иконку (информационный значок)
    # -t 5000 - сообщение само исчезнет через 5 секунд
    notify-send -i folder-remote "Бэкап pCloud" "Синхронизация завершена успешно!" -t 5000
else
    # Если диск pCloud не найден
    echo "$(date): Ошибка! Диск не найден." >> "$LOG"
    notify-send -i error "Ошибка бэкапа" "pCloudDrive не найден. Проверь подключение!"
fi
