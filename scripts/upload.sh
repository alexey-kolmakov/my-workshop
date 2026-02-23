#!/bin/bash
# upload.sh — загрузка обновлённых модулей на GitHub

echo "⬆ Загрузка изменений на GitHub..."
echo

git add scripts/*.sh files.txt
git status

echo
read -p "Введите сообщение коммита: " msg

git commit -m "$msg"
git push

echo
echo "✅ Загрузка завершена!"
