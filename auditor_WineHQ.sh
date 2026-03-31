#!/bin/bash
# INFO: [WINE] студійний ревізор WineHQ


LOG="$HOME/winehq_repo_debug.log"
KEYRING="/etc/apt/keyrings/winehq-archive.key"
REPO_URL="https://dl.winehq.org/wine-builds/ubuntu/"
REPO_DIST="noble"
REPO_COMPONENT="main"
REPO_FILE="/etc/apt/sources.list.d/additional-repositories.list"
SIGNED="signed-by=$KEYRING"
FULL_LINE="deb [$SIGNED] $REPO_URL $REPO_DIST $REPO_COMPONENT"

# 📋 Лог запуску
{
  echo "=== Запуск скрипта ==="
  echo "Дата: $(date)"
  echo "USER: $USER"
  echo "DISPLAY: $DISPLAY"
  echo "PATH: $PATH"
  echo "Цільовий рядок: $FULL_LINE"
} >> "$LOG"

echo "🔧 Перевірка ключа WineHQ…"

# 🔑 Створення ключа, якщо його ще немає
if [ ! -f "$KEYRING" ]; then
  echo "⏳ Завантаження ключа WineHQ…"
  sudo mkdir -p "$(dirname "$KEYRING")"
  sudo wget -O "$KEYRING" https://dl.winehq.org/wine-builds/winehq.key
  echo "✅ Ключ збережено: $KEYRING"
else
  echo "✅ Ключ вже існує: $KEYRING"
fi

# 📦 Перевірка, чи запис вже існує
if grep -Fxq "$FULL_LINE" "$REPO_FILE"; then
  echo "✅ Репозиторій вже налаштований."
else
  echo "⚙️ Додаємо WineHQ-репозиторій…"
  sudo sed -i "\|$REPO_URL|d" "$REPO_FILE"
  echo "$FULL_LINE" | sudo tee -a "$REPO_FILE" >> "$LOG"
  echo "✅ Репозиторій додано."
fi

# 🔄 Оновлення списку пакетів
echo "🔄 Оновлення apt…"
sudo apt update >> "$LOG" 2>&1

# 🔔 Графічне повідомлення (якщо є DISPLAY)
if [ -n "$DISPLAY" ] && command -v notify-send >/dev/null; then
  notify-send "WineHQ" "Репозиторій успішно оновлено!"
fi

# 🔊 Звуковий сигнал (якщо доступний)
if command -v paplay >/dev/null && [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
  paplay /usr/share/sounds/freedesktop/stereo/complete.oga
fi

echo "✅ Скрипт завершено успішно."
