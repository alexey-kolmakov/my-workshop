#!/bin/bash
# INFO: [АРХІВ] оновлення майстерні з перевіркою та відновленням


# update.sh — обновление мастерской с проверкой хэшей, ошибок и восстановлением повреждённых модулей

echo "🔄 Обновление мастерской..."
echo

# 1. Проверка интернета
echo "🌐 Проверка интернета..."
ping -c 1 github.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Нет соединения с интернетом!"
    exit 1
fi
echo "✔ Интернет доступен"
echo

# 2. Проверка files.txt
if [ ! -f "files.txt" ]; then
    echo "❌ Файл files.txt отсутствует!"
    exit 1
fi

if [ ! -s "files.txt" ]; then
    echo "❌ Файл files.txt пуст!"
    exit 1
fi

echo "✔ files.txt найден"
echo

# 3. Проверка hashes.txt
if [ ! -f "hashes.txt" ]; then
    echo "⚠ hashes.txt отсутствует — создаю..."
    touch hashes.txt
fi

echo "✔ hashes.txt готов"
echo

# 4. Обработка каждого файла
while IFS="|" read -r filename url; do
    filename=$(echo "$filename" | xargs)
    url=$(echo "$url" | xargs)

    if [ -z "$filename" ] || [ -z "$url" ]; then
        continue
    fi

    echo "📄 Проверяю $filename..."

    local_file="scripts/$filename"

    # Проверка существования файла
    if [ ! -f "$local_file" ]; then
        echo "❌ Файл отсутствует — восстанавливаю..."
        curl -s -L "$url" -o "$local_file"
        new_hash=$(sha256sum "$local_file" | awk '{print $1}')
        sed -i "/^$filename |/d" hashes.txt
        echo "$filename | $new_hash" >> hashes.txt
        echo "✔ Восстановлено"
        echo
        continue
    fi

    # Проверка, что файл не пустой
    if [ ! -s "$local_file" ]; then
        echo "❌ Файл пуст — восстанавливаю..."
        curl -s -L "$url" -o "$local_file"
        new_hash=$(sha256sum "$local_file" | awk '{print $1}')
        sed -i "/^$filename |/d" hashes.txt
        echo "$filename | $new_hash" >> hashes.txt
        echo "✔ Восстановлено"
        echo
        continue
    fi

    # Скачиваем удалённую версию во временный файл
    curl -s -L "$url" -o "/tmp/$filename"
    if [ $? -ne 0 ] || [ ! -s "/tmp/$filename" ]; then
        echo "❌ Ошибка скачивания удалённой версии"
        echo
        continue
    fi

    # Хэши
    remote_hash=$(sha256sum "/tmp/$filename" | awk '{print $1}')
    local_hash=$(grep "^$filename |" hashes.txt | awk '{print $3}')

    # Если хэши совпадают
    if [ "$remote_hash" = "$local_hash" ]; then
        echo "✔ Без изменений"
        echo
        continue
    fi

    # Если хэши разные — обновляем
    echo "⚠ Файл повреждён или изменён — обновляю..."
    mv "/tmp/$filename" "$local_file"
    sed -i "/^$filename |/d" hashes.txt
    echo "$filename | $remote_hash" >> hashes.txt
    echo "✔ Обновлено"
    echo

done < files.txt

echo "✅ Обновление завершено!"
