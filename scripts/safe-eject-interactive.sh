#!/bin/bash
# INFO: [СИСТЕМА]  інтерактивне відключення USB-пристрою


# Інтерактивний ритуал безпечного відключення USB-пристрою

export DISPLAY=:0
LOG="$HOME/safe-eject.log"
echo "=== $(date) ===" >> "$LOG"
echo "Запуск інтерактивного ритуалу" >> "$LOG"

# Знайти знімні пристрої
mapfile -t drives < <(lsblk -o NAME,RM,TYPE,SIZE,MOUNTPOINT | awk '$2 == 1 && $3 == "disk" {print $1}')

if [ ${#drives[@]} -eq 0 ]; then
  zenity --error --text="❌ Немає знімних пристроїв для відключення"
  echo "Немає знімних пристроїв" >> "$LOG"
  exit 1
fi

# Вибір максимального розміру
max_size_gb=$(zenity --entry \
  --title="Фільтр по розміру" \
  --text="Максимальний розмір пристрою (в ГБ):" \
  --entry-text="250")

if [ -z "$max_size_gb" ]; then
  notify-send "Ритуал скасовано" "Розмір не вказано"
  echo "Ритуал скасовано: не вказано розмір" >> "$LOG"
  exit 0
fi

max_size_bytes=$((max_size_gb * 1024 * 1024 * 1024))

# Фільтрація пристроїв
filtered_drives=()
excluded=""
for d in "${drives[@]}"; do
  size_bytes=$(lsblk -dn -b -o SIZE "/dev/$d")
  if [ "$size_bytes" -lt "$max_size_bytes" ]; then
    filtered_drives+=("$d")
  else
    gb=$((size_bytes / 1024 / 1024 / 1024))
    excluded="${excluded}\n📦 /dev/$d — ${gb} ГБ"
    echo "Пропущено: /dev/$d — ${gb} ГБ" >> "$LOG"
  fi
done

if [ -n "$excluded" ]; then
  zenity --warning --text="⚠️ Пропущені великі пристрої:${excluded}" --timeout=6
fi

if [ ${#filtered_drives[@]} -eq 0 ]; then
  zenity --error --text="❌ Немає пристроїв, що відповідають фільтру"
  echo "Немає пристроїв після фільтрації" >> "$LOG"
  exit 1
fi

# Підготовка списку для вибору
choices=()
for d in "${filtered_drives[@]}"; do
  size=$(lsblk -dn -o SIZE "/dev/$d")
  label=$(lsblk -dn -o LABEL "/dev/${d}1" 2>/dev/null)
  desc="${d} (${size})"
  [ -n "$label" ] && desc="$desc — $label"
  choices+=("$desc")
done

# Вибір пристрою
selected=$(zenity --list \
  --title="Отключение USB" \
  --text="Вибери пристрій для безпечного відключення:" \
  --column="Пристрій" "${choices[@]}")

if [ -z "$selected" ]; then
  notify-send "Ритуал скасовано" "Нічого не вибрано"
  echo "Ритуал скасовано користувачем" >> "$LOG"
  exit 0
fi

# Витягти ім’я пристрою
devname=$(echo "$selected" | awk '{print $1}')
echo "Вибрано: $devname" >> "$LOG"

# Знайти всі розділи
mapfile -t parts < <(lsblk -ln -o NAME "/dev/$devname" | grep -v "^$devname$")

# Відмонтування розділів
for p in "${parts[@]}"; do
  echo "Відмонтування /dev/$p..." >> "$LOG"
  udisksctl unmount -b "/dev/$p" && \
  echo "/dev/$p успішно відмонтовано" >> "$LOG" || \
  echo "Помилка при відмонтованні /dev/$p" >> "$LOG"
done

# Вимкнення живлення
if udisksctl power-off -b "/dev/${parts[0]}"; then
  zenity --info --text="✅ Пристрій відключено\nМожна безпечно витягти флешку" --timeout=5
  paplay /usr/share/sounds/freedesktop/stereo/complete.oga
  echo "Живлення успішно вимкнено" >> "$LOG"
else
  zenity --error --text="⚠️ Не вдалося вимкнути живлення"
  echo "Помилка при вимкненні живлення" >> "$LOG"
fi

echo "Ритуал завершено" >> "$LOG"
