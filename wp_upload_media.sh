#!/bin/bash

# Check first to see if the file is changed or new by looking in the
# cache file for the main document.
function q_upload_media_file() {
    verbose 10 "function: $FUNCNAME $@"
    local blog_url="$1"
    USER="$2"
    PASS="$3"
    TYPE="$4"
    FILENAME="$5"
    OVERWRITE="$6"

    local original_timestamp=$(get_cache_item "${FILENAME}.timestamp")
    local new_timestamp=$(stat -c %y "${FILENAME}")
    verbose 10 "ot: $original_timestamp"
    verbose 10 "nt: $new_timestamp"
    if [[ "$original_timestamp" = "$new_timestamp" ]]
    then
        verbose 3 "${FILENAME} already uploaded, get remote url from cache."
        RESULT==${CACHE["${FILENAME}.url"]}
    else
        verbose 1 "Time stamp changed, uploading"
        upload_media_file \
            "${blog_url}" "${USER}" \
            "${PASS}" "${TYPE}" "${FILENAME}" \
            "${OVERWRITE}"
        update_cache "${FILENAME}.url" "$RESULT"
        update_cache "${FILENAME}.timestamp" "$new_timestamp"

    fi
}

function upload_media_file() {
    verbose 10 "function: $FUNCNAME $@"
    local blog_url="$1"
    USER="$2"
    PASS="$3"
    TYPE="$4"
    FILENAME="$5"
    OVERWRITE="$6"
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
    verbose 10 "xml: $XML"

    # Save the xml to a file because pictures can easily be too big
    # for the command line.
    xml_file="${TEMP_DIR}/xml"
    echo "$XML" > "$xml_file"
    response=$(curl -vksS -H "Content-Type: application/xml" -X POST --data-binary "@${xml_file}" ${blog_url}/xmlrpc.php)
    verbose 10 "Response: $response"

    url=${response#*http://}
    url=${url%%\<*}
    RESULT="http://$url"    
}

