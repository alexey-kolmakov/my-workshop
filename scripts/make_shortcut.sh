#!/bin/bash
# INFO: [СИСТЕМА] ласкаво просимо до конструктора ярликів


echo "🎯 Добро пожаловать в конструктор ярлыков!"

# Название ярлыка
read -p "👉 Название ярлыка: " title

# Путь к файлу или папке
read -p "📁 Путь к файлу или папке: " target

# Куда сохранить ярлык
read -p "📂 Папка для сохранения ярлыка (по умолчанию: /home/peppermint/Стільниця/): " location
location=${location:-"/home/peppermint/Стільниця/"}

# Имя иконки (необязательно)
read -p "🎨 Имя иконки (шлях, або залишь порожним): " icon
icon=${icon:-text-x-generic}

# Имя .desktop-файла
desktop_file="${title// /_}.desktop"
desktop_path="$location/$desktop_file"

# Создание файла
cat <<EOF > "$desktop_path"
[Desktop Entry]
Version=1.0
Type=Application
Name=$title
Exec=xdg-open "$target"
Icon=$icon
Terminal=false
#Terminal=true
#Categories=Office;
#Categories=Education;
#Categories=TextEditor;Utility;
#Categories=Application;
StartupNotify=true
EOF

chmod +x "$desktop_path"

echo -e "\n✅ Ярлык '$title' создан по пути:/home/peppermint/Стільниця/"
