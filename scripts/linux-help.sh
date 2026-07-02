#!/bin/bash
# INFO: [СИСТЕМА] Формує список термінальних команд Linux, що скачується.


# --- НАСТРОЙКИ ПУТЕЙ ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
FAV_FILE="$SCRIPT_DIR/favorites.txt"
USER_CMDS="$SCRIPT_DIR/my_commands.txt"
CHOSEN_FILE="$SCRIPT_DIR/chosen_command.txt"

# Создаем файлы, если их нет
touch "$FAV_FILE" "$USER_CMDS" "$CHOSEN_FILE"

# --- КАТЕГОРИИ КОМАНД ---

# 1. Файлы и папки
files_cmds=(
"pwd|Показать текущую папку"
"ls -la|Список файлов подробно"
"cd ..|На уровень вверх"
"chmod +x file|Сделать файл исполняемым"
"cp file1 file2|Копировать файл"
"mv file1 file2|Переместить или переименовать"
"rm file|Удалить файл"
"mkdir dir|Создать папку"
"touch file|Создать файл"
"tar -czf file.tar.gz dir|Создать архив"
"tar -xzf file.tar.gz|Распаковать архив"
)

# 2. Поиск и информация о системе
search_cmds=(
"grep 'text' file|Поиск текста"
"find . -name file|Поиск файла"
"df -h|Место на диске"
"free -h|Память"
"lsblk|Список дисков"
)

# 3. Система и управление процессами
sys_cmds=(
"sudo apt update|Обновить пакеты"
"sudo apt upgrade|Обновить систему"
"sudo apt install pkg|Установить пакет"
"top|Монитор процессов"
"ps aux|Список процессов"
"kill PID|Завершить процесс"
)

# 4. Сеть и диски
net_cmds=(
"ip a|Сеть"
"ping google.com|Проверка сети"
"udisksctl mount -b /dev/sdX1|Смонтировать"
"udisksctl unmount -b /dev/sdX1|Размонтировать"
)

# Вспомогательная функция паузы
pause() { read -p "Enter..."; }

# --- ФУНКЦИИ ВЫПОЛНЕНИЯ КОМАНД ---

run_command() {
    local cmd="$1"
    clear
    echo "Команда:"
    echo "$cmd"
    echo "------------------"
    read -p "Выполнить? (y/n): " ans

    if [[ "$ans" == "y" ]]; then
        eval "$cmd"
        echo "$cmd" > "$CHOSEN_FILE"
    fi
    pause
}

copy_command() {
    local cmd="$1"
    echo "$cmd" > "$CHOSEN_FILE"

    if command -v xclip >/dev/null; then
        echo -n "$cmd" | xclip -selection clipboard
        echo "✅ Скопировано (xclip)"
    elif command -v xsel >/dev/null; then
        echo -n "$cmd" | xsel --clipboard
        echo "✅ Скопировано (xsel)"
    else
        echo "⚠️ Буфер обмена не найден. Вот команда:"
        echo "$cmd"
    fi
    pause
}

# --- РАБОТА С ИЗБРАННЫМ ---

add_fav() {
    local cmd="$1"
    echo "$cmd" >> "$FAV_FILE"
    echo "⭐ Добавлено в избранное"
    pause
}

remove_fav() {
    local index_to_remove=$1
    mapfile -t favs < "$FAV_FILE"
    > "$FAV_FILE" # Очистка файла

    for i in "${!favs[@]}"; do
        if [[ $i -ne $index_to_remove ]]; then
            echo "${favs[$i]}" >> "$FAV_FILE"
        fi
    done
}

# --- ДОБАВЛЕНИЕ СВОЕЙ КОМАНДЫ ---

add_user_cmd() {
    read -p "Команда: " cmd
    read -p "Описание: " desc
    if [[ -n "$cmd" && -n "$desc" ]]; then
        echo "$cmd|$desc" >> "$USER_CMDS"
        echo "✅ Добавлено в «Мои команды»"
    else
        echo "❌ Ошибка: введите и команду и описание"
    fi
    pause
}

# --- ОТОБРАЖЕНИЕ СПИСКА (МЕНЮ) ---
# Здесь реализован ваш запрос: сначала описание, потом команда
show_list() {
    local arr=("$@")

    while true; do
        clear
        i=1
        for item in "${arr[@]}"; do
            # Разделяем строку по символу "|"
            cmd="${item%%|*}"
            desc="${item##*|}"

            # Выводим описание первым, как вы хотели
            echo "$i) $desc"
            echo "   👉 $cmd"

            ((i++))
        done

        echo "0) Назад"
        read -p "Выбор: " num

        if [[ "$num" == "0" ]]; then
            return
        fi

        # Проверка на корректный ввод
        if [[ ! "$num" =~ ^[0-9]+$ ]] || [[ "$num" -gt ${#arr[@]} ]]; then
            echo "❌ Неверный номер"
            pause
            continue
        fi

        index=$((num-1))
        item="${arr[$index]}"
        cmd="${item%%|*}"

        echo "1) Выполнить"
        echo "2) Копировать"
        if [[ -f "$FAV_FILE" ]]; then
            echo "3) В избранное"
            read -p "Выбор: " act
            case $act in
                1) run_command "$cmd" ;;
                2) copy_command "$cmd" ;;
                3) add_fav "$cmd" ;;
                *) pause ;;
            esac
        else
            # Если нет файла избранного (редкий случай), просто 1 и 2
            read -p "Выбор (1/2): " act
            case $act in
                1) run_command "$cmd" ;;
                2) copy_command "$cmd" ;;
                *) pause ;;
            esac
        fi
    done
}

