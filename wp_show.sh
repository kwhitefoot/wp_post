

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
	desc=( "_Error_" "Warning" "Success" "ABORTED")
        desc="${desc[$1]}! $3"
        
	[ -n "$3" ] && echo -ne "${desc}";
        printf "\n%s\n" "...[ ${message} ]"
    fi
}
