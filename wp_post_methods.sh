



# CLI Poster POSTING METHODS
function post_file() {
    # Parameters: file(s)
    echo "function: $FUNCNAME $@"
    local file="$1"
    local orig_file="$1"
    echo "file: $file"
    make_cache "$file"
    local original_timestamp=$(get_cache_item "${file}.timestamp")
    local new_timestamp=$(stat -c %y "${file}")

    local posterrors="0"
    CONVERTED_TITLE=""
    echo "CONVERTER: $CONVERTER"
    if [[ "$CONVERTER" != "null" ]]
    then
        # Note that we have to convert the file to html in order to
        # find the image links so that we can upload changed images
        # even if the file that refers to them has not changed.
        echo "post_media"
        post_media "$file"
        # Replace filename with name of temporary file containing the
        # html created from markdown, asciidoc, etc.
        file="$RESULT"
    fi

    if [[ "$original_timestamp" = "$new_timestamp" ]]
    then
        echo "File unchanged"
        let TOTAL_UNCHANGED+=1 
    else
        # set the filename as the title of this post, and file content as
        # the post content and sanitize both

        echo "Title: $CONVERTED_TITLE"
        if [[ $CONVERTED_TITLE = "" ]]
        then
            WPTITLE="${filename%.*}"
        else
            WPTITLE=$CONVERTED_TITLE
        fi
        WPTITLE="${WPTITLE//\'/\&apos;}"
        WP_POST=$(echo "$(<"$file")" | sed -e "s|'|\&apos;|g")
        echo "Convert other entities"
        #WP_POST=$(php -r "echo htmlentities('$WP_POST',ENT_NOQUOTES,'ISO-8859-1',false);")
        WP_POST=$(convert_entities "$WP_POST")
        
        # if a source format is provided, format the post accordingly
        if [ "$POSTFORMAT" == "auto" ]
        then
            get_auto_syntax_for_file "$1"
            if test -z "$syntax"
            then
                WP_POST="[${syntax}]${WP_POST}[/${syntax}]"
            fi
        elif [ "$POSTFORMAT" != "off" ]
        then
            WP_POST="[${POSTFORMAT}]${WP_POST}[/${POSTFORMAT}]"
            syntax="${POSTFORMAT}"
        fi
        syntax=${syntax:-"text"}
        
        if test -z "$WP_POST"
        then
            error "Seems like the source content is empty.\n\t(Or, probably, there was an error while preparing this content for posting.)"
        else
            if [ "${SHORTOUTPUT}" == "0" ]
            then
                echo -en "Posting: ${FILEBASE} (applied formatting: ${syntax})"
            fi
            post_to_wordpress "${CONFIG[url]}" \
                "$(get_cache_item "${orig_file}.id")" \
                "${CONFIG[user]}" \
                "${CONFIG[password]}" "${WPTITLE}" "${WPCATEGORY}" \
                "${WPPOSTTYPE}" "${WP_POST}"
            let posterrors+=${posterror:0}
            #show_posting_success
        fi
        update_cache "${orig_file}.id" "$POST_ID"
        update_cache "${orig_file}.timestamp" "$new_timestamp"
    fi
}

function post_content() {
    # options: title, content
    #echo "function: $FUNCNAME"
    posterrors="0"
    # set the filename as the title of this post, and file content as
    # the post content and sanitize both
    WPTITLE=$(echo "$1" | sed -e "s|'|\&apos;|g")
    WP_POST=$(echo "$2" | sed -e "s|'|\&apos;|g")
    #    WPTITLE=$(php -r "echo htmlentities('$WPTITLE',ENT_NOQUOTES,'ISO-8859-1',false);")
    #    WP_POST=$(php -r "echo htmlentities('$WP_POST',ENT_NOQUOTES,'ISO-8859-1',false);")
    
    # if a source format is provided, format the post accordingly
    if [ "$POSTFORMAT" != "auto" ] && [ "$POSTFORMAT" != "off" ]
    then
        WP_POST="[${POSTFORMAT}]${WP_POST}[/${POSTFORMAT}]"
    else
        POSTFORMAT="text"
    fi
    
    if [ "${SHORTOUTPUT}" == "0" ]
    then
        echo -en "Posting to ${CONFIG[url]} (applied formatting: ${POSTFORMAT})"
    fi
    post_to_wordpress "${CONFIG[url]}" \
        "" \
        "${CONFIG[user]}" \
        "${CONFIG[pass]}" "${WPTITLE}" "${WPCATEGORY}" \
        "${WPPOSTTYPE}" "${WP_POST}"
    let posterrors+=${posterror:0}
    #show_posting_success
 }

