#!/bin/bash
# INFO:[WINE] встановлення .reg-файлів з папки

PREFIX_DIR="$HOME/prefixes"
REG_DIR="$HOME/wine_font_presets"

# Проверка zenity
if ! command -v zenity >/dev/null 2>&1; then
    echo "zenity не найден. Установи его через пакетный менеджер и попробуй снова."
    exit 1
fi

# Проверка папок
if [ ! -d "$PREFIX_DIR" ]; then
    zenity --error --text="Папка с префиксами не найдена:\n$PREFIX_DIR"
    exit 1
fi

if [ ! -d "$REG_DIR" ]; then
    zenity --error --text="Папка с .reg-файлами не найдена:\n$REG_DIR"
    exit 1
fi

# Выбор префикса
PREFIX=$(zenity --file-selection \
    --title="Выбери Wine-префикс" \
    --filename="$PREFIX_DIR/" \
    --directory)

[ -z "$PREFIX" ] && exit 0

# Выбор .reg-файла
REGFILE=$(zenity --file-selection \
    --title="Выбери .reg-файл для импорта" \
    --filename="$REG_DIR/" \
    --file-filter="*.reg")

[ -z "$REGFILE" ] && exit 0

zenity --question --text="Импортировать\n$REGFILE\nв префикс:\n$PREFIX ?"
[ $? -ne 0 ] && exit 0

# Импорт
WINEPREFIX="$PREFIX" wine regedit "$REGFILE"

# Перезапуск Wine
pkill -9 wine 2>/dev/null
pkill -9 wineserver 2>/dev/null

zenity --info --text="Готово!\n\nПрефикс:\n$PREFIX\nФайл:\n$REGFILE"

