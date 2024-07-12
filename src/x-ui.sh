#!/bin/bash

# Color codes
Purple='\033[0;35m'
Cyan='\033[0;36m'
cyan='\033[0;36m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
White='\033[0;96m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to update system and install sqlite3
install_dependencies() {
    echo -e "${cyan}Updating package list...${NC}"
    sudo apt update -y

    echo -e "${cyan}Installing openssl...${NC}"
    sudo apt install -y openssl

    echo -e "${cyan}Installing jq...${NC}"
    sudo apt install -y jq

    echo -e "${cyan}Installing curl...${NC}"
    sudo apt install -y curl

    echo -e "${cyan}Installing ufw...${NC}"
    sudo apt install -y ufw

    sudo apt -y install apt-transport-https locales apt-utils bash-completion libssl-dev socat

    sudo apt -y -q autoclean
    sudo apt -y clean
    sudo apt -q update
    sudo apt -y autoremove --purge
}

fix_etc_hosts(){
  echo
  yellow_msg "Fixing Hosts file."
  sleep 0.5

  cp $HOST_PATH /etc/hosts.bak
  yellow_msg "Default hosts file saved. Directory: /etc/hosts.bak"
  sleep 0.5

  # shellcheck disable=SC2046
  if ! grep -q $(hostname) $HOST_PATH; then
    echo "127.0.1.1 $(hostname)" | sudo tee -a $HOST_PATH > /dev/null
    green_msg "Hosts Fixed."
    echo
    sleep 0.5
  else
    green_msg "Hosts OK. No changes made."
    echo
    sleep 0.5
  fi
}

fix_dns(){
    echo
    yellow_msg "Fixing DNS Temporarily."
    sleep 0.5

    cp $DNS_PATH /etc/resolv.conf.bak
    yellow_msg "Default resolv.conf file saved. Directory: /etc/resolv.conf.bak"
    sleep 0.5

    sed -i '/nameserver/d' $DNS_PATH

    echo "nameserver 8.8.8.8" >> $DNS_PATH
    echo "nameserver 8.8.4.4" >> $DNS_PATH

    green_msg "DNS Fixed Temporarily."
    echo
    sleep 0.5
}

clear
# Function to display ASCII logo
display_logo() {
    echo -e "${Purple}"
    cat << "EOF"
          
                 
══════════════════════════════════════════════════════════════════════════════════════
        ____                             _     _                                     
    ,   /    )                           /|   /                                  /   