# --- ПОИСК ПО ВСЕМ КОМАНДАМ ---

search_commands() {
    read -p "Поиск (введите слово): " query
    query=$(echo "$query" | tr '[:upper:]' '[:lower:]')

    # Собираем все команды в один массив
    all=("${files_cmds[@]}" "${search_cmds[@]}" "${sys_cmds[@]}" "${net_cmds[@]}")
    mapfile -t user < "$USER_CMDS"
    all+=("${user[@]}")

    results=()

    for item in "${all[@]}"; do
        low=$(echo "$item" | tr '[:upper:]' '[:lower:]')
        # Ищем совпадение в строке
        [[ "$low" == *"$query"* ]] && results+=("$item")
    done

    if [[ ${#results[@]} -eq 0 ]]; then
        echo "😕 Ничего не найдено по запросу: $query"
    else
        echo "🔍 Найдено команд: ${#results[@]}"
        show_list "${results[@]}"
    fi
    pause
}

# --- МЕНЮ ИЗБРАННОГО ---

favorites_menu() {
    mapfile -t favs < "$FAV_FILE"
    if [[ ${#favs[@]} -eq 0 ]]; then
        echo "📭 Избранное пусто"
        pause
        return
    fi

    while true; do
        clear
        echo "==== ИЗБРАННОЕ ===="
        i=1
        for cmd in "${favs[@]}"; do
            echo "$i) $cmd"
            ((i++))
        done

        echo "d) Удалить из избранного"
        echo "0) Назад"
        read -p "Выбор: " input

        if [[ "$input" == "0" ]]; then
            return
        fi

        if [[ "$input" == "d" ]]; then
            echo "Введите номер команды для удаления:"
            read -p "Номер: " num
            if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -gt 0 && $num -le ${#favs[@]} ]]; then
                remove_fav $((num-1))
                echo "✅ Удалено"
                pause
            else
                echo "❌ Неверный номер"
                pause
            fi
            continue
        fi

        if [[ "$input" =~ ^[0-9]+$ ]] && [[ $input -gt 0 && $input -le ${#favs[@]} ]]; then
            cmd="${favs[$((input-1))]}"
            # Разбираем строку, если вдруг в избранное попал пользовательский формат
            cmd_part="${cmd%%|*}"

            echo "1) Выполнить"
            echo "2) Копировать"
            read -p "Выбор: " act
            case $act in
                1) run_command "$cmd_part" ;;
                2) copy_command "$cmd_part" ;;
                *) pause ;;
            esac
        else
            echo "❌ Неверный выбор"
            pause
        fi
    done
}

# --- МЕНЮ ПОЛЬЗОВАТЕЛЬСКИХ КОМАНД ---

user_commands_menu() {
    mapfile -t user < "$USER_CMDS"
    if [[ ${#user[@]} -eq 0 ]]; then
        echo "📭 Ваши команды еще не добавлены"
        pause
        return
    fi
    show_list "${user[@]}"
}

# --- ГЛАВНОЕ МЕНЮ ---

while true; do
    clear
    echo "==== Linux Helper PRO MAX ===="
    echo "1) Категории команд"
    echo "2) Поиск команд"
    echo "3) Избранное"
    echo "4) Мои команды"
    echo "5) Добавить свою команду"
    echo "0) Выход"
    echo "------------------"
    echo "Последняя команда: $(cat "$CHOSEN_FILE" 2>/dev/null || echo "нет")"

    read -p "Выбор: " choice

    case $choice in
        1)
            # Меню категорий
            while true; do
                clear
                echo "=== ВЫБЕРИТЕ КАТЕГОРИЮ ==="
                echo "1) Файлы и папки"
                echo "2) Поиск и информация"
                echo "3) Система и процессы"
                echo "4) Сеть и диски"
                echo "0) Назад"

                read -p "Выбор: " cat_choice
                case $cat_choice in
                    1) show_list "${files_cmds[@]}" ;;
                    2) show_list "${search_cmds[@]}" ;;
                    3) show_list "${sys_cmds[@]}" ;;
                    4) show_list "${net_cmds[@]}" ;;
                    0) break ;;
                    *) echo "Неверный выбор"; pause ;;
                esac
            done
            ;;
        2) search_commands ;;
        3) favorites_menu ;;
        4) user_commands_menu ;;
        5) add_user_cmd ;;
        0)
            echo "До свидания!"
            exit 0
            ;;
        *)
            echo "❌ Неверный выбор"
            pause
            ;;
    esac
done
