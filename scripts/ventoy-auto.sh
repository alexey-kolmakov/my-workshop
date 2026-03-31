#!/bin/bash
# INFO: [VENTOY] автоформатування ventoy


### === НАСТРОЙКИ ===
VENTOY_DIR="/home/minok/.local/Local_bin_du/Ventoy"
VENTOY_SCRIPT="$VENTOY_DIR/Ventoy2Disk.sh"
SIZE_LIMIT_GB=250

### === ПРОВЕРКА НАЛИЧИЯ VENTOY ===
if [ ! -f "$VENTOY_SCRIPT" ]; then
    echo "Ошибка: Ventoy2Disk.sh не найден по пути:"
    echo "  $VENTOY_SCRIPT"
    exit 1
fi

### === ПОИСК ПОДХОДЯЩЕЙ ФЛЕШКИ ===
echo ">>> Ищем флешку (RM=1, TYPE=disk, SIZE < ${SIZE_LIMIT_GB}G)..."

USB_DEV=$(lsblk -nrpo NAME,RM,TYPE,SIZE | \
    awk -v limit="$SIZE_LIMIT_GB" '
        $2==1 && $3=="disk" {
            # Преобразуем SIZE в гигабайты
            size=$4
            sub(/G$/, "", size)
            if (size < limit) print $1
        }
    ')

if [ -z "$USB_DEV" ]; then
    echo "Ошибка: подходящая флешка не найдена."
    exit 1
fi

### === ИНФОРМАЦИЯ О НАЙДЕННОМ УСТРОЙСТВЕ ===
MODEL=$(lsblk -no MODEL "$USB_DEV")
SIZE=$(lsblk -no SIZE "$USB_DEV")

echo ">>> Найдено устройство:"
echo "    Устройство: $USB_DEV"
echo "    Модель:     $MODEL"
echo "    Размер:     $SIZE"

### === ПОДТВЕРЖДЕНИЕ ===
read -p "Продолжить очистку и установку Ventoy на $USB_DEV? (yes/no): " ans
if [ "$ans" != "yes" ]; then
    echo "Отменено."
    exit 0
fi

### === РАЗМОНТИРОВАНИЕ ===
echo ">>> Размонтируем все разделы..."
for part in $(lsblk -nrpo NAME "$USB_DEV" | tail -n +2); do
    sudo umount -l "$part" 2>/dev/null
done

### === ОЧИСТКА НАЧАЛА ===
echo ">>> Стираем первые 10 МБ..."
sudo dd if=/dev/zero of="$USB_DEV" bs=1M count=10 status=progress

### === ОЧИСТКА СИГНАТУР ===
echo ">>> Удаляем файловые сигнатуры..."
sudo wipefs -a "$USB_DEV"

### === СОЗДАНИЕ GPT ===
echo ">>> Создаём новую GPT..."
sudo parted "$USB_DEV" mklabel gpt -s

### === УСТАНОВКА VENTOY ===
echo ">>> Устанавливаем Ventoy..."
cd "$VENTOY_DIR"
sudo bash "$VENTOY_SCRIPT" -i "$USB_DEV"

echo ">>> Готово!"
echo "Флешка полностью подготовлена и Ventoy установлен."
