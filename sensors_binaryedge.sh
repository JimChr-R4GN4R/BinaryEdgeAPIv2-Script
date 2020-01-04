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
sensors_main_point(){

        printf "/${exp_choosen_category}/ >>> "; read opt1
        cd Sensors &> /dev/null # get in sensors Folder

         if [[ "$opt1" == "hname2ipcon" ]]; then
            printf "/${exp_choosen_category}/$opt1="; read host_name # read host's name to convert it to it's IP

            if [[ "$host_name" == "" ]]; then
                sensors_main_point
            fi

            host "$host_name" | awk '/has address/ { print $4 }' # convert host's name to it's IP address and prints it
            sensors_main_point
        elif [[ "$opt1" == "help" ]]; then
            gnome-terminal &> /dev/null  -- sh -c "cat help_sensors.txt; exec bash" &
            sensors_main_point

        elif [[ "$opt1" == "ip" ]]; then
            if [[ "$sub_name_updt" == "Free" ]]; then # if subscription is free,then do not allow history options
                echo -e "${RED}You have to have paid subscription to use ip feature!${NC}"
                sensors_main_point
            fi

            ip_beg_point(){
                printf "/${exp_choosen_category}/$opt1="; read host_ip # read host's name to convert it to it's IP

                if [[ "$host_ip" == "" ]]; then
                    sensors_main_point
                else
                    now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                    file_name="ip=${host_ip}_date=${now}.txt"
                    file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                    curl -s "https://api.binaryedge.io/v2/query/sensors/ip/$host_ip" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"

                
                    lines=$(wc -l < "$file_name")
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
                            cd Sensors &> /dev/null
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

        elif [[ "$opt1" == "search" ]]; then
            if [[ "$sub_name_updt" == "Free" ]]; then # if subscription is free,then do not allow search options
                echo -e "${RED}You have to have paid subscription to use search feature!${NC}"
                sensors_main_point
            fi

            sensors_search_beg_point(){            
            printf "/${exp_choosen_category}/$opt1/{query=,days=,page=,only_ips=} >>> "; read search_par # read search parameter ( query,page,only_ips )
             
                if [[ "$search_par" == "help_search" ]]; then
                    gnome-terminal &> /dev/null  -- sh -c "curl -s https://raw.githubusercontent.com/binaryedge/docs.binaryedge.io/master/docs/sensors-search.md; exec bash" & # print info for search parameters
                    sensors_search_beg_point

                elif [[ "$search_par" =~ "query=" ]]; then
                    upd_search_par=$(echo "${search_par//\//%20}") # changes / to %20 for AND OR
                    result=$(curl -s "https://api.binaryedge.io/v2/query/sensors/search?${upd_search_par}" -H "X-Key:$binaryedge_api_key" | jq) 
                    now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                    file_name="search=${upd_search_par}_date=${now}.txt"
                    file_name=$(echo "${file_name//\//_slash_}")
                    echo "$result" > "$file_name"

                        lines=$(wc -l < "$file_name")
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
                            cd Sensors &> /dev/null
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
                    sensors_search_beg_point

                elif [[ "$search_par" == "stats" ]]; then
                    sensors_search_stats_beg_point(){
                    printf "/${exp_choosen_category}/$opt1/stats/{query=,type=,days=,order=} >>> "; read search_stats_par
                        if [[ "$search_stats_par" =~ "query=" ]] && [[ "$search_stats_par" =~ "type=" ]]; then

                            upd_search_stats_par=$(echo "${search_stats_par//\//%20}") # changes / to %20 for AND OR
                            result=$(curl -s "https://api.binaryedge.io/v2/query/sensors/search/stats?${upd_search_stats_par}" -H "X-Key:$binaryedge_api_key" | jq) 
                            now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                            file_name="search_stats=${upd_search_stats_par}_date=${now}.txt"
                            file_name=$(echo "${file_name//\//_slash_}")
                            echo "$result" > "$file_name"

                                lines=$(wc -l < "$file_name")
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
                                    cd Sensors &> /dev/null
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
                            sensors_search_stats_beg_point
                        elif [[ "$search_stats_par" == "" ]]; then
                            sensors_search_beg_point
                        else
                            echo -e "${ORAGNE}Invalid input! Please try again...${NC}"
                            sensors_search_stats_beg_point  
                        fi
                    }
                    sensors_search_stats_beg_point




                elif [[ "$search_par" == "" ]]; then
                    sensors_main_point

                else
                    echo -e "${ORAGNE}Invalid input! Please try again...${NC}"
                    sensors_search_beg_point

                fi
                    }
            sensors_search_beg_point

        elif [[ "$opt1" == "tag" ]]; then
            tag_beg_point(){
            printf "/${exp_choosen_category}/$opt1/ >>> "; read tag_par

            if [[ "$tag_par" == "" ]]; then
                sensors_main_point

            elif [[ "$tag_par" == "help_tag" ]]; then
                gnome-terminal &> /dev/null  -- sh -c "curl -s https://raw.githubusercontent.com/binaryedge/docs.binaryedge.io/master/docs/sensors-tags.md; exec bash" & # print info for search parameters
                tag_beg_point

            elif [[ "$tag_par" =~ "tag=" ]]; then
                upd_tag_par=$(echo "${tag_par//tag=/}") # replaces tag=MALICIOUS with just MALICIOUS because API wants to be like .../tag/MALICOUS instead of /tag/tag=MALICOUS
                result=$(curl -s "https://api.binaryedge.io/v2/query/sensors/tag/${upd_tag_par}" -H "X-Key:$binaryedge_api_key" | jq) 
                now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                file_name="tag=${upd_tag_par}_date=${now}.txt"
                echo "$result" > "$file_name"
                    lines=$(wc -l < "$file_name")
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
                        cd Sensors &> /dev/null
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
                tag_beg_point

            else
                echo -e "${ORAGNE}Invalid input! Please try again...${NC}"
                tag_beg_point  

            fi

        }
        tag_beg_point

        elif [[ "$opt1" == "" ]]; then
            clear
            BinaryEdgeMenu

        else
            echo -e "${ORANGE}Invalid input!${NC}"
            sensors_main_point

        fi
    }
  sensors_main_point # sensors start