#!/bin/bash
# INFO: [WINE] установник .exe у потрібний префікс


# Чудесный установщик Wine с выбором префикса на внешнем диске
# + автоматический запуск winecfg после установки

EXT_WINE="/home/minok/prefixes"
USER_NAME=$(logname)

# ----------------------
# Запрос .exe-файла
exe=$(zenity --file-selection --title="Выберите установочный файл (.exe)")
[ -z "$exe" ] && exit

# ----------------------
# Получаем список существующих префиксов
prefixes=()
if [ -d "$EXT_WINE" ]; then
    while IFS= read -r dir; do
        prefixes+=("$(basename "$dir")")
    done < <(find "$EXT_WINE" -mindepth 1 -maxdepth 1 -type d)
fi

# Добавляем вариант для нового префикса
prefixes+=("Создать новый префикс...")

# ----------------------
# Диалог выбора префикса
choice=$(zenity --list \
    --title="Выберите Wine-префикс" \
    --text="Выберите существующий префикс или создайте новый" \
    --column="Префикс" "${prefixes[@]}")

[ -z "$choice" ] && exit

# ----------------------
# Если выбран новый префикс
if [ "$choice" == "Создать новый префикс..." ]; then
    newprefix=$(zenity --entry --title="Новый префикс" --text="Введите имя нового префикса:")
    [ -z "$newprefix" ] && exit
    DST="$EXT_WINE/$newprefix"
    mkdir -p "$DST"
    chown -R $USER_NAME:$USER_NAME "$DST"
    prefix="$DST"
else
    prefix="$EXT_WINE/$choice"
fi

# ----------------------
# Создаём симлинк в домашней папке, если его ещё нет
LINK="$HOME/.wine/$(basename "$prefix")"
if [ ! -L "$LINK" ]; then
    ln -s "$prefix" "$LINK"
    echo "Создан симлинк $LINK → $prefix"
fi

# ----------------------
# Запуск установки
WINEPREFIX="$prefix" wine "$exe"

# ----------------------
# Автоматический
