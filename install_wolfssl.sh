#!/bin/bash

# به‌روزرسانی سیستم و نصب پیش‌نیازها
echo "Updating system and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev curl git

# دانلود و نصب WolfSSL از GitHub (استفاده از URL اسکریپت شما)
echo "Downloading and installing WolfSSL..."
bash <(curl -s https://raw.githubusercontent.com/Tsepahvand/waterwall/main/install_wolfssl.sh)

# کلون کردن مخزن WaterWall
echo "Cloning WaterWall repository..."
if [ ! -d "WaterWall" ]; then
    git clone https://github.com/radkesvat/WaterWall.git
else
    echo "WaterWall repository already cloned."
fi

# نصب WaterWall
echo "Building and installing WaterWall..."
cd WaterWall
make
sudo make install
cd ..

# بررسی نصب بودن نرم‌افزارهای مورد نیاز
if ! command -v waterwall &> /dev/null; then
    echo "WaterWall نصب نشده است. لطفاً بررسی کنید و سپس دوباره تلاش کنید."
    exit 1
fi

if ! command -v wolfssl &> /dev/null; then
    echo "WolfSSL نصب نشده است. لطفاً بررسی کنید و سپس دوباره تلاش کنید."
    exit 1
fi

# دریافت اطلاعات از کاربر
read -p "آدرس سرور (IP یا دامنه): " server_address
read -p "پورت سرور: " server_port
read -p "نام کاربری: " username
read -sp "رمز عبور: " password
echo

# ایجاد فایل تنظیمات WaterWall
cat <<EOF > /tmp/waterwall.conf
server_address=$server_address
server_port=$server_port
username=$username
password=$password
EOF

# تنظیم دسترسی به فایل تنظیمات
chmod 600 /tmp/waterwall.conf

# اجرای WaterWall با تنظیمات WolfSSL
sudo waterwall --config /tmp/waterwall.conf --ssl

# پاک کردن فایل تنظیمات موقت
rm /tmp/waterwall.conf
