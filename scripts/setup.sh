#!/bin/bash
# INFO: [СИСТЕМА] Скрипт налаштування проекту "Omnichannel" (MX-Linux; MiniOS)

# 1. Определяем путь к папке проекта
PROJECT_DIR="$(dirname "$(readlink -f "$0")")"

# 2. Список нужных программ
DEPENDENCIES="bash zenity notify-send sed"

echo "🚀 Начинаю настройку проекта..."
echo "------------------------------------------------"

# 3. Блок проверки и автоустановки
echo "🔍 Проверка системных компонентов:"
MISSING_PKGS=""

for cmd in $DEPENDENCIES; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  ✅ Инструмент '$cmd' найден: $(command -v "$cmd")"
    else
        echo "  ❌ ОШИБКА: Инструмент '$cmd' НЕ НАЙДЕН!"
        MISSING_PKGS="$MISSING_PKGS $cmd"
    fi
done

# Если чего-то не хватает, предлагаем установить
if [ -n "$MISSING_PKGS" ]; then
    echo "------------------------------------------------"
    echo "⚠️ Для работы проекта нужны пакеты:$MISSING_PKGS"
    read -p "Хотите установить их прямо сейчас? [y/n]: " answer
    if [[ "$answer" =~ ^[YyДд]$ ]]; then
        echo "📦 Запускаю установку через apt (понадобится пароль)..."
        sudo apt update && sudo apt install -y $MISSING_PKGS
    else
        echo "⚠️ Установка отменена. Скрипты могут работать некорректно."
    fi
fi


# 4. Даем права всем файлам (скрипты, ярлыки, питон)
echo "📦 Установка прав доступа (chmod +x)..."
find "$PROJECT_DIR" -type f \( -name "*.sh" -o -name "*.desktop" -o -name "*.py" \) -exec chmod +x {} +

# 5. Активация доверия для ярлыков (для GNOME)
find "$PROJECT_DIR" -name "*.desktop" -exec gio set {} metadata::trusted true 2>/dev/null \;

# 6. Финальный аккорд
echo "------------------------------------------------"
echo "🎉 Настройка завершена успешно!"
echo "Теперь вы можете запускать ярлыки двойным кликом."
echo "------------------------------------------------"

