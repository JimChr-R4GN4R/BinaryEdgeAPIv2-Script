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
domains_main_point(){
        printf "/${exp_choosen_category}/ >>> "; read opt1
        cd Domains &> /dev/null # get in Domains Folder

        if [[ "$opt1" == "hname2ipcon" ]]; then
            printf "/${exp_choosen_category}/$opt1="; read host_name # read host's name to convert it to it's IP

            if [[ "$host_name" == "" ]]; then
                domains_main_point
            fi

            host "$host_name" | awk '/has address/ { print $4 }' # convert host's name to it's IP address and prints it
            domains_main_point

        elif [[ "$opt1" == "help" ]]; then
            gnome-terminal &> /dev/null  -- sh -c "cat help_domains.txt; exec bash" &
            domains_main_point

        elif [[ "$opt1" == "subdomain" ]]; then
            subdomain_beg_point(){
            printf "/${exp_choosen_category}/$opt1="; read host_name # read host's IP
                if [[ "$host_name" == "" ]]; then
                    domains_main_point
                else
                    now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                    file_name="subdomain=${host_name}_date=${now}.txt"
                    file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                    curl -s "https://api.binaryedge.io/v2/query/domains/subdomain/$host_name" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"

                
                    lines=$(wc -l < "$file_name") # Check how many lines the file has (If it's only 5 and it contains the x word, then you have no results)
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
                            cd Domains &> /dev/null
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
                subdomain_beg_point
                fi
            }
            subdomain_beg_point

        elif [[ "$opt1" == "dns" ]]; then
            if [[ "$sub_name_updt" == "Free" ]]; then # if subscription is free,then do not allow history options
                echo -e "${RED}You have to have paid subscription to use DNS feature!${NC}"
                domains_main_point
            fi

            dns_beg_point(){
            printf "/${exp_choosen_category}/$opt1="; read host_name # read host's IP
                if [[ "$host_name" == "" ]]; then
                    domains_main_point
                else
                    now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                    file_name="dns=${host_name}_date=${now}.txt"
                    file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                    curl -s "https://api.binaryedge.io/v2/query/domains/dns/$host_name" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"

                
                    lines=$(wc -l < "$file_name") # Check how many lines the file has (If it's only 5 and it contains the x word, then you have no results)
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
                            cd Domains &> /dev/null
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
                dns_beg_point
                fi
            }
            dns_beg_point

        elif [[ "$opt1" == "ip" ]]; then
            if [[ "$sub_name_updt" == "Free" ]]; then # if subscription is free,then do not allow history options
                echo -e "${RED}You have to have paid subscription to use DNS feature!${NC}"
                domains_main_point
            fi

            ip_beg_point(){
            printf "/${exp_choosen_category}/$opt1="; read host_ip # read host's IP
                if [[ "$host_ip" == "" ]]; then
                    domains_main_point
                else
                    now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                    file_name="ip=${host_ip}_date=${now}.txt"
                    file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                    curl -s "https://api.binaryedge.io/v2/query/domains/ip/$host_ip" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"

                
                    lines=$(wc -l < "$file_name") # Check how many lines the file has (If it's only 5 and it contains the x word, then you have no results)
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
                            cd Domains &> /dev/null
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
            search_beg_point(){
           printf "/${exp_choosen_category}/$opt1/{query=,page=} >>> "; read search_par # read search parameter ( query,page,only_ips )
               if [[ "$search_par" =~ "query=" ]]; then
                    upd_search_par=$(echo "${search_par//\//%20}") # changes / to %20 for AND, OR
                    result=$(curl -s "https://api.binaryedge.io/v2/query/domains/search?${upd_search_par}" -H "X-Key:$binaryedge_api_key" | jq) 
                    now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                    file_name="search=${upd_search_par}_date=${now}.txt"
                    file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
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
                            cd Torrent &> /dev/null
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
                    search_beg_point
                elif [[ "$search_par" == "" ]]; then
                    domains_main_point
                else
                    echo -e "${ORANGE}You need to type the target!${NC}"
                    search_beg_point
                fi
                }
                search_beg_point

        elif [[ "$opt1" == "enumeration" ]]; then
            if [[ "$sub_name_updt" == "Free" ]] || [[ "$sub_name_updt" == "Starter" ]]; then # if subscription is free or starter,then do not allow enumeration option
                echo -e "${RED}You have to have Business subscription to use enumeration feature!${NC}"
                domains_main_point

            else
                enumeration_beg_point(){
                printf "/${exp_choosen_category}/$opt1="; read host_name

                if [[ "$host_name" == "" ]]; then
                    domains_main_point

                else
                    now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                    file_name="enumeration=${host_name}_date=${now}.txt"
                    file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                    curl -s "https://api.binaryedge.io/v2/query/domains/enumeration/$host_name" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"

                
                    lines=$(wc -l < "$file_name") # Check how many lines the file has (If it's only 5 and it contains the x word, then you have no results)
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
                        elif grep -q -F "Internal" "$file_name" && [[ "$lines" == 5 ]]; then #### Internal Server Error"
                            echo "Database request error. Please contact support and try again."
                            rm "$file_name"
                        elif [[ "$file_name" =~ " " ]]; then
                            echo "Spaces are not allowed.Please check your input."
                            binaryedge_api_key=$(cat binaryedge_api_v2.txt)
                            cd Domains &> /dev/null
                            rm "$file_name"

                    else
                        cat "$file_name" | jq
                    fi

                reqs_func
                enumeration_beg_point
                fi
                }
                enumeration_beg_point
            fi
        elif [[ "$opt1" == "homoglyphs" ]]; then
            if [[ "$sub_name_updt" == "Free" ]] || [[ "$sub_name_updt" == "Starter" ]]; then # if subscription is free or starter,then do not allow homoglyphs option
                echo -e "${RED}You have to have Business subscription to use homoglyphs feature!${NC}"
                domains_main_point

            else
                homoglyphs_beg_point(){
                printf "/${exp_choosen_category}/$opt1="; read host_name

                if [[ "$host_name" == "" ]]; then
                    domains_main_point

                else
                    now=$(date +"%Y_%m_%d_%H_%M_%S_%p")
                    file_name="homoglyphs=${host_name}_date=${now}.txt"
                    file_name=$(echo "${file_name//\//_slash_}") # in case filename has /,for error purposes change it with _slash_
                    curl -s "https://api.binaryedge.io/v2/query/domains/homoglyphs/$host_name" -H "X-Key:$binaryedge_api_key" | jq > "$file_name"

                
                    lines=$(wc -l < "$file_name") # Check how many lines the file has (If it's only 5 and it contains the x word, then you have no results)
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
                    elif grep -q -F "Internal" "$file_name" && [[ "$lines" == 5 ]]; then #### Internal Server Error"
                            echo "Database request error. Please contact support and try again."
                            rm "$file_name"
                    elif [[ "$file_name" =~ " " ]]; then
                            echo "Spaces are not allowed.Please check your input."
                            binaryedge_api_key=$(cat binaryedge_api_v2.txt)
                            cd Domains &> /dev/null
                            rm "$file_name"

                    else
                        cat "$file_name" | jq
                    fi

                reqs_func
                homoglyphs_beg_point
                fi
                }
                homoglyphs_beg_point
            fi

        elif [[ "$opt1" == "" ]]; then
            clear
            BinaryEdgeMenu

        else
            echo -e "${ORANGE}Invalid input!${NC}"
            domains_main_point

        fi
    }
  domains_main_point # Domains start