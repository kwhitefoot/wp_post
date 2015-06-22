

declare -A CHARS_TO_ENTITIES
CHARS_TO_ENTITIES=(["<"]="&lt;" ["'"]="&apos;")

# Convert characters to html entities, no need for php.
function convert_entities() {
    html=$1
    for key in "${!CHARS_TO_ENTITIES[@]}"
    do
        value="${CHARS_TO_ENTITIES[$key]}"
        html=${html//$key/$value}
    done
    echo "${html}"
}

function test_e() {

    html="<a href='adfakdjf'>"
    convert_entities "${html}"
    x="<"
    y="${x//</&lt;}"
    echo "y: $y"
}

