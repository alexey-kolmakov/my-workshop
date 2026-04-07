#!/bin/bash
# INFO: [СИСТЕМА] найчастіші команди в термінал

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FAV_FILE="$SCRIPT_DIR/favorites.txt"
USER_CMDS="$SCRIPT_DIR/my_commands.txt"
CHOSEN_FILE="$SCRIPT_DIR/chosen_command.txt"

touch "$FAV_FILE" "$USER_CMDS" "$CHOSEN_FILE"

commands=(
"pwd|Показать текущую папку"
"ls -la|Список файлов подробно"
"cd ..|На уровень вверх"
"chmod +x file|Сделать файл исполняемым"
"cp file1 file2|Копировать файл"
"mv file1 file2|Переместить или переименовать"
"rm file|Удалить файл"
"mkdir dir|Создать папку"
"touch file|Создать файл"

"grep 'text' file|Поиск текста"
"find . -name file|Поиск файла"

"sudo apt update|Обновить пакеты"
"sudo apt upgrade|Обновить систему"
"sudo apt install pkg|Установить пакет"

"top|Монитор процессов"
"ps aux|Список процессов"
"kill PID|Завершить процесс"

"df -h|Место на диске"
"free -h|Память"

"lsblk|Список дисков"
"udisksctl mount -b /dev/sdX1|Смонтировать"
"udisksctl unmount -b /dev/sdX1|Размонтировать"

"ip a|Сеть"
"ping google.com|Проверка сети"

"tar -czf file.tar.gz dir|Создать архив"
"tar -xzf file.tar.gz|Распаковать архив"
)

# ----------------------

pause() { read -p "Enter..."; }

run_command() {
    clear
    echo "Команда:"
    echo "$1"
    echo "------------------"
    read -p "Выполнить? (y/n): " ans
    if [[ "$ans" == "y" ]]; then
        eval "$1"
        # Сохраняем именно ту команду, которую выполнили, в отдельный файл
        echo "$1" > "$CHOSEN_FILE"
    fi
    pause
}

copy_command() {
    # Сохраняем команду в файл даже при копировании
    echo "$1" > "$CHOSEN_FILE"

    if command -v xclip >/dev/null; then
        echo -n "$1" | xclip -selection clipboard
        echo "Скопировано (xclip)"
    elif command -v xsel >/dev/null; then
        echo -n "$1" | xsel --clipboard
        echo "Скопировано (xsel)"
    else
        echo "$1"
    fi
    pause
}

add_fav() {
    echo "$1" >> "$FAV_FILE"
    echo "⭐ Добавлено"
    pause
}

remove_fav() {
    mapfile -t favs < "$FAV_FILE"
    > "$FAV_FILE"
    for i in "${!favs[@]}"; do
        if [[ $i -ne $1 ]]; then
            echo "${favs[$i]}" >> "$FAV_FILE"
        fi
    done
}

add_user_cmd() {
    read -p "Команда: " cmd
    read -p "Описание: " desc
    echo "$cmd|$desc" >> "$USER_CMDS"
    echo "Добавлено!"
    pause
}

show_list() {
    local arr=("$@")

    while true; do
        clear
        i=1
        for item in "${arr[@]}"; do
            cmd="${item%%|*}"
            desc="${item##*|}"
            echo "$i) $cmd"
            echo "   → $desc"
            ((i++))
        done

        echo "0) Назад"
        read -p "Выбор: " num
        [[ "$num" == "0" ]] && return

        index=$((num-1))
        item="${arr[$index]}"
        cmd="${item%%|*}"

        echo "1) Выполнить"
        echo "2) Копировать"
        echo "3) В избранное"
        read -p "Выбор: " act

        case $act in
            1) run_command "$cmd" ;;
            2) copy_command "$cmd" ;;
            3) add_fav "$cmd" ;;
        esac
    done
}

search_commands() {
    read -p "Поиск: " query
    query=$(echo "$query" | tr '[:upper:]' '[:lower:]')

    all=("${commands[@]}")
    mapfile -t user < "$USER_CMDS"
    all+=("${user[@]}")

    results=()

    for item in "${all[@]}"; do
        low=$(echo "$item" | tr '[:upper:]' '[:lower:]')
        [[ "$low" == *"$query"* ]] && results+=("$item")
    done

    [[ ${#results[@]} -eq 0 ]] && echo "Ничего не найдено" && pause && return

    show_list "${results[@]}"
}

favorites_menu() {
    mapfile -t favs < "$FAV_FILE"
    [[ ${#favs[@]} -eq 0 ]] && echo "Пусто" && pause && return

    while true; do
        clear
        i=1
        for cmd in "${favs[@]}"; do
            echo "$i) $cmd"
            ((i++))
        done

        echo "d) удалить"
        echo "0) назад"
        read -p "Выбор: " input

        [[ "$input" == "0" ]] && return

        if [[ "$input" == "d" ]]; then
            read -p "Номер для удаления: " num
            remove_fav $((num-1))
            mapfile -t favs < "$FAV_FILE"
            continue
        fi

        cmd="${favs[$((input-1))]}"

        echo "1) Выполнить"
        echo "2) Копировать"
        read -p "Выбор: " act

        case $act in
            1) run_command "$cmd" ;;
            2) copy_command "$cmd" ;;
        esac
    done
}

user_commands_menu() {
    mapfile -t user < "$USER_CMDS"
    [[ ${#user[@]} -eq 0 ]] && echo "Пусто" && pause && return
    show_list "${user[@]}"
}

# ----------------------

while true; do
    clear
    echo "==== Linux Helper PRO MAX ===="
    echo "1) Все команды"
    echo "2) Поиск"
    echo "3) Избранное"
    echo "4) Мои команды"
    echo "5) Добавить команду"
    echo "0) Выход"

    read -p "Выбор: " choice

    case $choice in
        1) show_list "${commands[@]}" ;;
        2) search_commands ;;
        3) favorites_menu ;;
        4) user_commands_menu ;;
        5) add_user_cmd ;;
        0) exit ;;
    esac
done
