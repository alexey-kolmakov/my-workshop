#!/bin/bash
# INFO:[АРХІВ] оновлення хешів майстерні


# hash.sh — обновление хэшей мастерской

HASHFILE="hashes.txt"

echo "🔍 Обновление хэшей..."

for file in scripts/*.sh; do
    name=$(basename "$file")
    hash=$(sha256sum "$file" | awk '{print $1}')

    # Удаляем старую запись
    sed -i "/^$name |/d" "$HASHFILE"

    # Добавляем новую
    echo "$name | $hash" >> "$HASHFILE"

    echo "✔ $name → $hash"
done

echo
echo "✅ Хэши обновлены!"
