#!/bin/bash
# INFO: [АРХІВ] модуль діагностики майстерні


# diagnostics.sh — модуль диагностики мастерской

echo "=============================="
echo "   ДИАГНОСТИКА МАСТЕРСКОЙ"
echo "=============================="
echo

# 1. Где мы находимся
echo "📍 Текущая директория:"
pwd
echo

# 2. Проверка Git
echo "🔍 Проверка Git:"
if [ -d ".git" ]; then
    echo "✔ Git-репозиторий найден"
    echo "   Текущая ветка: $(git branch --show-current)"
else
    echo "❌ Git-репозиторий НЕ найден"
    exit 1
fi
echo

# 3. Статус Git
echo "📦 Статус Git:"
git status --short
if [ $? -eq 0 ]; then
    echo "(Если список пуст — всё чисто)"
fi
echo

# 4. Последний коммит
echo "🕒 Последний коммит:"
git log -1 --pretty=format:"%h — %s (%ci)"
echo
echo

# 5. Список модулей
echo "🧩 Модули в scripts/:"
ls -1 scripts/
echo

# 6. Проверка files.txt
echo "📄 Содержимое files.txt:"
if [ -f "files.txt" ]; then
    cat files.txt
else
    echo "❌ Файл files.txt отсутствует"
fi
echo

# 7. Проверка связи с GitHub
echo "🌐 Проверка связи с GitHub:"
git ls-remote --heads origin &> /dev/null
if [ $? -eq 0 ]; then
    echo "✔ GitHub доступен"
else
    echo "❌ Нет связи с GitHub"
fi
echo

echo "=============================="
echo "   ДИАГНОСТИКА ЗАВЕРШЕНА"
echo "=============================="
