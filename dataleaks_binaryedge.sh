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
dataleaks_main_point(){

        printf "/${exp_choosen_category}/ >>> "; read opt1
        cd Dataleaks &> /dev/null # get in Dataleaks Folder

        if [[ "$opt1" == "help" ]]; then
            gnome-terminal &> /dev/null  -- sh -c "cat help_dataleaks.txt; exec bash" &
            dataleaks_main_point

        elif [[ "$opt1" == "email" ]]; then
            email_beg_point(){
            printf "/${exp_choosen_category}/$opt1="; read email # read email

            if [[ "$email" == "" ]]; then
                dataleaks_main_point

            else
                if [[ "$email" == ?*@?*.?* ]] ; then
                now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                file_name="email=${email}_date=${now}.txt"
                file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                curl -s "https://api.binaryedge.io/v2/query/dataleaks/email/$email" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"
                
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
                            cd Dataleaks &> /dev/null
                            rm "$file_name"
                        elif grep -q -F "Internal" "$file_name" && [[ "$lines" == 5 ]]; then #### Internal Server Error"
                            echo "Database request error. Please contact support and try again."
                            rm "$file_name"
                        elif [[ "$file_name" =~ " " ]]; then
                            echo "Spaces are not allowed.Please check your input."
                        else
                            cat "$file_name" | jq
                        fi
                else
                    echo -e "${ORANGE}Invalid email format! Please try again...${NC}"
                    email_beg_point
                fi
                reqs_func
                dataleaks_main_point

            fi     
        }
        email_beg_point

        elif [[ "$opt1" == "domain" ]]; then
            domain_beg_point(){
            printf "/${exp_choosen_category}/$opt1="; read domain # read domain

            if [[ "$domain" == "" ]]; then
                dataleaks_main_point
            else
                if [[ "$domain" == ?*.?* ]] ; then
                now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                file_name="domain=${domain}_date=${now}.txt"
                file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                curl -s "https://api.binaryedge.io/v2/query/dataleaks/organization/$domain" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"
                
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
                            cd Dataleaks &> /dev/null
                            rm "$file_name"
                        elif grep -q -F "Internal" "$file_name" && [[ "$lines" == 5 ]]; then #### Internal Server Error"
                            echo "Database request error. Please contact support and try again."
                            rm "$file_name"
                        elif [[ "$file_name" =~ " " ]]; then
                            echo "Spaces are not allowed.Please check your input."
                        else
                            cat "$file_name" | jq
                        fi
                else
                    echo -e "${ORANGE}Invalid domain! Please try again...${NC}"
                    domain_beg_point
                fi
                reqs_func
                dataleaks_main_point
            fi
        }
        domain_beg_point

        elif [[ "$opt1" == "info" ]]; then
            now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
            file_name="dataleaks_info_sources_${now}.txt"
            file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
            curl -s "https://api.binaryedge.io/v2/query/dataleaks/info" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"
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
                            cd Dataleaks &> /dev/null
                            rm "$file_name"
                        elif grep -q -F "Internal" "$file_name" && [[ "$lines" == 5 ]]; then #### Internal Server Error"
                            echo "Database request error. Please contact support and try again."
                            rm "$file_name"
                        elif [[ "$file_name" =~ " " ]]; then
                            echo "Spaces are not allowed.Please check your input."
                        else
                            cat "$file_name" | jq
                        fi
            dataleaks_main_point

        elif [[ "$opt1" == "" ]]; then
            clear
            BinaryEdgeMenu
        else
            echo -e "${ORANGE}Invalid input!${NC}"
            dataleaks_main_point
        fi
        
    }
  dataleaks_main_point # Dataleaks start