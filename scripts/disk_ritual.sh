# ОЧИСТКА ВСЕГО ДИСКА! ОСТОРОЖНО!
#!/bin/bash
# INFO: [УВАГА!] скрипт повністю очистить весь диск!


# 🌟 Ритуальний скрипт очищення та підготовки диска
# Автор: Олексій & Copilot

echo -e "\n========== 💾 Ритуал очищення диска ==========\n"

# 🔍 Показ доступних дисків (крім системного sda)
echo "📦 Доступні диски (крім системного):"
lsblk -dno NAME,SIZE,MODEL | grep -v sda
echo

# 👉 Вибір диска
read -p "🧠 Введи ім'я диска для ритуалу (наприклад, sdc): " disk
echo -e "\n🔎 Перевірка вибраного диска: /dev/$disk\n"
sudo fdisk -l /dev/$disk

read -p "❗ Це точно той диск? ВНИМАННЯ: все буде знищено! (yes/no): " confirm_disk
[[ "$confirm_disk" != "yes" ]] && echo "🚫 Ритуал скасовано. Диск не чіпали." && exit 1

# 🧹 Занулення
read -p "🧼 Занулити диск /dev/$disk? Це знищить ВСЕ. (yes/no): " confirm_dd
if [[ "$confirm_dd" == "yes" ]]; then
  echo -e "\n🧘‍♂️ Очищення почалося. Нехай минуле піде..."
  sudo dd if=/dev/zero of=/dev/$disk bs=1M status=progress
else
  echo "⏭️ Пропускаємо занулення."
fi

# 📐 GPT
read -p "📐 Створити нову таблицю розділів (GPT)? (yes/no): " confirm_gpt
[[ "$confirm_gpt" == "yes" ]] && sudo parted /dev/$disk mklabel gpt || echo "⏭️ Пропускаємо GPT."

# 📁 Створення розділу
read -p "📁 Створити основний розділ на весь диск? (yes/no): " confirm_part
[[ "$confirm_part" == "yes" ]] && sudo parted /dev/$disk mkpart primary ext4 0% 100% || echo "⏭️ Пропускаємо розділ."

# 🧙‍♂️ Вибір файлової системи
echo -e "\n📁 Доступні файлові системи:"
echo "1. ext4   (Linux, надійна)"
echo "2. xfs    (Linux, продуктивна)"
echo "3. fat32  (Windows, обмеження 4 ГБ)"
echo "4. exFAT  (Windows + Linux, універсальна)"
echo "5. ntfs   (Windows, стабільна)"

read -p "👉 Введи номер файлової системи: " fs_choice
case $fs_choice in
  1) fs_type="ext4" ;;
  2) fs_type="xfs" ;;
  3) fs_type="vfat" ;;
  4) fs_type="exfat" ;;
  5) fs_type="ntfs" ;;
  *) echo "⚠️ Невірний вибір. Використовуємо ext4."; fs_type="ext4" ;;
esac

# 🧪 Перевірка утиліти mkfs
if ! command -v mkfs.$fs_type &> /dev/null; then
  echo -e "\n⚠️ mkfs.$fs_type не знайдено!"
  case $fs_type in
    exfat) echo "👉 Встанови пакет: sudo apt install exfatprogs" ;;
    ntfs)  echo "👉 Встанови пакет: sudo apt install ntfs-3g" ;;
    xfs)   echo "👉 Встанови пакет: sudo apt install xfsprogs" ;;
    vfat)  echo "👉 Встанови пакет: sudo apt install dosfstools" ;;
  esac
  echo "🚫 Форматування неможливе без цієї утиліти."
  exit 1
fi

# 🏷️ Метка розділу
read -p "🏷️ Введи ритуальне ім'я диска (метку, напр. StudioDisk): " disk_label

# 🧾 Форматування
read -p "🧾 Форматувати /dev/${disk}1 в $fs_type з меткою '$disk_label'? (yes/no): " confirm_fs
if [[ "$confirm_fs" == "yes" ]]; then
  sudo mkfs.$fs_type -L "$disk_label" /dev/${disk}1
else
  echo "⏭️ Пропускаємо форматування."
fi

# ✅ Завершення
echo -e "\n🎉 Ритуал завершено! Диск /dev/$disk готовий до нової цифрової історії.\n"

