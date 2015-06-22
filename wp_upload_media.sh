#!/bin/bash

# Check first to see if the file is changed or new by looking in the
# cache file for the main document.
function q_upload_media_file() {
    echo "function: $FUNCNAME"
    local blog_url="$1"
    USER="$2"
    PASS="$3"
    TYPE="$4"
    FILENAME="$5"
    OVERWRITE="$6"
    echo "function: $FUNCNAME"
    echo "USER: $USER, PASS: $PASS"
    echo "FILENAME: $FILENAME"

    #echo "cache keys: ${!CACHE[@]}"
    #echo "cache values: ${CACHE[@]}"
    local original_timestamp=$(get_cache_item "${FILENAME}.timestamp")
    local new_timestamp=$(stat -c %y "${FILENAME}")
    #echo "ot: $original_timestamp"
    #echo "nt: $new_timestamp"
    if [[ "$original_timestamp" = "$new_timestamp" ]]
    then
        echo "${FILENAME} already uploaded, get remote url from cache."
        RESULT==${CACHE["${FILENAME}.url"]}
    else
        echo "Time stamp changed, uploading"
        upload_media_file \
            "${blog_url}" "${USER}" \
            "${PASS}" "${TYPE}" "${FILENAME}" \
            "${OVERWRITE}"
        update_cache "${FILENAME}.url" "$RESULT"
        update_cache "${FILENAME}.timestamp" "$new_timestamp"

    fi
}

function upload_media_file() {
    local blog_url="$1"
    USER="$2"
    PASS="$3"
    TYPE="$4"
    FILENAME="$5"
    OVERWRITE="$6"
    echo "function: $FUNCNAME"
    echo "u $USER, p $PASS"
    FILE=$(base64 "$FILENAME")

    XML=$(cat <<EOF 
<?xml version='1.0' encoding='iso-8859-1'?>
<methodCall>
  <methodName>metaWeblog.newMediaObject</methodName>
  <params>
    <param>
      <value>
        <int>0</int>
      </value>
    </param>
    <param>
      <value>
        <string>$USER</string> 
      </value>
    </param>
    <param>
      <value><string>$PASS</string>
      </value>
    </param>
    <param>
      <value>
        <struct>
          <member>
            <name>name</name>
            <value>
              <string>$FILENAME</string>
            </value>
          </member>
          <member>
            <name>type</name>
            <value>
              <string>image/jpeg</string>
            </value>
          </member>
          <member>
            <name>bits</name>
            <value><base64>$FILE</base64>
            </value>
          </member>
          <member>
            <name>overwrite</name>
            <value>
              <bool>$OVERWRITE</bool>
            </value>
          </member>
          <member>
            <name>post_type</name>
            <value>
              <string>$6</string>
            </value>
          </member>
          <member>
            <name>mt_keywords</name>
            <value>
              <string/>
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
    #echo "xml: $XML"

    # Save the xml to a file because pictures can easily be too big
    # for the command line.
    xml_file="${TEMP_DIR}/xml"
    #echo "xmlfile: $xml_file"
    echo "$XML" > "$xml_file"
    response=$(curl -vksS -H "Content-Type: application/xml" -X POST --data-binary "@${xml_file}" ${blog_url}/xmlrpc.php)
    echo "Response: $response"

    url=${response#*http://}
    url=${url%%\<*}
    #echo "url: $url"
    RESULT="http://$url"
    
}

