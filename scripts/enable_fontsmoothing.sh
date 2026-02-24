cat > enable_fontsmoothing.sh <<'EOF'
#!/bin/bash

REG_FILE="fontsmoothing.reg"

cat > "$REG_FILE" <<EOL
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\\Control Panel\\Desktop]
"FontSmoothing"="2"
"FontSmoothingType"=dword:00000002
"FontSmoothingGamma"=dword:00000578
"FontSmoothingOrientation"=dword:00000001
EOL

echo "Файл $REG_FILE создан."

echo "Импорт в реестр Wine..."
wine regedit "$REG_FILE"

echo "Готово! 🎉 Попробуй перезапустить Wine-приложение, чтобы проверить результат."
EOF
