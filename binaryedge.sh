#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[1;32m'
ORANGE='\033[0;33m'


####################################
if [ "$EUID" -ne 0 ]              #### Check for root access else exit
  then echo "Please run as root." ##
  exit                            ##
fi                                ##
####################################

#####################################
chmod +x dataleaks_binaryedge.sh   #### Set execute permissions at BinaryEdge's scripts
chmod +x domains_binaryedge.sh     ##
chmod +x host_binaryedge.sh        ##
chmod +x image_binaryedge.sh       ##
chmod +x risk_score_binaryedge.sh  ##
chmod +x sensors_binaryedge.sh     ##
chmod +x torrent_binaryedge.sh     ##
#####################################

subscr_name(){
    sub_name=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$(cat binaryedge_api_v2.txt)" | jq '.subscription.name')
    sub_name_updt=$(echo "${sub_name//\"/}") # deletes "" in $sub_name
    if [[ "$sub_name_updt" == "null" ]]; then  # OSO to poso twn requests einai null, diavaze kainoutio API
        while [[ "$sub_name_updt" == "null" ]]; do
            printf "Write your API key here:"; read new_api_key
            echo "$new_api_key" > binaryedge_api_v2.txt
            sub_name=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$(cat binaryedge_api_v2.txt)" | jq '.subscription.name')
            sub_name_updt=$(echo "${sub_name//\"/}")
        done
    fi
    echo -e "${RED}================================"
    echo -e "Subscription name: $sub_name_updt" 
    echo -e "================================${NC}"
}

reqs_func(){ #shows your requests that left
    reqs_left=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$(cat binaryedge_api_v2.txt)" | jq '.requests_left')
    if [[ "$reqs_left" == "null" ]]; then  # OSO to poso twn requests einai null, diavaze kainoutio API
        while [[ "$reqs_left" == "null" ]]; do
            printf "Write your API key here:"; read new_api_key
            echo "$new_api_key" > binaryedge_api_v2.txt
            reqs_left=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$(cat binaryedge_api_v2.txt)" | jq '.requests_left')
        done
    fi
    echo -e "${RED}==================="
    echo -e "Requests left: $reqs_left" 
    echo -e "===================${NC}"
    echo
}

current_version="1.1" # Current version

#############################################################
binaryedge_started="TRUE"                                  #### Give the info to the subscripts that you started from here
export exported_binaryedge_started="$binaryedge_started"   ##
#############################################################

BinaryEdge_logo(){
echo
echo -e "          ||       =====================            =====================       ||"
echo -e "          ||          =====================      =====================          ||"
echo -e "          ||           ======================  ======================           ||"
echo -e "          ||                             ====  ====                             ||"
echo -e "          ||                            =====  =====                            ||"
echo -e "          ||           ======================  ======================           ||"
echo -e "          ||          =====================      =====================          ||"
echo -e "          ||          =====================      =====================          ||"
echo -e "          ||           ======================  ======================           ||"
echo -e "          ||                             ====  ====                             ||"
echo -e "          ||                            =====  =====                            ||"
echo -e "          ||           ======================  ======================           ||"
echo -e "          ||          =====================      =====================          ||"
echo -e "          ||       =====================            =====================       ||"
echo
echo
echo -e " 888888b.   d8b                                    8888888888      888                   "
echo -e " 888   88b  Y8P                                    888             888                   "
echo -e " 888  .88P                                         888             888                   "
echo -e " 8888888K.  888 88888b.   8888b.  888d888 888  888 8888888     .d88888  .d88b.   .d88b.  "
echo -e " 888   Y88b 888 888  88b      88b 888P    888  888 888        d88  888 d88P 88b d8P  Y8b "
echo -e " 888    888 888 888  888 .d888888 888     888  888 888        888  888 888  888 88888888 "
echo -e " 888   d88P 888 888  888 888  888 888     Y88b 888 888        Y88b 888 Y88b 888 Y8b.     "
echo -e " 8888888P   888 888  888  Y888888 888       Y88888 8888888888   Y88888   Y88888   Y8888  "
echo -e "                                               888                          888          "
echo -e "                                          Y8b d88P                     Y8b d88P          "
echo -e "                                            Y88P                         Y88P            "
}
BinaryEdge_logo
show_API_info(){
subscr_name #shows your subscription name
reqs_func #shows your requests that left
}
show_API_info

show_menu(){
echo "==========  Services  =========="
echo "==         1) Host            =="
echo "==         2) Image           =="
echo "==         3) Torrents        =="
echo "==         4) Dataleaks       =="
echo "==         5) Risk Score      =="
echo "==         6) Domains         =="
echo "==         7) Sensors         =="
echo "================================"
}
show_menu

