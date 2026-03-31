#!/bin/bash
# INFO: [СИСТЕМА] створює ярлик перетягуванням

if [ -n "$1" ]; then
  target="$1"
else
  read -e -p "📁 Путь к файлу или папке: " target
fi

if [ ! -e "$target" ]; then
  echo "❌ Указанный путь не существует: $target"
  exit 1
fi

title=$(basename "$target")
location="$(xdg-user-dir DESKTOP)"
mkdir -p "$location"
icon="application-x-executable"

if [[ "$target" == *.exe ]]; then
  exec_cmd="wine $target"
elif [[ "$target" == *.sh ]]; then
  exec_cmd="bash $target"
elif [[ -d "$target" ]]; then
  exec_cmd="xdg-open $target"
else
  exec_cmd="xdg-open $target"
fi

desktop_file="${title// /_}.desktop"
desktop_path="$location/$desktop_file"

cat <<EOF > "$desktop_path"
[Desktop Entry]
Version=1.0
Type=Application
#Type=Link
Name=$title
#Comment=$title
Exec="$exec_cmd"
#URL="$exec_cmd $url"
#Exec=exo-open --launch TerminalEmulator bash -c "$exec_cmd"
Icon=$icon
Terminal=false
#Terminal=true
Categories=Education;
#Categories=Application;
StartupNotify=true
EOF

chmod +x "$desktop_path"
echo -e "\n✅ Ярлык '$title' создан по пути: $desktop_path"

