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

# Check if the user has root access
if [ "$EUID" -ne 0 ]; then
  echo $'\e[32mPlease run with root privileges.\e[0m'
  exit
fi


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
wk_dir=~/v2rayBot
config_dir=config
config_file=config.yml
git_url="https://github.com/iPmartNetwork/v2rayBot.git"

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error：${plain} Please run this script with root privilege \n " && exit 1

# Check OS and set release variable
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    release=$ID
elif [[ -f /usr/lib/os-release ]]; then
    source /usr/lib/os-release
    release=$ID
else
    echo "Failed to check the system OS, please contact the author!" >&2
    exit 1
fi

check_python() {
    if [[ $(python3 -c "import sys; print(sys.version_info[:2] >= (3, 10))") == "True" ]]; then
        curl -sS https://bootstrap.pypa.io/get-pip.py | python3
        python3 -m pip install --upgrade pip && python3 -m pip install --upgrade setuptools

        if [ -d "$wk_dir/$config_dir" ]; then
            cp -r $wk_dir/$config_dir/$config_file ~/
            rm -rf $wk_dir
            cd ~/ && git clone $git_url &&
            cp -r ~/$config_file $wk_dir/$config_dir && rm -rf ~/$config_file
        else
            rm -rf $wk_dir
            cd ~/ && git clone $git_url;
        fi

        (crontab -l; echo "*/3 * * * * python3 ~/v2ray-tel-bot/login.py"; echo "@reboot python3 ~/v2ray-tel-bot/bot.py"; echo "42 2 */2 * * rm -rf ~/v2ray-tel-bot/cookies.pkl") | sort -u | crontab -
    else 
        echo -e "${cyan}updating python version ${plain}\n"
        apt-get install -y software-properties-common && add-apt-repository -y ppa:deadsnakes/ppa && apt-get -y install python3.10 && unlink /usr/bin/python3 && ln -s /usr/bin/python3.10 /usr/bin/python3

        curl -sS https://bootstrap.pypa.io/get-pip.py | python3
        python3 -m pip install --upgrade pip && python3 -m pip install --upgrade setuptools

        if [ -d "$wk_dir/$config_dir" ]; then
            cp -r $wk_dir/$config_dir/$config_file ~/
            rm -rf $wk_dir
            cd ~/ && git clone $git_url &&
            cp -r ~/$config_file $wk_dir/$config_dir && rm -rf ~/$config_file
        else
            rm -rf $wk_dir
            cd ~/ && git clone $git_url;
        fi
        
        (crontab -l; echo "*/3 * * * * python3 ~/v2ray-tel-bot/login.py"; echo "@reboot python3 ~/v2ray-tel-bot/bot.py"; echo "42 2 */2 * * rm -rf ~/v2ray-tel-bot/cookies.pkl") | sort -u | crontab -
    
    fi

    pip install --ignore-installed PyYAML
    pip install -r $wk_dir/requirements.txt
    echo -e "\n${cyan}Edit 'config.yml' file, then restart the server with the 'reboot' command. The bot will start working after the server comes back up.${plain}"

}

install_base() {
    case "${release}" in
        centos|fedora)
            echo -e "${Purple}The script does not support CentOS-based operating systems ${plain}\n"
            ;;
        *)
            apt-get update && apt-get install -y git wget python3
            ;;
    esac
}

if [ -d "$wk_dir/$config_dir" ]; then
    echo -e "${cyan}Upgrade script...${plain}\n"
else
    echo -e "${cyan}install script...${plain}\n"
fi

install_base
check_python
