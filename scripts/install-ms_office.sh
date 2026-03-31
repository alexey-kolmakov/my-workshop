#!/bin/bash
# INFO: [WINE] встановлення ms_office в wine


# 📁 Настройки
PREFIX="$HOME/wine/office"
INSTALLER="$HOME/installers/ms_office_2007.exe"  # ← Убедись, что путь корректный
DESKTOP_FILE="$HOME/.local/share/applications/msword.desktop"

echo "🔧 Старт установки Microsoft Word..."

# 🧼 Удаление старого префикса
if [ -d "$PREFIX" ]; then
  echo "🧹 Удаление старого Wine-префикса..."
  rm -rf "$PREFIX"
fi

# 📦 Проверка установочного файла
if [ ! -f "$INSTALLER" ]; then
  echo "❌ Установочный файл не найден: $INSTALLER"
  exit 1
fi

# 🔐 Проверка и установка winbind (для NTLM)
if ! command -v ntlm_auth &> /dev/null; then
  echo "⚠️ Не найден ntlm_auth. Устанавливаю winbind..."
  sudo apt install -y winbind
fi

# 🧙 Создание нового Wine-префикса
echo "📁 Создание нового Wine-префикса..."
WINEPREFIX="$PREFIX" WINEARCH=win64 winecfg -v win7

# 📚 Установка необходимых компонентов
echo "📦 Установка библиотек через winetricks..."
WINEPREFIX="$PREFIX" winetricks -q corefonts msxml6 gdiplus riched20 dotnet45 vcrun2010 ole32

# ⏸️ Пауза перед установкой
echo "📥 Готов к установке Office. Нажми Enter для продолжения..."
read

# 🚀 Запуск установщика
echo "🚀 Установка Microsoft Office..."
WINEPREFIX="$PREFIX" wine "$INSTALLER"

# 🖼️ Создание ярлыка
echo "📝 Создание .desktop-файла для Word..."
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Microsoft Word
Exec=env WINEPREFIX="$PREFIX" wine "C:\\\\Program Files (x86)\\\\Microsoft Office\\\\Office12\\\\WINWORD.EXE" Z:\\\\%f
Type=Application
StartupNotify=true
MimeType=application/vnd.openxmlformats-officedocument.wordprocessingml.document;
Icon=word
Categories=Office;
EOF

# 🔗 Назначение ассоциации
echo "🔗 Назначение Word как обработчика .docx..."
xdg-mime default msword.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document

echo "✅ Установка завершена! Word готов к запуску и двойному клику."
