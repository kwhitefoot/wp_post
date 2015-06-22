

verbose 15 "Loading wp_config.sh"

declare -A CONFIG
function read_configuration() {
    verbose 10 "function: $FUNCNAME $1"
    local file=$1
    verbose 5 "Loading configuration from ${file}"
    while read line
    do
        if [[ $line == *=* ]]
        then
            key=$(trim "${line%%=*}")
            value=$(trim "${line#*=}")
            CONFIG[$key]=$value
        fi
    done < "$file"
    
    if [[ ${#CONFIG[@]} = 0 ]] 
    then 
        echo "Empty Configuration File or file does not contain"
        echo "necessary values!"
        exit EXIT_MALFORMED_CONFIG
    fi
}

# If the user specifies a configuration use that, if not look in the
# same directory as the file being posted for a file of the same name
# but with the extension .config and a leading dot to hide it from
# normal directry scans.  If that is not found look in the same
# directory for .wp_post.config, lastly look in ~/.wp_post.config.
# The reason for looking twice in the file directory is so that we can
# have multiple blogs in the same directory each consisting of only
# one file or a single blog consisting of many files.

# When looking for config files we do not look in a global standard
# location so as to avoid embarrasing mistakes like posting your sex
# blog to the one you share with the rest of your family.

# Expects the blog_fn argument to be a full path.
function load_configuration() {
    verbose 10 "function: $FUNCNAME $1 $2"
    local config_fn="$1"
    local blog_fn=$2
    if [[ "$config_fn" = "" ]]
    then
        verbose 3 "No configuration file specified, trying default locations and names" 
        config_fn=".${blog_fn}.config"
        if [[ ! -f "$config_fn" ]]
        then
            verbose 3 "Config named for file  <${config_fn}> does not exist"
            if [[ "${blog_fn}" = *"/"* ]]
            then
                d="${blog_fn%/*}/"
            else
                d=""
            fi
            config_fn="${d}.wp_post.config"
        fi
    fi
    if [[ ! -f "$config_fn" ]]
    then
        die "Configuration file <${config_fn}> does not exist"
    fi
    read_configuration "$config_fn"
}

function make_config_template() {
    verbose 10 "function: $FUNCNAME $1"
    
    echo "url=xxxx"
    echo "user=yyyy"
    echo "pass=zzzz"
    
}

