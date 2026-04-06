#!/bin/bash
# INFO:[THUNAR] розширене меню в Thunar


# --- выбор действия ---
choice=$(zenity --list \
  --title="Переименование файлов" \
  --column="Действие" \
  "Пробелы → _" \
  "Имя → lower" \
  "Имя → UPPER" \
  "Расширение → lower" \
  "Очистка имени" \
  "Транслит" \
  "Добавить префикс" \
  "Добавить суффикс" \
  --height=440 --width=320)

[ -z "$choice" ] && exit 0

# --- ввод доп. параметров ---
prefix=""
suffix=""
do_numbering=false

if [[ "$choice" == "Добавить префикс" ]]; then
    prefix=$(zenity --entry --title="Префикс" --text="Введите префикс:")
    [ $? -ne 0 ] && exit 0
fi

if [[ "$choice" == "Добавить суффикс" ]]; then
    suffix=$(zenity --entry --title="Суффикс" --text="Введите суффикс:")
    [ $? -ne 0 ] && exit 0
fi

if [[ "$choice" == "Нумерация файлов" ]]; then
    # подтверждение: действительно нумеруем?
    zenity --question --title="Подтверждение нумерации" \
        --text="Вы хотите пронумеровать выбранные файлы?\nМожно отменить."
    [ $? -ne 0 ] && exit 0
    do_numbering=true
fi

preview=""
declare -A rename_map

# --- подготовка переименований ---
num=1
width=${#@}  # для ведущих нулей при нумерации

for f in "$@"; do
    dir="$(dirname "$f")"
    base="$(basename "$f")"
    name="${base%.*}"
    ext="${base##*.}"
    [ "$base" = "$ext" ] && ext="" || ext=".$ext"
    new="$base"

    case "$choice" in
        "Пробелы → _")
            new="${base// /_}"
            ;;
        "Имя → lower")
            new="$(echo "$name" | tr 'A-Z' 'a-z')$ext"
            ;;
        "Имя → UPPER")
            new="$(echo "$name" | tr 'a-z' 'A-Z')$ext"
            ;;
        "Расширение → lower")
            if [ "$ext" != "" ]; then
                new="$name.$(echo "$ext" | tr 'A-Z' 'a-z')"
            fi
            ;;
        "Очистка имени")
            clean="$(echo "$name" | tr -cd '[:alnum:]_-')"
            new="$clean$ext"
            ;;
        "Транслит")
            new="$(echo "$base" | iconv -f UTF-8 -t ASCII//TRANSLIT)"
            ;;
        "Добавить префикс")
            new="$prefix$name$ext"
            ;;
        "Добавить суффикс")
            new="$name$suffix$ext"
            ;;
        "Нумерация файлов")
            printf -v number "%0${#@}d" "$num"
            new="$number"_"$name$ext"
            num=$((num+1))
            ;;
    esac

    rename_map["$f"]="$dir/$new"

    if [ "$base" != "$new" ]; then
        preview+="$base → $(basename "$new")\n"
    fi
done

# --- если нечего менять ---
[ -z "$preview" ] && zenity --info --text="Нет изменений" && exit 0

# --- предпросмотр ---
zenity --question \
  --title="Подтвердите переименование" \
  --width=500 \
  --height=400 \
  --text="Будут выполнены изменения:\n\n$preview"

[ $? -ne 0 ] && exit 0

# --- выполнение ---
errors=""

for old in "${!rename_map[@]}"; do
    new="${rename_map[$old]}"
    if [ ! -e "$new" ]; then
        mv -- "$old" "$new"
    else
        errors+="Пропущено (уже существует): $(basename "$new")\n"
    fi
done

# --- результат ---
if [ -n "$errors" ]; then
    zenity --warning --text="Готово, но с предупреждениями:\n\n$errors"
else
    zenity --info --text="Переименование завершено!"
fi