function make_data() {
    local item=$1
    cat <<EOF
                <data>
                  <value>
                    <string>$item</string>
                  </value>
                </data>

EOF
}

function make_categories_array() {
    for i in "${CONVERTED_CATEGORIES[@]}"
    do
        make_data "$i"
    done
}

#  See http://xmlrpc.scripting.com/metaWeblogApi.html
function post_to_wordpress() {
    # Parameters: blog, post_id, user, pass, title, category, post-type, content
    local blog_url=$1
    local post_id=$2
    local user=$3
    local pass=$4
    local title=$5
    local categories=$6
    local post_type=$7
    local post=$8
    #echo "pi: $post_id"
    #echo "keys: ${!CACHE[@]}"
    #echo "values: ${CACHE[@]}"
    if [[ $post_id = "" ]]
    then
        local rpc="newPost"
    else
        local rpc="editPost"
    fi
    
    XML=$(cat <<EOF 
<?xml version='1.0' encoding='iso-8859-1'?>
<methodCall>
  <methodName>metaWeblog.${rpc}</methodName>
  <params>
    <param><value><int>${post_id}</int></value></param>
    <param><value><string>${user}</string></value></param>
    <param>
      <value><string>${pass}</string>
      </value>
    </param>
    <param>
      <value>
        <struct>
          <member>
            <name>title</name>
            <value>
              <string>${title}</string>
            </value>
          </member>
          <member>
            <name>description</name>
            <value>
              <string>${post}</string>
            </value>
          </member>
          <member>
            <name>mt_allow_comments</name>
            <value><int>1</int>
            </value>
          </member>
          <member>
            <name>mt_allow_pings</name>
            <value>
              <int>1</int>
            </value>
          </member>
          <member>
            <name>post_type</name>
            <value>
              <string>$post_type</string>
            </value>
          </member>
          <member>
            <name>mt_keywords</name>
            <value>
              <string/>
            </value>
          </member>
          <member>
            <name>categories</name>
            <value>
              <array>
                $(make_categories_array)
              </array>
            </value>
          </member>
        </struct>
      </value>
    </param>
    <param>
      <value>
        <boolean>1</boolean>
      </value>
    </param>
  </params>
</methodCall>
EOF
)
    echo "xml: $XML"
    
    (( $DRYRUN )) || {
        echo "Post via curl"
        local response=$(curl -ksS -H "Content-Type: application/xml" -X POST --data-binary "${XML}" $blog_url/xmlrpc.php)
        echo "Response: $response"
        if [[ $response == *\<name\>faultCode\</name\>* ]]
        then
            get_fault "$response"
            local fault=$RESULT
            echo "fault: $fault"
        else
            echo "No fault"
            local fault=""
            if [[ $post_id = "" ]]
            then
                echo "Get the new post id"
                POST_ID=$(echo $response | sed "s|.*string>\(.*\)<\/string.*$|\1|g")
            else
                POST_ID=$post_id
            fi
        fi
    }

    echo "pi: $POST_ID"
    if [[ $fault == "" ]] && [ "$POST_ID" != "0" ] || (( $DRYRUN ))
    then
        echo "No post error"
        posterror=0;
        if [ "$VERBOSE" == "1" ]
        then
            echo -e "\n\tPosted successfully to: $1 with user: $2 with URL: http://$1/?p=${POST_ID}"
        fi
        if [ "$OPENBLOGS" == "post" ] && [ -n "$OPENBROWSER" ]
        then
            $OPENBROWSER "http://$1/?p=${POST_ID}"
        fi
    else
        echo "Post Error"
        posterror=1
        if [ "$VERBOSE" == "1" ]
        then
	    if [[ ! $success ]]
            then
                echo -e "\n\tPosting to: $1 with user: $2"
                warn "$fault"
	    fi
	fi
    fi
}

