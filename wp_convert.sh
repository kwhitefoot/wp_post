# This module provides functions for converting documents, finding
# image links, replacing image links, translating to html.

# Upload image and return the url of the uploaded image.
function upload_image() {
    #echo "function: $FUNCNAME"
    link="$1"
    q_upload_media_file \
        "${CONFIG[url]}" "${CONFIG[user]}" \
        "${CONFIG[password]}" "image/jpeg" "$link" 1
}


# Assume the file is markdown.  Convert to html in a temporary file,
# upload all the pictures, return the temporary file name.
function post_media() {
    #echo "function: $FUNCNAME"
    filename="$1"
    echo "Converting $file to html"
    echo "using $CONVERTER"
    tmp_file="$TEMP_DIR/html"
    #echo "tmp: $tmp_file"
    #"$CONVERTER" "$filename" > "$tmp_file"
    plugin_convert "$filename"
    # Now extract the image links
    img_links=$(cat "$tmp_file" | grep "<img .*src=\"" | sed "s/<img .*src=\"/\\n<img src=\"/g" |sed 's/\"/\n/2' | grep "img src=\""|sed 's/<img src=\"//g'|sort -u)

    file=$(cat "${tmp_file}")
    for link in $img_links
    do
        #echo "link: $link"
        upload_image "$link"
        # Replace the local link with the remote link.
        file=${file//$link/$RESULT}
    done
    #echo "tmp: $tmp_file"
    echo "$file" > "$tmp_file"
    RESULT="$tmp_file"
}
