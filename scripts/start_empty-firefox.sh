#!/bin/bash
# INFO: [СИСТЕМА] Відкриває нову вкладку у існуючому вікні FirefoxPortable


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
FIREFOX_BIN="$BASE_DIR/FirefoxPortable/firefox/firefox"

if [ ! -f "$FIREFOX_BIN" ]; then
    echo "Ошибка: Браузер не найден"
    exit 1
fi

# -new-tab открывает новую вкладку в существующем окне
"$FIREFOX_BIN" -new-tab "about:blank"
