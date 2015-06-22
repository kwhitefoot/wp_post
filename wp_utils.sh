#!/bin/bash

# Remove leading and trailing whitespace.
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"  
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"  
    echo -n "$var"
}

function verbose() {
    local limit=$1
    local msg="$2"
    if (( $limit <= $VERBOSITY ))
    then
        echo "$msg"
    fi
}

        
