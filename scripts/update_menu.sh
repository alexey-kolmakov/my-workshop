#!/bin/bash
# INFO: [АРХІВ] обhtmlливать папку


# 1. Выбор папки
TARGET_DIR=$(zenity --file-selection --directory --title="Какую папку обhtmlливать?")
[[ -z "$TARGET_DIR" ]] && exit 0

# 2. Переходим в выбранную папку - ЭТО ГЛАВНОЕ
cd "$TARGET_DIR" || exit

# 3. Названия
FOLDER_NAME=$(basename "$PWD")
OUTPUT="${FOLDER_NAME}.html"

# 4. Начало файла
cat << EOF > "$OUTPUT"
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Каталог: $FOLDER_NAME</title>
EOF

# 5. Стили (Защищенный блок)
cat << 'EOF' >> "$OUTPUT"
    <style>
        :root { --bg: #f3f4f6; --card-bg: #ffffff; --primary: #2563eb; --text: #374151; }
        body { background-color: var(--bg); color: var(--text); font-family: sans-serif; padding: 20px; margin: 0; }
        .container { max-width: 1200px; margin: 0 auto; }
        .search-box { width: 100%; padding: 15px; border: 2px solid #ddd; border-radius: 10px; font-size: 16px; margin-bottom: 25px; box-sizing: border-box; outline: none; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 15px; }
        .item { background: var(--card-bg); border-radius: 8px; padding: 12px; display: flex; align-items: center; text-decoration: none; color: inherit; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,0.1); transition: 0.2s; cursor: pointer; min-width: 0; }
        .item:hover { border-color: var(--primary); transform: translateY(-2px); }
        .icon { flex-shrink: 0; width: 32px; margin-right: 12px; text-align: center; font-size: 1.2em; }
        .name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 14px; }
        .folder { border-left: 4px solid #3b82f6; }
        .script { border-left: 4px solid #f59e0b; }
        .hidden { display: none !important; }
    </style>
</head>
<body>
    <div class="container">
        <input type="text" id="searchInput" class="search-box" placeholder="Поиск в $FOLDER_NAME..." onkeyup="filterFiles()">
        <div class="grid" id="fileGrid">
EOF

# 6. Сбор данных (используем простейший find .)
# ПАПКИ
find . -maxdepth 2 -not -path '*/.*' -type d | sort | while read -r item; do
    name="${item#./}"
    [[ -z "$name" || "$name" == "." ]] && continue
    echo "            <a class=\"item folder\" onclick=\"openHere('$name')\"><span class=\"icon\">📁</span> <span class=\"name\">$name</span></a>" >> "$OUTPUT"
done

# ФАЙЛЫ
find . -maxdepth 2 -not -path '*/.*' -type f | sort | while read -r item; do
    name="${item#./}"
    [[ "$name" == "$OUTPUT" || "$name" == "update_menu.sh" ]] && continue
    
   ICON="📜" # Иконка по умолчанию для всех остальных файлов
    CLASS="file"
    
    [[ "$name" == *.mp4 || "$name" == *.mkv || "$name" == *.avi ]] && ICON="📽️"
    [[ "$name" == *.mp3 || "$name" == *.wav || "$name" == *.flac ]] && ICON="🎵"
    [[ "$name" == *.xlsx || "$name" == *.csv ]] && ICON="📊"
    [[ "$name" == *.jpg || "$name" == *.png ]] && ICON="🖼️"
    [[ "$name" == *.zip || "$name" == *.tar* ]] && ICON="📦"
    [[ "$name" == *.rar ]] && ICON="🧰"
    [[ "$name" == *.iso ]] && ICON="💽"
    [[ "$name" == *.doc* ]] && ICON="📋"
    [[ "$name" == *.txt ]] && ICON="📝"
    [[ "$name" == *.pdf ]] && ICON="📕"
    [[ "$name" == *.sh ]] && { ICON="⚙️"; CLASS="script"; }

    echo "            <a class=\"item $CLASS\" onclick=\"openHere('$name')\"><span class=\"icon\">$ICON</span> <span class=\"name\">$name</span></a>" >> "$OUTPUT"
done

# 7. Финал (JS)
cat << 'EOF' >> "$OUTPUT"
        </div>
    </div>
    <script>
        function filterFiles() {
            const input = document.getElementById('searchInput').value.toLowerCase();
            document.querySelectorAll('.item').forEach(item => {
                const name = item.querySelector('.name').textContent.toLowerCase();
                item.classList.toggle('hidden', !name.includes(input));
            });
        }
        function openHere(path) {
            const currentPath = window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/'));
            window.location.href = "folder://" + decodeURIComponent(currentPath) + "/" + path;
        }
    </script>
</body>
</html>
EOF

notify-send "Готово" "Файл $OUTPUT создан в выбранной папке"
