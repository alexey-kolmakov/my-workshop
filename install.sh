#!/bin/bash
# install.sh — автоматический установщик рабочей мастерской

echo "=============================="
echo "  АВТОМАТИЧЕСКИЙ УСТАНОВЩИК"
echo "=============================="
echo

# 1. Проверяем, что мы в my-workshop
if [ ! -d "scripts" ]; then
    echo "❌ Похоже, вы не в my-workshop."
    echo "   Установщик нужно запускать из каталога my-workshop."
    exit 1
fi

echo "✔ Установщик запущен из my-workshop"
echo

# 2. Определяем GitHub-репозиторий
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE_URL" ]; then
    echo "❌ Не удалось получить git remote origin."
    echo "   Убедитесь, что my-workshop — это git-репозиторий с привязкой к GitHub."
    exit 1
fi

# Ожидаем формат: https://github.com/username/repo.git
USER_REPO=$(echo "$REMOTE_URL" | sed -E 's#https://github.com/([^/]+/[^.]+)(\.git)?#\1#')
GITHUB_USER=$(echo "$USER_REPO" | cut -d'/' -f1)
GITHUB_REPO=$(echo "$USER_REPO" | cut -d'/' -f2)

echo "✔ Обнаружен GitHub-репозиторий:"
echo "  Пользователь: $GITHUB_USER"
echo "  Репозиторий: $GITHUB_REPO"
echo

# 3. Создаём чистую рабочую мастерскую
WORKSHOP=~/workshop

echo "📁 Создаю чистую рабочую мастерскую..."
rm -rf "$WORKSHOP"
mkdir -p "$WORKSHOP/scripts"

echo "✔ Папка workshop создана заново"
echo

# 4. Копируем скрипты
echo "📦 Копирую модули..."
cp scripts/*.sh "$WORKSHOP/scripts/"
chmod +x "$WORKSHOP/scripts/"*.sh
echo "✔ Модули скопированы"
echo

# 5. Генерируем files.txt с RAW-ссылками
FILES_TXT="$WORKSHOP/files.txt"
BRANCH="main"   # если у тебя ветка master — поменяем потом

echo "🧾 Генерирую files.txt..."
> "$FILES_TXT"

for file in scripts/*.sh; do
    name=$(basename "$file")
    raw_url="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$BRANCH/scripts/$name"
    echo "$name | $raw_url" >> "$FILES_TXT"
    echo "✔ $name → $raw_url"
done

echo
echo "✔ files.txt создан: $FILES_TXT"
echo

# 6. Создаём hashes.txt
echo "📄 Создаю hashes.txt..."
touch "$WORKSHOP/hashes.txt"
echo "✔ hashes.txt создан"
echo

# 7. Финальная проверка
echo "🔍 Проверяю структуру..."

if [ -d "$WORKSHOP/scripts" ] &&
   [ -f "$WORKSHOP/files.txt" ] &&
   [ -f "$WORKSHOP/hashes.txt" ]; then

    echo "=============================="
    echo "  ✔ УСТАНОВКА ЗАВЕРШЕНА"
    echo "=============================="
    echo "Рабочая мастерская готова:"
    echo "$WORKSHOP"
    echo
    echo "Теперь запускай:"
    echo "cd ~/workshop"
    echo "./scripts/update.sh"
else
    echo "❌ Что-то пошло не так — структура неполная."
fi