# No need to use sed.
function get_fault() {
    local xml=$1
    RESULT=${xml#*<name>faultString</name>*<value><string>}
    RESULT=${RESULT%%<*}
}

function get_file_name_and_extension() {
    #echo "function: $FUNCNAME"
    #echo "arg: $1"
    FILEBASE="${1##*/}" # remove directory
    FILE_EXTENSION="${FILEBASE#*.}" # get just extension
    FILENAME="${FILEBASE%%.*}" # remove extension
    FILE_EXTENSION=${FILE_EXTENSION,,} # convert to lower case
    if [ "$FILENAME" == "$FILE_EXTENSION" ] || [ -z "$FILENAME" ]
    then
        FILENAME="$FILE_EXTENSION"
        FILE_EXTENSION=""
    fi
}

# prepare a list of files that we need to post
function send_files_for_posting() {
    echo "function: $FUNCNAME $@" 
    local file
    for file in "$@"; do
        echo "file: $file"
        # get file extension, file basename for this file
        get_file_name_and_extension "$file"
        
        if [[ -f "$file" ]]
        then
            echo "exists"
            post_file "$file";
            let totalerrors+=${posterrors:-0};
            let totalposted+=${postedto:-0};
            let totalposts+=1
        elif [ -d "$file" ]
        then
            if (( $RECURSIVEPOSTING ))
            then
                postfiles="$(find "$file" -type f -readable -not -iregex ".*\/\..*")"
            elif (( $DIRECTORYPOSTING ))
            then
                postfiles="$(find "$file" -maxdepth 1 -type f -readable -not -iregex "\..*\/\..*")"
            else
                (( "${SHORTOUTPUT}" )) || warn "Skipping: '${FILEBASE}', as directory posting is disabled, by default!"
            fi
            for postfile in $postfiles; do
                post_file "$postfile"
                let totalerrors+=${posterrors:-0};
                let totalposted+=${postedto:-0};
                let totalposts+=${totaltopost:-0}; 
            done
        else
            (( "${SHORTOUTPUT}" )) || warn "Skipping: '${FILEBASE}', as either it was not found, or is neither a file nor a directory!"
        fi
    done
}



# WORDPRESS RELATED FUNCTIONS
function test_wp_configuration() {
    # Parameters: blog, user, pass
    XML="<?xml version='1.0' encoding='iso-8859-1'?><methodCall><methodName>wp.getUsersBlogs</methodName><params><param><value><string>$2</string></value></param><param><value><string>$3</string></value></param></params></methodCall>"
    response=$(curl -ksS -H "Content-Type: application/xml" -X POST --data-binary "${XML}" $1/xmlrpc.php)

    faultString=$(echo $response | grep "faultString");
    if echo $response | grep -q "<name>isAdmin<\/name>"; then
        blogcheck="1"
        echo -e "Testing: $1 for user: $2"
        success "Login to this site works!" 1
    else
        blogcheck="0";
        if echo $response | grep -q "faultString"
        then
            echo -e "Testing: $1 for user: $2"
            error "$(echo $response | sed 's|.*faultString.*<string>\(.*\)<\/string>.*$|\1|g')" 1
        else
            echo -e "Testing: $1 for user: $2"
            echo "Response: $response"
            error "Some Unknown error occurred!" 1
        fi
    fi
}



# SyntaxHighlighter RELATED FUNCTIONS
function get_auto_syntax_for_file() {
    postmimetype=$(file -ib "$1")
    get_file_name_and_extension "$1"

    if   [[ $FILE_EXTENSION == js ]] || [[ $postmimetype == *javascript* ]]; then
        syntax="javascript";
    elif [[ $FILE_EXTENSION == css ]] || [[ $postmimetype == *css* ]]; then
        syntax="css";
    elif [[ $FILE_EXTENSION == sh ]] || [[ $FILE_EXTENSION == bash ]] || [[ $FILE_EXTENSION == zsh ]] || [[ $postmimetype == *shell* ]]; then
        syntax="shell";
    elif [[ $FILE_EXTENSION == py ]] || [[ $postmimetype == *python* ]]; then
        syntax="python";
    elif [[ $FILE_EXTENSION == pas ]] || [[ $postmimetype == *pascal* ]]; then
        syntax="pascal";
    elif [[ $FILE_EXTENSION == groovy ]] || [[ $postmimetype == *groovy* ]]; then
        syntax="groovy";
    elif [[ $FILE_EXTENSION == pl ]] || [[ $postmimetype == *perl* ]]; then 
        syntax="perl";
    elif [[ $FILE_EXTENSION == rb ]] || [[ $postmimetype == *ruby* ]]; then
        syntax="ruby";
    elif [[ $FILE_EXTENSION == sql ]] || [[ $postmimetype == *sql* ]]; then
        syntax="sql";
    elif [[ $postmimetype == *php* ]]; then    
        syntax="php";
    elif [[ $postmimetype == *html* ]]; then
        syntax="html";
    elif [[ $postmimetype == *xml* ]] || [[ $postmimetype == *xsl* ]]; then
        syntax="xml";
    elif [[ $postmimetype == *text/x-c* ]] || [[ $postmimetype == *c++* ]]; then
        syntax="cpp";
    elif [[ $FILE_EXTENSION == cs ]] || [[ $postmimetype == *csharp* ]]; then
        syntax="c-sharp";
    elif [[ $postmimetype == *diff* ]]; then
        syntax="diff";
    elif [[ $postmimetype == *java* ]]; then
        syntax="java";
    else syntax=""; fi
}

