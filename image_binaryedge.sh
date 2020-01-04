#!/bin/bash
###################################################################Standards####################################################################################
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[1;32m'
ORANGE='\033[0;33m'

###########################################################
if [[ "$exported_binaryedge_started" != "TRUE" ]]; then  #### Check if started from the right file
    echo -e "${RED}Execute binaryedge.sh file!${NC}"     ##
    exit                                                 ##
fi                                                       ##
###########################################################

binaryedge_api_key=$(cat binaryedge_api_v2.txt)

BinaryEdgeMenu(){
cd .. # go from BinaryEdge/Host to BinaryEdge
./binaryedge.sh
}

subscr_name_identifier(){
    sub_name=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$binaryedge_api_key" | jq '.subscription.name')
    sub_name_updt=$(echo "${sub_name//\"/}") # deletes "" in $sub_name
}
subscr_name_identifier

subscr_name(){
    sub_name=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$binaryedge_api_key" | jq '.subscription.name')
    sub_name_updt=$(echo "${sub_name//\"/}") # deletes "" in $sub_name
    echo -e "${RED}================================"
    echo -e "Subscription name: $sub_name_updt" 
    echo -e "================================${NC}"
    echo
}

reqs_func(){ #shows your requests that left
    reqs_left=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$binaryedge_api_key" | jq '.requests_left')
    echo -e "${RED}==================="
    echo -e "Requests left: $reqs_left" 
    echo -e "===================${NC}"
    echo
}

api_verifier(){
    cd .. # Goes from Host folder to BinaryEdge.
    reqs_left=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$(cat binaryedge_api_v2.txt)" | jq '.requests_left')
    if [[ "$reqs_left" == "null" ]]; then  # OSO to poso twn requests einai null, diavaze kainoutio API
        while [[ "$reqs_left" == "null" ]]; do
            printf "Write your API key here:"; read new_api_key
            echo "$new_api_key" > binaryedge_api_v2.txt
            reqs_left=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$(cat binaryedge_api_v2.txt)" | jq '.requests_left')
        done
    fi
    binaryedge_api_key=$(cat binaryedge_api_v2.txt)
    sub_name=$(curl -s 'https://api.binaryedge.io/v2/user/subscription' -H "X-Key:$binaryedge_api_key" | jq '.subscription.name')
    sub_name_updt=$(echo "${sub_name//\"/}") # deletes "" in $sub_name
}


###############################################################################################################################################################
image_main_point(){

        printf "/${exp_choosen_category}/ >>> "; read opt1
        cd Image &> /dev/null # get in Image Folder

        if [[ "$opt1" == "help" ]]; then
            gnome-terminal &> /dev/null  -- sh -c "cat help_image.txt; exec bash" &
            image_main_point

        elif [[ "$opt1" == "ip" ]]; then
            ip_beg_point(){
            printf "/${exp_choosen_category}/$opt1="; read host_ip # read host's IP

            if [[ "$host_ip" == "" ]]; then
                image_main_point

            else
                now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                file_name="ip=${host_ip}_date=${now}.txt"
                file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                curl -s "https://api.binaryedge.io/v2/query/image/ip/$host_ip" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"
                
                    lines=$(wc -l < "$file_name") # check how many lines the file has
                    if grep -q -F "Not Found" "$file_name" && [[ "$lines" == 5 ]]; then
                        echo "Target not found! Please try again."
                        rm "$file_name"
                    elif grep -q -F "Bad Request" "$file_name" && [[ "$lines" == 5 ]]; then #### if saved file contains the title "Bad Request" then delete it.
                        echo "Bad Parameter. Please review your query and try again."
                        rm "$file_name"
                    elif grep -q -F "Forbidden" "$file_name" && [[ "$lines" == 5 ]]; then
                        echo "Your plan doesn't allow you to access this resource."
                        rm "$file_name"
                    elif grep -q -F "Unauthorized" "$file_name" && [[ "$lines" == 5 ]]; then
                        echo "Could not validate token (API key). Please review your token and try again."
                            if [ -s binaryedge_api_v2.txt ]; then
                                printf "Your current api key is:"; cat binaryedge_api_v2.txt
                            fi
                        api_verifier                     
                        binaryedge_api_key=$(cat binaryedge_api_v2.txt)
                        cd Image &> /dev/null
                        rm "$file_name"
                    elif grep -q -F "Internal" "$file_name" && [[ "$lines" == 5 ]]; then #### Internal Server Error"
                        echo "Database request error. Please contact support and try again."
                        rm "$file_name"
                    elif [[ "$file_name" =~ " " ]]; then
                        echo "Spaces are not allowed.Please check your input."
                    else
                        cat "$file_name" | jq
                    fi

                reqs_func
                ip_beg_point

            fi     
            }
            ip_beg_point
        elif [[ "$opt1" == "hname2ip" ]]; then
            hname2ip_beg_point(){
            printf "/${exp_choosen_category}/$opt1="; read host_name # read host's name to convert it to it's IP
            if [[ "$host_name" == "" ]]; then
                image_main_point
            fi

            var_hname2ip=$(host "$host_name" | awk '/has address/ { print $4 }') # convert host's name to it's IP address
            host "$host_name" | awk '/has address/ { print $4 }' >> temp.txt # put $var_hname2ip result in temp.txt file
            more_than_1ip=0 # 0 is when var_hname2ip has no more than 1 IP

            if read -r && read -r ; then # if the temp file has more than one lines. (more than 1 IPs)
                     echo "$var_hname2ip"
                     more_than_1ip=1 # 1 is when var_hname2ip has more than 1 IP
            fi < temp.txt

            truncate -s 0 temp.txt # clear the temp file

            if [[ "$more_than_1ip" = 1 ]]; then # if var_hname2ip has more than one IP,then choose what IP you want to scan
                     printf "/${exp_choosen_category}/ip="; read var_hname2ip

                     if [[ "$var_hname2ip" == "" ]]; then
                        image_main_point
                     fi
            fi

            result=$(curl -s "https://api.binaryedge.io/v2/query/image/ip/$var_hname2ip" -H "X-Key:$binaryedge_api_key") # | jq >> saved_file.txt

            now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
            file_name="ip=${var_hname2ip}_date=${now}.txt"
            file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
            echo "$result" | jq > "$file_name"
                
                lines=$(wc -l < "$file_name") # check how many lines the file has
                if grep -q -F "Not Found" "$file_name" && [[ "$lines" == 5 ]] && [[ "$lines" == 5 ]]; then
                    echo "Target not found! Please try again."
                    rm "$file_name"
                elif grep -q -F "Bad Request" "$file_name" && [[ "$lines" == 5 ]]; then #### if saved file contains the title "Bad Request" then delete it.
                    echo "Bad Parameter. Please review your query and try again."
                    rm "$file_name"
                elif grep -q -F "Forbidden" "$file_name" && [[ "$lines" == 5 ]]; then
                    echo "Your plan doesn't allow you to access this resource."
                    rm "$file_name"
                elif grep -q -F "Unauthorized" "$file_name" && [[ "$lines" == 5 ]]; then
                    echo "Could not validate token (API key). Please review your token and try again."
                    if [ -s binaryedge_api_v2.txt ]; then
                        printf "Your current api key is:"; cat binaryedge_api_v2.txt
                    fi
                    api_verifier
                    binaryedge_api_key=$(cat binaryedge_api_v2.txt)
                    cd Image &> /dev/null
                    rm "$file_name"
                elif grep -q -F "Internal" "$file_name" && [[ "$lines" == 5 ]]; then #### Internal Server Error"
                    echo "Database request error. Please contact support and try again."
                    rm "$file_name"
                elif [[ "$file_name" =~ " " ]]; then
                    echo "Spaces are not allowed.Please check your input."
                else
                    cat "$file_name" | jq
                fi

            
            reqs_func
            hname2ip_beg_point
            }
            hname2ip_beg_point

        elif [[ "$opt1" == "hname2ipcon" ]]; then
            hname2ipcon_beg_point(){
            printf "/${exp_choosen_category}/$opt1="; read host_name # read host's name to convert it to it's IP

            if [[ "$host_name" == "" ]]; then
                image_main_point
            fi

            host "$host_name" | awk '/has address/ { print $4 }' # convert host's name to it's IP address and prints it
            hname2ipcon_beg_point
            }
            hname2ipcon_beg_point

        elif [[ "$opt1" == "search" ]]; then
            image_search_beg_point(){            
            printf "/${exp_choosen_category}/$opt1/{query=,page=} >>> "; read search_par # read search parameter ( query,page,only_ips )
             
                if [[ "$search_par" == "help_search" ]]; then
                    gnome-terminal &> /dev/null  -- sh -c "curl -s https://raw.githubusercontent.com/binaryedge/docs.binaryedge.io/master/docs/image-search.md; exec bash" & # print info for search parameters
                    image_search_beg_point

                elif [[ "$search_par" =~ "query=" ]]; then
                    upd_search_par=$(echo "${search_par//\//%20}") # changes / to %20 for AND OR
                    result=$(curl -s "https://api.binaryedge.io/v2/query/image/search?${upd_search_par}" -H "X-Key:$binaryedge_api_key" | jq) 
                    now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                    file_name="search=${upd_search_par}_date=${now}.txt"
                    file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                    echo "$result" > $file_name

                        lines=$(wc -l < "$file_name") # check how many lines the file has
                        if grep -q -F "Not Found" "$file_name" && [[ "$lines" == 5 ]] && [[ "$lines" == 5 ]]; then
                            echo "Target not found! Please try again."
                            rm "$file_name"
                        elif grep -q -F "Bad Request" "$file_name" && [[ "$lines" == 5 ]]; then #### if saved file contains the title "Bad Request" then delete it.
                            echo "Bad Parameter. Please review your query and try again."
                            rm "$file_name"
                        elif grep -q -F "Forbidden" "$file_name" && [[ "$lines" == 5 ]]; then
                            echo "Your plan doesn't allow you to access this resource."
                            rm "$file_name"
                        elif grep -q -F "Unauthorized" "$file_name" && [[ "$lines" == 5 ]]; then
                            echo "Could not validate token (API key). Please review your token and try again."
                            if [ -s binaryedge_api_v2.txt ]; then
                                printf "Your current api key is:"; cat binaryedge_api_v2.txt
                            fi
                            api_verifier
                            binaryedge_api_key=$(cat binaryedge_api_v2.txt)
                            cd Image &> /dev/null
                            rm "$file_name"
                        elif grep -q -F "Internal" "$file_name" && [[ "$lines" == 5 ]]; then #### Internal Server Error"
                            echo "Database request error. Please contact support and try again."
                            rm "$file_name"
                        elif [[ "$file_name" =~ " " ]]; then
                            echo "Spaces are not allowed.Please check your input."
                        else
                            cat "$file_name" | jq
                        fi

                    reqs_func
                    image_search_beg_point

                elif [[ "$search_par" == "tags" ]]; then
                     curl -s "https://api.binaryedge.io/v2/query/image/tags" -H "X-Key:$binaryedge_api_key" | jq
                     reqs_func
                     image_search_beg_point  

                elif [[ "$search_par" == "" ]]; then
                    image_main_point

                else
                    echo -e "${ORAGNE}Invalid input! Please try again...${NC}"
                    image_search_beg_point

                fi
                    }
            image_search_beg_point
        elif [[ "$opt1" == "" ]]; then
            clear
            BinaryEdgeMenu
        else
            echo -e "${ORANGE}Invalid input!${NC}"
            image_main_point
        fi
        
    }
  image_main_point # Image start