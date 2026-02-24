#!/bin/bash
# Обработка скриптов на Linux: исправление CRLF и управление исполнением
# Можно выбрать один файл или папку для массовой обработки

# Выбор действия
ACTION=$(zenity --list \
  --title="Выберите действие" \
  --text="Что вы хотите сделать с файлом/папкой?" \
  --radiolist \
  --column="Выбор" --column="Действие" \
  TRUE "Сделать исполняемым" \
  FALSE "Снять исполнение")

if [ -z "$ACTION" ]; then
  zenity --info --title="Отменено" --text="Действие отменено."
  exit 0
fi

# Выбор режима: один файл или папка
MODE=$(zenity --list \
  --title="Выберите режим" \
  --text="Обработать:" \
  --radiolist \
  --column="Выбор" --column="Режим" \
  TRUE "Один файл" \
  FALSE "Папка (все .sh файлы)")

if [ -z "$MODE" ]; then
  zenity --info --title="Отменено" --text="Действие отменено."
  exit 0
fi

# Выбор файла или папки
if [ "$MODE" = "Один файл" ]; then
  TARGET=$(zenity --file-selection --title="Выберите файл")
  FILES=("$TARGET")
else
  TARGET=$(zenity --file-selection --directory --title="Выберите папку")
  FILES=($(find "$TARGET" -type f -name "*.sh"))
fi

# Проверка на выбор
if [ -z "$TARGET" ]; then
  zenity --info --title="Отменено" --text="Ничего не выбрано. Действие отменено."
  exit 0
fi

# Обработка файлов
for FILE in "${FILES[@]}"; do
  if [ ! -f "$FILE" ]; then
    echo "⚠ Файл не найден: $FILE"
    continue
  fi

  PERMS_BEFORE=$(stat -c "%A" "$FILE")
  # Исправляем переносы строк
  sed -i 's/\r$//' "$FILE"

  if [ "$ACTION" = "Сделать исполняемым" ]; then
    chmod +x "$FILE"
    RESULT_TEXT="Файл теперь исполняемый."
  else
    chmod -x "$FILE"
    RESULT_TEXT="Исполнение снято. Файл нельзя запустить как программу."
  fi

  PERMS_AFTER=$(stat -c "%A" "$FILE")

  echo -e "✅ $FILE\nПрава ДО: $PERMS_BEFORE\nПрава ПОСЛЕ: $PERMS_AFTER\n$RESULT_TEXT\n"
done | zenity --text-info --title="Результаты обработки" --width=600 --height=400


# Делает файл исполняемым