-------/____/---_--_----__---)__--_/_---/-| -/-----__--_/_-----------__---)__---/-__-
  /   /        / /  ) /   ) /   ) /    /  | /    /___) /   | /| /  /   ) /   ) /(    
_/___/________/_/__/_(___(_/_____(_ __/___|/____(___ _(_ __|/_|/__(___/_/_____/___\__

══════════════════════════════════════════════════════════════════════════════════════
EOF
    echo -e "${NC}"
}

# Function to display server location and IP
display_server_info() {
    echo -e "\e[93m═════════════════════════════════════════════\e[0m"  
    echo -e "${cyan}Server Country:${NC} $SERVER_COUNTRY"
    echo -e "${cyan}Server IP:${NC} $SERVER_IP"
    echo -e "${cyan}Server ISP:${NC} $SERVER_ISP"
}

# Detect Ubuntu version
. /etc/os-release

# Check if the script is being run on Ubuntu
if [[ "$ID" != "ubuntu" ]]; then
    echo "This script is only for Ubuntu systems."
    exit 1
fi

# Install packages based on Ubuntu version
echo "Starting package installation for Ubuntu version $VERSION_ID..."
case "$VERSION_ID" in
    "24.04")
        echo "Updating package list..."
        apt update >/dev/null 2>&1
        echo "Installing HWE kernel for 24.04..."
        apt install --install-recommends linux-generic-hwe-24.04 -y >/dev/null 2>&1
        ;;
    "23.10")
        echo "Updating package list..."
        apt update >/dev/null 2>&1
        echo "Installing HWE kernel for 23.10..."
        apt install --install-recommends linux-generic-hwe-23.10 -y >/dev/null 2>&1
        ;;
    "22.04")
        echo "Updating package list..."
        apt update >/dev/null 2>&1
        echo "Installing HWE kernel for 22.04..."
        apt install --install-recommends linux-generic-hwe-22.04 -y >/dev/null 2>&1
        ;;
    "20.04")
        echo "Updating package list..."
        apt update >/dev/null 2>&1
        echo "Installing HWE kernel for 20.04..."
        apt install --install-recommends linux-generic-hwe-20.04 -y >/dev/null 2>&1
        ;;
    *)
        echo "Unsupported Ubuntu version: $VERSION_ID"
        exit 1
        ;;
esac

# Apply BBR settings
echo "Applying BBR settings..."
modprobe tcp_bbr >/dev/null 2>&1
echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p >/dev/null 2>&1
sysctl net.ipv4.tcp_available_congestion_control >/dev/null 2>&1
sysctl net.ipv4.tcp_congestion_control >/dev/null 2>&1
lsmod | grep bbr >/dev/null 2>&1

echo "BBR has been configured successfully."

# Detect system architecture
echo "Detecting system architecture..."
ARCH=$(uname -m)
case "${ARCH}" in
  x86_64 | x64 | amd64) XUI_ARCH="amd64" ;;
  i*86 | x86) XUI_ARCH="386" ;;
  armv8* | armv8 | arm64 | aarch64) XUI_ARCH="arm64" ;;
  armv7* | armv7) XUI_ARCH="armv7" ;;
  armv6* | armv6) XUI_ARCH="armv6" ;;
  armv5* | armv5) XUI_ARCH="armv5" ;;
  s390x) echo 's390x' ;;
  *) XUI_ARCH="amd64" ;;
esac

# Download and install x-ui
echo "Downloading and installing x-ui..."
cd /root/
wget -q https://github.com/MHSanaei/3x-ui/releases/latest/download/x-ui-linux-${XUI_ARCH}.tar.gz >/dev/null 2>&1
rm -rf x-ui/ /usr/local/x-ui/ /usr/bin/x-ui >/dev/null 2>&1
tar zxvf x-ui-linux-${XUI_ARCH}.tar.gz >/dev/null 2>&1
rm -rf /root/x-ui-linux-amd64.tar.gz >/dev/null 2>&1
chmod +x x-ui/x-ui x-ui/bin/xray-linux-* x-ui/x-ui.sh >/dev/null 2>&1
cp x-ui/x-ui.sh /usr/bin/x-ui >/dev/null 2>&1
cp -f x-ui/x-ui.service /etc/systemd/system/ >/dev/null 2>&1
mv x-ui/ /usr/local/ >/dev/null 2>&1
systemctl daemon-reload >/dev/null 2>&1
systemctl enable x-ui >/dev/null 2>&1

# Prompt user for WARP or Direct
read -p "Do you want to use WARP or Direct? (warp/direct, default: direct): " choice

# Set default choice to "direct"
choice=${choice:-direct}

# Download and replace the x-ui database based on user's choice
echo "Configuring x-ui database for $choice..."
rm -f /etc/x-ui/x-ui.db >/dev/null 2>&1
if [[ "$choice" == "warp" ]]; then
    echo "Configuring x-ui database for WARP..."
    wget -q -O /etc/x-ui/x-ui.db https://github.com/iPmartNetwork/easy-xui/raw/main/x-ui/db/warp.db  >/dev/null 2>&1
    systemctl restart x-ui >/dev/null 2>&1
    # Run setup_warproxy.sh script in the background without showing any output
    nohup curl -s https://raw.githubusercontent.com/iPmartNetwork/easy-xui/main/warp/setup_warproxy.sh | bash >/dev/null 2>&1 
    echo ""
else
    echo "Configuring x-ui database for Direct..."
    wget -q -O /etc/x-ui/x-ui.db https://github.com/iPmartNetwork/easy-xui/raw/main/x-ui/db/direct.db >/dev/null 2>&1
fi

# Restart x-ui service
echo "Restarting x-ui service..."
systemctl restart x-ui >/dev/null 2>&1

echo "x-ui has been installed, configured, and started successfully"
