#!/bin/bash
# INFO:[СОРТУВАННЯ] для роботи з PDF та зображеннями


# Расширенный комбайн для работы с PDF и изображениями
# Автор: Олексій + Copilot :)

INPUT_DIR="$HOME/pdf_input"
OUTPUT_IMG2PDF="$INPUT_DIR/combined.pdf"
OUTPUT_PDFMERGE="$INPUT_DIR/merged.pdf"
OUTPUT_EXTRACT_DIR="$INPUT_DIR/extracted_images"

echo "📋 Выбери режим работы:"
echo "1 - Собрать изображения (jpg/png) в PDF"
echo "2 - Объединить PDF файлы в один"
echo "3 - Извлечь изображения из PDF"
read -p "👉 Введи номер режима: " MODE

case $MODE in
  1)
    # --- Сборка изображений в PDF ---
    if ! command -v img2pdf &> /dev/null; then
        echo "❌ Утилита img2pdf не найдена. Установи её: sudo apt install img2pdf"
        exit 1
    fi
    FILES=$(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \))
    if [ -z "$FILES" ]; then
        echo "⚠️ Нет изображений (jpg/png) для сборки в $INPUT_DIR"
        exit 1
    fi
    echo "📋 Найденные изображения:"
    echo "$FILES" | while read f; do
        echo "   • $(basename "$f")"
    done
    echo "📂 Собираю изображения в PDF..."
    eval img2pdf $FILES -o "\"$OUTPUT_IMG2PDF\""
    if [ -f "$OUTPUT_IMG2PDF" ]; then
        SIZE=$(du -h "$OUTPUT_IMG2PDF" | cut -f1)
        COUNT=$(echo "$FILES" | wc -l)
        echo "✅ Готово! Файл: $OUTPUT_IMG2PDF (страниц: $COUNT, размер: $SIZE)"
    else
        echo "❌ Ошибка: PDF не был создан."
    fi
    ;;
  2)
    # --- Объединение PDF ---
    if ! command -v pdfunite &> /dev/null; then
        echo "❌ Утилита pdfunite не найдена. Установи её: sudo apt install poppler-utils"
        exit 1
    fi
    FILES=()
    while IFS= read -r f; do
        FILES+=("$f")
    done < <(find "$INPUT_DIR" -maxdepth 1 -type f -iname "*.pdf")

    if [ ${#FILES[@]} -eq 0 ]; then
        echo "⚠️ Нет PDF файлов для объединения в $INPUT_DIR"
        exit 1
    fi

    echo "📋 Найденные PDF для объединения:"
    for f in "${FILES[@]}"; do
        echo "   • $(basename "$f")"
    done

    echo "📂 Объединяю PDF файлы..."
    pdfunite "${FILES[@]}" "$OUTPUT_PDFMERGE"

    if [ -f "$OUTPUT_PDFMERGE" ]; then
        SIZE=$(du -h "$OUTPUT_PDFMERGE" | cut -f1)
        COUNT=$(pdfinfo "$OUTPUT_PDFMERGE" | grep Pages | awk '{print $2}')
        echo "✅ Готово! Файл: $OUTPUT_PDFMERGE (страниц: $COUNT, размер: $SIZE)"
    else
        echo "❌ Ошибка: объединённый PDF не был создан."
    fi
    ;;
  3)
    # --- Извлечение изображений из PDF ---
    if ! command -v pdftoppm &> /dev/null; then
        echo "❌ Утилита pdftoppm не найдена. Установи её: sudo apt install poppler-utils"
        exit 1
    fi
    FILES=$(find "$INPUT_DIR" -maxdepth 1 -type f -iname "*.pdf")
    if [ -z "$FILES" ]; then
        echo "⚠️ Нет PDF файлов для извлечения изображений в $INPUT_DIR"
        exit 1
    fi
    mkdir -p "$OUTPUT_EXTRACT_DIR"
    echo "📋 Найденные PDF для извлечения:"
    echo "$FILES" | while read f; do
        echo "   • $(basename "$f")"
    done
    for f in $FILES; do
        BASENAME=$(basename "$f" .pdf)
        echo "📂 Извлекаю страницы из $f..."
        pdftoppm -png "$f" "$OUTPUT_EXTRACT_DIR/$BASENAME"
    done
    echo "✅ Изображения сохранены в $OUTPUT_EXTRACT_DIR"
    ;;
  *)
    echo "❌ Неверный выбор режима."
    ;;
esac

echo "🔚 Работа завершена. Нажми Enter, чтобы закрыть окно..."
read
