#!/bin/bash
# INFO: [СИСТЕМА] техосмотр системы Linux через Zenity

# 🖥️ system-checkup-gui.sh — графический техосмотр системы Linux через Zenity
# с выбором сохранения лога

LOG="/tmp/system_checkup.log"
> "$LOG"

(
echo "10" ; echo "# Проверка свободного места..."
df -h | grep -E '^/|Filesystem' >> "$LOG"

echo "20" ; echo "# Очистка системного мусора..."
sudo apt clean -y >> "$LOG" 2>&1
sudo apt autoremove --purge -y >> "$LOG" 2>&1

if command -v journalctl &>/dev/null; then
  echo "30" ; echo "# Очистка старых логов..."
  sudo journalctl --vacuum-time=5d >> "$LOG" 2>&1
fi

echo "40" ; echo "# Обновление списка пакетов..."
sudo apt update >> "$LOG" 2>&1

echo "50" ; echo "# Исправление поломанных пакетов..."
sudo apt -f install -y >> "$LOG" 2>&1

echo "60" ; echo "# Проверка обновлений ядра..."
sudo apt list --upgradable 2>/dev/null | grep linux-image >> "$LOG" || echo "Обновлений ядра нет." >> "$LOG"

echo "70" ; echo "# Проверка SMART-диска..."
if command -v smartctl &>/dev/null; then
  DISK=$(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print "/dev/"$1; exit}')
  if [ -n "$DISK" ]; then
    sudo smartctl -H "$DISK" >> "$LOG" 2>&1
  else
    echo "❗ Диск не найден." >> "$LOG"
  fi
else
  echo "❗ smartctl не установлен (пакет smartmontools)." >> "$LOG"
fi

echo "80" ; echo "# Проверка температуры..."
if command -v sensors &>/dev/null; then
  sensors | grep -E 'temp1|CPU|Core' >> "$LOG"
else
  echo "❗ sensors не установлен (пакет lm-sensors)." >> "$LOG"
fi

echo "90" ; echo "# Перезапуск Thunar (если запущен)..."
if pgrep -x "thunar" >/dev/null; then
  thunar -q
  rm -rf ~/.cache/Thunar
  nohup thunar >/dev/null 2>&1 &
  echo "✅ Thunar перезапущен." >> "$LOG"
fi

echo "100" ; echo "# Завершено!"
sleep 1
) |
zenity --progress \
  --title="🔧 Проверка системы" \
  --text="Подождите, идёт техосмотр..." \
  --percentage=0 \
  --auto-close

# После проверки — спрашиваем, сохранять лог или нет
CHOICE=$(zenity --list \
  --title="💾 Сохранение лога" \
  --text="Хотите сохранить отчет проверки системы?" \
  --column="Выбор" "Сохранить" "Не сохранять" \
  --height=200 --width=400)

if [ "$CHOICE" = "Сохранить" ]; then
    FILE=$(zenity --file-selection --save --confirm-overwrite \
      --title="Выберите место для сохранения лога" \
      --filename="$HOME/system_checkup.log")
    if [ -n "$FILE" ]; then
        cp "$LOG" "$FILE"
        zenity --info --title="✅ Готово" --text="Лог сохранён в:\n$FILE"
    fi
else
    zenity --info --title="ℹ️ Пропущено" --text="Лог не сохранён"
fi
