#!/bin/bash

# 🎯 Ввод адреса сайта
read -rp "🔍 Введите адрес сайта (например, example.com): " site

# 📁 Папка для логов
log_dir="$HOME/site_diagnostics"
mkdir -p "$log_dir"

# 🧼 Очистка имени файла (удаление https://, замена / и спецсимволов)
safe_name=$(echo "$site" | sed 's|https\?://||; s|/|_|g; s|[^a-zA-Z0-9._-]|_|g')
log_file="$log_dir/${safe_name}_$(date +%Y%m%d_%H%M%S).log"

# 🔔 Звуковой сигнал (если доступен)
beep() { command -v paplay &>/dev/null && paplay /usr/share/sounds/freedesktop/stereo/message.oga; }

# 📡 Проверка ping
echo -e "\n🌐 Проверка ping..." | tee -a "$log_file"
ping -c 4 "$site" | tee -a "$log_file"

# ⏱️ Проверка времени загрузки curl
echo -e "\n⏳ Проверка времени загрузки..." | tee -a "$log_file"
curl -o /dev/null -s -w "Время: %{time_total} сек\n" "https://$site" | tee -a "$log_file"

# 🧠 DNS-анализ
echo -e "\n🔎 DNS-записи..." | tee -a "$log_file"
dig "$site" ANY +short | tee -a "$log_file"

# 📦 Проверка размера страницы
echo -e "\n📏 Размер HTML-страницы..." | tee -a "$log_file"
curl -s "https://$site" | wc -c | awk '{print "Размер: "$1" байт"}' | tee -a "$log_file"

# ✅ Завершение
echo -e "\n✅ Диагностика завершена. Лог сохранён в:\n$log_file"
beep

# 📖 Автоматическое открытие лога (если доступно)
if command -v xdg-open &>/dev/null; then
    xdg-open "$log_file"
elif command -v less &>/dev/null; then
    less "$log_file"
else
    echo "📂 Откройте лог вручную: $log_file"
fi
