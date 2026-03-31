#!/usr/bin/env bash
# INFO: [WINE] Менеджер Wine-префиксов (с диалогами)


# ------------------------------------------------------------
# Менеджер Wine-префиксов (версия с проверками и диалогами)
# Автор: ChatGPT + Олексій 😊
# ------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# --- Основные настройки ---
WINE_DIR="${WINE_DIR:-$HOME/prefixes}"   # можно переопределить через переменную окружения
USER_NAME=${USER:-$(whoami)}

# --- Проверка наличия нужных команд ---
REQUIRED_CMDS=(zenity wine winetricks find basename)
missing=()

for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing+=("$cmd")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    zenity --error --title="Ошибка" \
        --text="Отсутствуют необходимые команды:\n\n${missing[*]}\n\nУстанови их и попробуй снова."
    exit 1
fi

# --- Проверка наличия директории с префиксами ---
if [ ! -d "$WINE_DIR" ]; then
    zenity --error --title="Ошибка" \
        --text="Каталог с префиксами не найден:\n$WINE_DIR"
    exit 1
fi

# --- Получаем список существующих префиксов ---
prefixes=()
while IFS= read -r dir; do
    prefixes+=("$(basename "$dir")")
done < <(find "$WINE_DIR" -mindepth 1 -maxdepth 1 -type d)

if [ ${#prefixes[@]} -eq 0 ]; then
    zenity --error --text="Не найдено ни одного префикса Wine в:\n$WINE_DIR"
    exit 1
fi

# --- Диалог выбора префикса ---
choice=$(zenity --list \
    --title="Выберите Wine-префикс" \
    --text="Выберите префикс для работы с Wine" \
    --column="Префикс" "${prefixes[@]}")

[ -z "$choice" ] && exit

prefix="$WINE_DIR/$choice"

# --- Диалог выбора действия ---
action=$(zenity --list \
    --title="Что открыть?" \
    --text="Выберите действие для префикса: $choice" \
    --column="Действие" "winecfg" "regedit" "winetricks")

[ -z "$action" ] && exit

# --- Запуск выбранного действия ---
case "$action" in
    winecfg)
        WINEPREFIX="$prefix" winecfg
        ;;
    regedit)
        WINEPREFIX="$prefix" wine regedit
        ;;
    winetricks)
        WINEPREFIX="$prefix" winetricks
        ;;
esac