BinaryEdgeMenu(){
binaryedge_api_key=$(cat binaryedge_api_v2.txt)
export exported_sub_name_updt="$sub_name_updt"



printf "/ >>> "; read option # read binary_edge_menu_option



if [[ "$option" == 1 ]]; then
    choosen_category="Host"
    export exp_choosen_category="${choosen_category}"
    ./host_binaryedge.sh

elif [[ "$option" == 2 ]]; then
    choosen_category="Image"
    export exp_choosen_category="${choosen_category}"
    ./image_binaryedge.sh

elif [[ "$option" == 3 ]]; then
    if [[ "$sub_name_updt" == "Free" ]]; then # if subscription is free,then do not allow history options
        echo -e "${RED}You have to have paid subscription to use Torrent feature!${NC}"
        BinaryEdgeMenu
    else
        choosen_category="Torrent"
        export exp_choosen_category="${choosen_category}"
        ./torrent_binaryedge.sh
    fi

elif [[ "$option" == 4 ]]; then
    if [[ "$sub_name_updt" == "Free" ]]; then # if subscription is free,then do not allow history options
        echo -e "${RED}You have to have paid subscription to use Torrent feature!${NC}"
        BinaryEdgeMenu
    else
        choosen_category="Dataleaks"
        export exp_choosen_category="${choosen_category}"
        ./dataleaks_binaryedge.sh
    fi

elif [[ "$option" == 5 ]]; then
    if [[ "$sub_name_updt" == "Free" ]]; then # if subscription is free,then do not allow history options
        echo -e "${RED}You have to have paid subscription to use Torrent feature!${NC}"
        BinaryEdgeMenu
    else
    choosen_category="Risk Score"
    export exp_choosen_category="${choosen_category}"
    ./risk_score_binaryedge.sh
    fi

elif [[ "$option" == 6 ]]; then
    choosen_category="Domains"
    export exp_choosen_category="${choosen_category}"
    ./domains_binaryedge.sh

elif [[ "$option" == 7 ]]; then
    choosen_category="Sensors"
    export exp_choosen_category="${choosen_category}"
    ./sensors_binaryedge.sh

elif [[ "$option" == "pkg_check" ]]; then
    which gnome-terminal 1> /dev/null 
    if [[ $? != 0 ]]; then
      echo -e "${RED}gnome-terminal is not installed!${NC}"
      apt-get install gnome-terminal;
      else 
    echo -e "${RED}gnome-terminal${GREEN} is installed. Make sure to keep it up-to-date.${NC}"
    fi

    which jq 1> /dev/null 
    if [[ $? != 0 ]]; then
      echo -e "${RED}jq ins not installed${NC}"
      sudo apt-get install jq
    else
      echo -e "${RED}jq ${GREEN} is installed${NC}"
    fi

    BinaryEdgeMenu
elif [[  "$option" == "updt_check" ]]; then

    wget -q --tries=10 --timeout=20 --spider https://raw.githubusercontent.com/JimChr-R4GN4R/BinaryEdgeAPIv2-Script/master/.version # check if have access with the repo

    if [[ $? -eq 0 ]]; then # if connected with the repo

        last_version=$(curl  -s -L https://raw.githubusercontent.com/JimChr-R4GN4R/BinaryEdgeAPIv2-Script/master/.version) # get's last version number
        echo "Latest Version: $last_version"
        echo "Current Version: $current_version"
        echo "If you have outdated version, then download the latest version by downloading it here: https://github.com/JimChr-R4GN4R/BinaryEdgeAPIv2-Script" 
        BinaryEdgeMenu
    else # if not connected with the repo

            echo "You have not access with the repository or your connection is low. Please try again..."
            BinaryEdgeMenu
    fi


elif [[ "$option" == "help" ]]; then
    echo "pkg_check /// Check if you have the required packages for the script."
    echo "updt_check /// Check if you have the latest version"
    echo "clear /// type this command to clear your screen"
    BinaryEdgeMenu

elif [[ "$option" == "" ]]; then
    BinaryEdgeMenu

elif [[ "$option" == "clear" ]]; then
    clear
    show_menu
    BinaryEdgeMenu
    
elif [[ "$option" == "exit" ]]; then
	exit

else
    echo -e "${ORANGE}Invalid option! Please try again...${NC}"
    show_menu
    BinaryEdgeMenu

fi


}
BinaryEdgeMenu

#Thanks Igama, Balgan and frbexiga for their support!
