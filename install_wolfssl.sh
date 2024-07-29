#!/bin/bash

# به‌روزرسانی سیستم و نصب پیش‌نیازها
echo "Updating system and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev curl git

# نصب WolfSSL از سورس کد
if ! command -v wolfssl &> /dev/null; then
    echo "Installing WolfSSL..."
    wget https://github.com/wolfSSL/wolfssl/archive/refs/tags/v5.3.0-stable.tar.gz -O wolfssl.tar.gz
    tar -xzf wolfssl.tar.gz
    cd wolfssl-5.3.0-stable
    ./configure
    make
    sudo make install
    cd ..
    rm -rf wolfssl-5.3.0-stable wolfssl.tar.gz
fi

# نصب Waterwall از سورس کد (فرض می‌کنیم مخزن GitHub دارد)
if ! command -v waterwall &> /dev/null; then
    echo "Installing Waterwall..."
    git clone https://github.com/ahmteam/waterwall.git
    cd waterwall
    ./configure
    make
    sudo make install
    cd ..
    rm -rf waterwall
fi

# بررسی نصب بودن نرم‌افزارهای مورد نیاز
if ! command -v waterwall &> /dev/null; then
    echo "Waterwall نصب نشده است. لطفاً بررسی کنید و سپس دوباره تلاش کنید."
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

# ایجاد فایل تنظیمات Waterwall
cat <<EOF > /tmp/waterwall.conf
server_address=$server_address
server_port=$server_port
username=$username
password=$password
EOF

# تنظیم دسترسی به فایل تنظیمات
chmod 600 /tmp/waterwall.conf

# اجرای Waterwall با تنظیمات WolfSSL
sudo waterwall --config /tmp/waterwall.conf --ssl

# پاک کردن فایل تنظیمات موقت
rm /tmp/waterwall.conf
