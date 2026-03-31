#!/bin/bash
# INFO: [СИСТЕМА] Створює каталог вмісту папки


# 1. Выбор папки через окно
TARGET_DIR=$(zenity --file-selection --directory --title="Вибрати папку для каталогізації")

# Если нажали отмену - выходим
[[ -z "$TARGET_DIR" ]] && exit 0

# 2. Переходим в выбранную директорию
cd "$TARGET_DIR" || exit

# 3. Названия
FOLDER_NAME=$(basename "$PWD")
OUTPUT="${FOLDER_NAME}.html"

# 4. Генерируем "шапку" (тут переменные Bash ДОЛЖНЫ работать, поэтому EOF без кавычек)
cat << EOF > "$OUTPUT"
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Каталог: $FOLDER_NAME</title>
EOF

# 5. Добавляем стили (используем 'EOF' в кавычках, чтобы Bash НЕ ТРОГАЛ знаки $)
cat << 'EOF' >> "$OUTPUT"
    <style>
        :root {
            --bg: #f3f4f6;
            --card-bg: #ffffff;
            --primary: #2563eb;
            --text: #374151;
        }
        body { background-color: var(--bg); color: var(--text); font-family: sans-serif; padding: 20px; margin: 0; }
        .container { max-width: 1200px; margin: 0 auto; }
        .search-box { 
            width: 100%; padding: 15px; border: 2px solid #ddd; 
            border-radius: 10px; font-size: 16px; margin-bottom: 25px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05); box-sizing: border-box; outline: none;
        }
        .grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); 
            gap: 15px; 
        }
        .item { 
            background: var(--card-bg); border-radius: 8px; padding: 12px;
            display: flex; align-items: center; text-decoration: none; color: inherit;
            border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            transition: 0.2s; cursor: pointer; min-width: 0;
        }
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
        <input type="text" id="searchInput" class="search-box" placeholder="Поиск по названию..." onkeyup="filterFiles()">
        <div class="grid" id="fileGrid">
EOF

# 6. ГЕНЕРАЦИЯ СПИСКА (логика поиска файлов)
# Сначала папки
find . -maxdepth 2 -not -path '*/.*' -type d | sort | while read -r dir; do
    rel_dir="${dir#./}"
    [[ -z "$rel_dir" || "$rel_dir" == "." ]] && continue
    echo "            <a class=\"item folder\" onclick=\"openHere('$rel_dir')\"><span class=\"icon\">📁</span> <span class=\"name\">$rel_dir</span></a>" >> "$OUTPUT"
done

# Потом файлы
find . -maxdepth 2 -not -path '*/.*' -type f | sort | while read -r file; do
    rel_file="${file#./}"
    [[ "$rel_file" == "$OUTPUT" ]] && continue
    
    ICON="📄"
    CLASS="file"
    [[ "$rel_file" == *.jpg || "$rel_file" == *.png ]] && ICON="🖼️"
    [[ "$rel_file" == *.pdf ]] && ICON="📕"
    [[ "$rel_file" == *.docx ]] && ICON="📋"
    [[ "$rel_file" == *.txt ]] && ICON="📝"
    [[ "$rel_file" == *.sh ]] && { ICON="⚙️"; CLASS="script"; }

    echo "            <a class=\"item $CLASS\" onclick=\"openHere('$rel_file')\"><span class=\"icon\">$ICON</span> <span class=\"name\">$rel_file</span></a>" >> "$OUTPUT"
done

# 7. Финал (JS часть - тоже под защитой 'EOF')
cat << 'EOF' >> "$OUTPUT"
        </div>
    </div>
    <script>
        function filterFiles() {
            const input = document.getElementById('searchInput').value.toLowerCase();
            const items = document.querySelectorAll('.item');
            items.forEach(item => {
                const nameTag = item.querySelector('.name');
                if (nameTag) {
                    const fileName = nameTag.textContent.toLowerCase();
                    item.classList.toggle('hidden', !fileName.includes(input));
                }
            });
        }
        function openHere(path) {
            const dir = window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/'));
            window.location.href = "folder://" + dir + "/" + path;
        }
    </script>
</body>
</html>
EOF

notify-send "Готово!" "Каталог для папки $FOLDER_NAME создан."
