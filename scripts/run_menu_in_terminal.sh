#!/bin/bash
# INFO: [СИСТЕМА] Скрипт-меню запуску скриптів у терміналі. Appimage (MX-Linux; MiniOS)

# Правильное вычисление APPDIR (scripts/.. = Omnichannel)
APPDIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "========================================"
echo "▶ Меню запуска скриптов MiniOS"
echo "APPDIR: $APPDIR"
echo "========================================"

# ---------------------------------------------------------
# 1. Проверка Terminal.AppImage
# ---------------------------------------------------------
TERMINAL="$APPDIR/programs/Terminal.AppImage"

if [[ ! -f "$TERMINAL" ]]; then
    echo "❌ Terminal.AppImage не найден!"
    echo "Ожидался путь: $TERMINAL"
    exit 1
fi

# ---------------------------------------------------------
# 2. Проверка NetworkManager
# ---------------------------------------------------------
if ! systemctl is-active --quiet NetworkManager; then
    echo "❌ NetworkManager не запущен!"
    exit 1
fi

# ---------------------------------------------------------
# 3. Проверка Wi‑Fi адаптера
# ---------------------------------------------------------
if ! nmcli device | grep -q wifi; then
    echo "❌ Wi‑Fi адаптер не найден!"
    exit 1
fi

# ---------------------------------------------------------
# 4. Проверка состояния Wi‑Fi
# ---------------------------------------------------------
if [[ "$(nmcli radio wifi)" != "enabled" ]]; then
    echo "ℹ Wi‑Fi выключен — включаю..."
    nmcli radio wifi on
fi

# ---------------------------------------------------------
# 5. Проверка активного подключения
# ---------------------------------------------------------
ACTIVE=$(nmcli -t -f ACTIVE,SSID dev wifi | grep "^yes" | cut -d: -f2)
if [[ -n "$ACTIVE" ]]; then
    echo "ℹ Активное подключение: $ACTIVE"
else
    echo "ℹ Нет активного подключения."
fi

# ---------------------------------------------------------
# 🔁 Основной цикл меню
# ---------------------------------------------------------
while true; do
    echo
    echo "Выберите действие:"
    echo "1) Подключение к Wi‑Fi (wifi-connect.sh)"
    echo "2) Оптимизация RTL8822CE (rtl8822ce-optimize.sh)"
    echo "3) Тест стабильности Wi‑Fi (wifi-test.sh)"
    echo "4) Выход"
    echo
    read -p "Введите номер: " choice

    case "$choice" in
        1)
            SCRIPT="$APPDIR/scripts/wifi-connect.sh"
            TITLE="Подключение к Wi‑Fi"
            ;;
        2)
            SCRIPT="$APPDIR/scripts/rtl8822ce-optimize.sh"
            TITLE="Оптимизация RTL8822CE"
            ;;
        3)
            SCRIPT="$APPDIR/scripts/wifi-test.sh"
            TITLE="Тест стабильности Wi‑Fi"
            ;;
        4)
            echo "Выход."
            exit 0
            ;;
        *)
            echo "❌ Неверный выбор!"
            continue
            ;;
    esac

    if [[ ! -f "$SCRIPT" ]]; then
        echo "❌ Скрипт не найден: $SCRIPT"
        continue
    fi

    chmod +x "$SCRIPT"

    echo "----------------------------------------"
    echo "▶ Запускаю Terminal.AppImage:"
    echo "$SCRIPT"
    echo "----------------------------------------"

    # ВАЖНО: Terminal.AppImage принимает только один аргумент — путь к скрипту
    "$TERMINAL" -e "$SCRIPT"

    # После закрытия терминала — возврат к меню
done
