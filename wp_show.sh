


# function init_colour_codes() {
#     echo "function: $FUNCNAME"
#     (( $COLORCODES )) && BLD=$(tput bold)
#     (( $COLORCODES )) && NML=$(tput sgr0)
#     (( $COLORCODES )) && RED=$BLD$(tput setaf 1)
#     (( $COLORCODES )) && GRN=$BLD$(tput setaf 2)
#     (( $COLORCODES )) && YLW=$BLD$(tput setaf 3)
#     (( $COLORCODES )) && BLU=$BLD$(tput setaf 6)
#     COL=$(tput cols)
#     let COL=COL-16
# }

function error {
    show_success 0 "failed" "$1"; 
}

function warn {
    show_success 1 "warning" "$1"; 
}

function success {
    show_success 2 "success" "$1";
}

function die { 
    show_success 3 "aborted" "$1"
    exit EXIT_ABORTED;
 }

function cleanup {
    [ -f "$TMP_FILE" ] && rm "$TMP_FILE"; 
    return 0;
}


# show success message for posting
function show_posting_success() {
    if [ "$posterrors" == "0" ]
    then
        success="2"
    else
        success="1"
    fi
    show_success "$success" "$postedto/$totaltopost"
}


function show_success() {
    
    # Parameters: condition_check (0|1|2|3), warn|fail|success|abort,
    # [desc], [override_short]
    
    # Parameters: condition_check (0|1|2|3), message, [desc]
    
    if (( ! $SHORTOUTPUT )) || (( $4 ))
    then
	message=( $(echo "$2" | tr '|' ' ') );
        message="${message[$1]}";
        message=${message:-"$2"}
	color=( "${RED}" "${YLW}" "${GRN}" "${RED}" )
	desc=( "_Error_" "Warning" "Success" "ABORTED")
	if (( $COLORCODES ))
        then
            desc="${color[$1]}${desc[$1]}!${NML} $3" 
        else
            desc="${desc[$1]}! $3"
        fi
	[ -n "$3" ] && echo -ne "${desc}";
	if (( $COLORCODES ))
        then
            tput hpa $COL
            echo -e "${color[$1]}[ ${message} ]${NML}";
	else
            printf "\n%${COL}s\n" "...[ ${message} ]"
        fi
    fi
}
