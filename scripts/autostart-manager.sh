#!/bin/bash
# INFO: [СИСТЕМА] Автоматична ревізія автозавантаження


AUTOSTART="$HOME/.config/autostart"
ARCHIVE="$AUTOSTART/disabled"
LOG="$HOME/.autostart-manager.log"
mkdir -p "$ARCHIVE"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"
echo -e "${CYAN}🔍 Автоматическая ревизия автозагрузки...${RESET}"

enabled=0
disabled=0
broken=0

for file in "$AUTOSTART"/*.desktop; do
    [ -f "$file" ] || continue
    name=$(grep -m1 "^Name=" "$file" | cut -d= -f2)
    exec=$(grep -m1 "^Exec=" "$file" | cut -d= -f2)
    hidden=$(grep -m1 "^Hidden=" "$file")

    if [[ -z "$exec" ]]; then
        echo -e "${RED}⚠️ $name — отсутствует Exec!${RESET}"
        ((broken++))
    elif [[ "$hidden" == "true" ]]; then
        ((disabled++))
    else
        ((enabled++))
    fi
done

echo -e "${CYAN}╔═══════════════════════════════════╗"
echo -e        "║         📊 Статистика             ║"
echo -e        "╚═══════════════════════════════════╝${RESET}"
echo -e "✅ Включено: $enabled"
echo -e "❌ Отключено: $disabled"
echo -e "🛑 Без Exec: $broken"

# 🔧 Интерактивная обработка файлов без Exec
BROKEN_FILES=($(grep -L "^Exec=" "$AUTOSTART"/*.desktop))

if (( ${#BROKEN_FILES[@]} > 0 )); then
    echo -e "${YELLOW}🛠 Обнаружены .desktop файлы без Exec. Выберите, что с ними делать:${RESET}"
    PS3=$'\n'"${CYAN}Выберите файл для обработки:${RESET} "
    select FILE in "${BROKEN_FILES[@]}" "🚪 Пропустить"; do
        [[ "$REPLY" == "$(( ${#BROKEN_FILES[@]} + 1 ))" ]] && break
        [[ -z "$FILE" ]] && echo -e "${RED}Неверный выбор${RESET}" && continue

        NAME=$(grep -m1 "^Name=" "$FILE" | cut -d= -f2)
        echo -e "${CYAN}Выбран:${RESET} $NAME → $FILE"
        echo -e "${YELLOW}Что сделать с этим файлом?${RESET}"
        select ACTION in "🔧 Добавить Exec вручную" "📦 Архивировать" "🗑 Удалить" "↩ Назад"; do
            case $REPLY in
                1) read -p "Введите команду Exec: " CMD
                   echo "Exec=$CMD" >> "$FILE"
                   echo "$(date): FIXED Exec for $NAME → $CMD" >> "$LOG"
                   echo -e "${GREEN}Добавлено: Exec=$CMD${RESET}"; break ;;
                2) mv "$FILE" "$ARCHIVE/"
                   echo "$(date): ARCHIVED broken $NAME" >> "$LOG"
                   echo -e "${YELLOW}Перемещено в архив!${RESET}"; break ;;
                3) rm "$FILE"
                   echo "$(date): DELETED broken $NAME" >> "$LOG"
                   echo -e "${RED}Удалено!${RESET}"; break ;;
                4) break ;;
                *) echo -e "${RED}Неверный выбор${RESET}" ;;
            esac
        done
    done
fi


sleep 5
clear
echo -e "${CYAN}╔════════════════════════════════════════════╗"
echo -e "║     🎛 Менеджер автозагрузки XFCE         ║"
echo -e "╚════════════════════════════════════════════╝${RESET}"

mapfile -t FILES < <(find "$AUTOSTART" -maxdepth 1 -name "*.desktop")

PS3=$'\n'"${YELLOW}Выберите файл для управления:${RESET} "
select FILE in "${FILES[@]}" "🚪 Выход"; do
    [[ "$REPLY" == "$(( ${#FILES[@]} + 1 ))" ]] && echo -e "${CYAN}До встречи!${RESET}" && exit 0
    [[ -z "$FILE" ]] && echo -e "${RED}Неверный выбор${RESET}" && continue

    NAME=$(grep -m1 "^Name=" "$FILE" | cut -d= -f2)
    EXEC=$(grep -m1 "^Exec=" "$FILE" | cut -d= -f2)
    STATUS=$(grep -m1 "^Hidden=" "$FILE")

    echo -e "${CYAN}Выбран:${RESET} $NAME → $EXEC"
    echo -e "${YELLOW}Что сделать с этим файлом?${RESET}"
    select ACTION in "✅ Включить" "❌ Отключить" "🗑 Удалить" "📦 Архивировать" "↩ Назад"; do
        case $REPLY in
            1) sed -i '/^Hidden=/d' "$FILE"; echo "Hidden=false" >> "$FILE"
               echo "$(date): ENABLED $NAME" >> "$LOG"
               echo -e "${GREEN}Включено!${RESET}"; break ;;
            2) sed -i '/^Hidden=/d' "$FILE"; echo "Hidden=true" >> "$FILE"
               echo "$(date): DISABLED $NAME" >> "$LOG"
               echo -e "${RED}Отключено!${RESET}"; break ;;
            3) rm "$FILE"
               echo "$(date): DELETED $NAME" >> "$LOG"
               echo -e "${RED}Удалено!${RESET}"; break ;;
            4) mv "$FILE" "$ARCHIVE/"
               echo "$(date): ARCHIVED $NAME" >> "$LOG"
               echo -e "${YELLOW}Перемещено в архив!${RESET}"; break ;;
            5) break ;;
            *) echo -e "${RED}Неверный выбор${RESET}" ;;
        esac
    done
done

# Автоматическая ревизия автозагрузки
