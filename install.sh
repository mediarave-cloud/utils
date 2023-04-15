#!/bin/bash
set -e

cat << "EOF"
#                         ___                           
#     ____ ___  ___  ____/ (_)___ __________ __   _____ 
#    / __ `__ \/ _ \/ __  / / __ `/ ___/ __ `/ | / / _ \
#   / / / / / /  __/ /_/ / / /_/ / /  / /_/ /| |/ /  __/
#  /_/ /_/ /_/\___/\__,_/_/\__,_/_/   \__,_/ |___/\___/ 
#                                                       
EOF

hostname=$(hostname)
ip_address=$(hostname -I | awk '{print $1}')
echo "# $hostname | $ip_address"

if [ -f /etc/os-release ]; then
    . /etc/os-release
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
else
    echo "---"
    echo "OS not supported. Exiting."
    echo "---"
    exit 1
fi

case $ID in
    debian|ubuntu)
        echo "---"
        echo "Installing... Please wait, this might take a while."
        echo "---"
        sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget unzip docker.io docker-compose > /dev/null 2>&1
        ;;
    fedora)
        echo "---"
        echo "Installing... Please wait, this might take a while."
        echo "---"
        sudo dnf install -y curl wget unzip docker-ce docker-ce-cli containerd.io docker-compose > /dev/null 2>&1
        sudo systemctl enable docker > /dev/null 2>&1
        sudo systemctl start docker > /dev/null 2>&1
        ;;
    *)
        echo "---"
        echo "OS not supported. Exiting."
        echo "---"
        exit 1
        ;;
esac

rm -f release.zip
rm -rf release

curl -O https://mediarave.cloud/release.zip > /dev/null 2>&1 || wget https://mediarave.cloud/release.zip > /dev/null 2>&1

unzip -q release.zip -d release

cd release

if command -v docker-compose >/dev/null 2>&1; then
docker-compose up -d > /dev/null 2>&1
else
docker compose up -d > /dev/null 2>&1
fi

echo "---"
echo "Mediarave installation completed successfully."
echo "---"

echo "Use the following address to access dashboard:"
echo "http://$ip_address/"
