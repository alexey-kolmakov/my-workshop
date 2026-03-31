#!/bin/bash
# INFO:[СИСТЕМА] відновлення після форматування носія


#Восстановление файлов после случайного форматирования носителя
# Меню восстановления файлов

# Цвета
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Заголовок
clear
echo -e "${GREEN}=== МЕНЮ ВОССТАНОВЛЕНИЯ ФАЙЛОВ ===${RESET}"
echo -e "${YELLOW}Выберите инструмент для восстановления:${RESET}"
echo
echo "1) TestDisk — восстановление разделов и таблицы файлов"
echo "2) PhotoRec — восстановление файлов по сигнатурам"
echo "3) extundelete — для ext3/ext4 (если формат был быстрый)"
echo "4) Установить все инструменты"
echo "0) Выход"
echo

read -p "Ваш выбор: " choice

case $choice in
    1)
        echo -e "${GREEN}Запуск TestDisk...${RESET}"
        sudo testdisk
        ;;
    2)
        echo -e "${GREEN}Запуск PhotoRec...${RESET}"
        sudo photorec
        ;;
    3)
        read -p "Введите путь к разделу (например, /dev/sdX1): " partition
        echo -e "${GREEN}Запуск extundelete...${RESET}"
        sudo extundelete $partition --restore-all
        ;;
    4)
        echo -e "${GREEN}Установка всех инструментов...${RESET}"
        sudo apt update
        sudo apt install testdisk extundelete -y
        echo -e "${GREEN}PhotoRec уже входит в пакет testdisk.${RESET}"
        ;;
    0)
        echo -e "${RED}Выход из меню.${RESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}Неверный выбор. Попробуйте снова.${RESET}"
        ;;
esac

