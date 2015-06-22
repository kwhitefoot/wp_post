
# Declare the cache array in the global scope
declare -A CACHE


function make_cache() {
    local base=$1
    verbose 10 "function: $FUNCNAME"
    make_cache_file_name "$base" 
    load_cache "$base" 
}

function make_cache_file_name() {
    CACHEFILE=".$1.wp_cache"
}

function get_cache_item() {
    key=$1
    if [[ ${CACHE[$key]+_} ]]
    then
        echo "${CACHE[$key]}"
    else
        echo ""
    fi
}

function update_cache() {
    KEY="$1"
    VALUE="$2"
    CACHE["$KEY"]=$VALUE
    echo "" > "${CACHEFILE}"
    # write one key-value pair per line separated by tabs.
    for i in "${!CACHE[@]}"
    do
        echo -e "$i\t${CACHE[$i]}" >> "${CACHEFILE}"
    done 
}

function load_cache() {
    verbose 10 "function: $FUNCNAME"
    if [ -e  "${CACHEFILE}" ]
    then
        verbose 5 "Load cache from $CACHEFILE"
        local file=$(cat "$CACHEFILE")
        # For reasons unknown the usual ways of saving and retrieving
        # associative arrays (declare -p etc.) don't seem to work for
        # me.
        while IFS=$'\t' read -r key value
        do
            # Check that the key is not empty, this copes with cache
            # files created by faulty programs.
            if [[ "${key}" != "" ]]
            then
                CACHE[${key}]=${value}
            fi
        done < "$CACHEFILE"
    else
        CACHE="( )"
    fi        
}

