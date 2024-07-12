#!/bin/bash

#!/bin/bash

echo  "
══════════════════════════════════════════════════════════════════════════════════════
        ____                             _     _                                     
    ,   /    )                           /|   /                                  /   
-------/____/---_--_----__---)__--_/_---/-| -/-----__--_/_-----------__---)__---/-__-
  /   /        / /  ) /   ) /   ) /    /  | /    /___) /   | /| /  /   ) /   ) /(    
_/___/________/_/__/_(___(_/_____(_ __/___|/____(___ _(_ __|/_|/__(___/_/_____/___\__

══════════════════════════════════════════════════════════════════════════════════════"

# Coler Code
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


# Function to show the menu
show_menu() {
    echo -e "${Purple}Please choose an option:${NC}"
    echo -e "${White}1. install x-ui${NC}"
    echo -e "${cyan}2. Restore Confing${NC}"
    echo -e "${White}0. Exit${NC}"
}

# Loop until the user chooses to exit
while true; do
    show_menu
    read -p "Enter choice [1-2-0]: " choice
    case $choice in
        1)
            clear
            bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
            ;;
        2)
            clear
            bash <(curl https://raw.githubusercontent.com/ipmartnetwork/xui/main/src/x-ui.sh)
            ;;
             0)
            echo "Exit"
            break
            ;;
        *)
            echo "Invalid choice! Please select a valid option."
            ;;
    esac
done
