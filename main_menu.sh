#!/bin/bash
# INFO: [WINE] Створення нового префікса


echo "🎛️ Створення нового префікса"

# 🔊 Звук відкриття меню
paplay /usr/share/sounds/freedesktop/stereo/service-login.oga 2>/dev/null

CHOICE=$(zenity --list \
  --title="🎛️ Bash-меню Wine-студії" \
  --window-icon="info" \
  --width=400 --height=300 \
  --column="Дія" \
  "🧱 Створити новий префікс" \
  "🚪 Вийти")
#"📦 Установити програму" \
# 🔊 Звук вибору
paplay /usr/share/sounds/freedesktop/stereo/dialog-question.oga 2>/dev/null

case "$CHOICE" in
  "🧱 Створити новий префікс")
    bash ~/SCRIPTS/Создание_Wine-префикса/create_wine_prefix.sh
    ;;

  "📦 Установити програму")
    bash ~/SCRIPTS/Установка_програм_в_Wine-префікс/install_program.sh
    ;;

  "🚪 Вийти")
    zenity --info --text="👋 До зустрічі, Олексій!"
    paplay /usr/share/sounds/freedesktop/stereo/service-logout.oga 2>/dev/null
    ;;

  *)
    echo "🚫 Скасовано."
    ;;
esac
