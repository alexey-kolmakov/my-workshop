#!/bin/bash

WORKSHOP="$HOME/workshop"
DESKTOP_DIR="$WORKSHOP/desktop"
LOCAL_APPS="$HOME/.local/share/applications"

mkdir -p "$DESKTOP_DIR"

echo "🔄 Обновление ярлыков..."

while IFS="|" read -r name url; do
    name=$(echo "$name" | xargs)
    url=$(echo "$url" | xargs)

    if [[ "$name" == *.desktop ]]; then
        echo "📄 $name"
        curl -s -L "$url" -o "$DESKTOP_DIR/$name"
        cp "$DESKTOP_DIR/$name" "$LOCAL_APPS/"
    fi
done < "$WORKSHOP/files.txt"

echo "✔ Ярлыки обновлены"
