# This module provides functions for converting documents, finding
# image links, replacing image links, translating to html.

# Upload image and return the url of the uploaded image.
function upload_image() {
    verbose 10 "function: $FUNCNAME"
    link="$1"
    q_upload_media_file \
        "${CONFIG[url]}" "${CONFIG[user]}" \
        "${CONFIG[password]}" "image/jpeg" "$link" 1
}


# Assume the file is markdown.  Convert to html in a temporary file,
# upload all the pictures, return the temporary file name.
function post_media() {
    verbose 10 "function: $FUNCNAME"
    filename="$1"
    verbose 2 "Converting $file to html"
    verbose 2 "using $CONVERTER"
    tmp_file="$TEMP_DIR/html"
    plugin_convert "$filename"
    # Now extract the image links
    img_links=$(cat "$tmp_file" | grep "<img .*src=\"" | sed "s/<img .*src=\"/\\n<img src=\"/g" |sed 's/\"/\n/2' | grep "img src=\""|sed 's/<img src=\"//g'|sort -u)

    file=$(cat "${tmp_file}")
    for link in $img_links
    do
        upload_image "$link"
        # Replace the local link with the remote link.
        file=${file//$link/$RESULT}
    done
    echo "$file" > "$tmp_file"
    RESULT="$tmp_file"
}
