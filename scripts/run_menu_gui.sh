#!/bin/bash
# INFO: [СИСТЕМА] zenity - меню проверки Wi-Fi сетей (MX-Linux; MiniOS)

# Правильное вычисление APPDIR
APPDIR="$(cd "$(dirname "$0")/.." && pwd)"

TERMINAL="$APPDIR/programs/Terminal.AppImage"

if [[ ! -f "$TERMINAL" ]]; then
    zenity --error --text="Terminal.AppImage не найден:\n$TERMINAL"
    exit 1
fi

# Проверка NetworkManager
if ! systemctl is-active --quiet NetworkManager; then
    zenity --error --text="NetworkManager не запущен!"
    exit 1
fi

# Проверка Wi‑Fi адаптера
if ! nmcli device | grep -q wifi; then
    zenity --error --text="Wi‑Fi адаптер не найден!"
    exit 1
fi

# Основной цикл GUI‑меню
while true; do

    CHOICE=$(zenity --list \
        --title="MiniOS Wi‑Fi Menu" \
        --text="Выберите действие:" \
        --column="Действие" \
        "Подключение к Wi‑Fi" \
        "Оптимизация RTL8822CE" \
        "Тест стабильности Wi‑Fi" \
        "Выход")

    case "$CHOICE" in
        "Подключение к Wi‑Fi")
            SCRIPT="$APPDIR/scripts/wifi-connect.sh"
            ;;
        "Оптимизация RTL8822CE")
            SCRIPT="$APPDIR/scripts/rtl8822ce-optimize.sh"
            ;;
        "Тест стабильности Wi‑Fi")
            SCRIPT="$APPDIR/scripts/wifi-test.sh"
            ;;
        "Выход")
            exit 0
            ;;
        *)
            # Пользователь закрыл окно
            exit 0
            ;;
    esac

    if [[ ! -f "$SCRIPT" ]]; then
        zenity --error --text="Скрипт не найден:\n$SCRIPT"
        continue
    fi

    chmod +x "$SCRIPT"

    # Запуск скрипта в Terminal.AppImage
    "$TERMINAL" -e "$SCRIPT"

done
