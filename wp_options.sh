

function get_options() {
    verbose 10 "function: $FUNCNAME"

    # SET SOME DEFAULT DEFINITIONS
    CONFIGFILE=""
    CONVERTER="null"
    VERBOSITY=1
    
    while getopts ":hsxeFVDR0nd:f:c:p:o:S:T:C:v:" options
    do
        verbose 7 "opt: $options"
        case $options in
            h) SHOW_USAGE=1;;
            e) SHOW_EXAMPLES=1;;
            v) VERBOSITY="$OPTARG";;
            s) SHORTOUTPUT=1;;
            x) TESTCONFIG=1;;
            F) FORCEPOSTING=1;;
            D) DIRECTORYPOSTING=1;;
            R) RECURSIVEPOSTING=1;;
            0) COLORCODES=0;;
            n) DRYRUN=1;;
            d) CONFIGFILE="$OPTARG";;
            f) POSTFORMAT="$OPTARG";;
            c) WPCATEGORY="$OPTARG";;
            p) WPPOSTTYPE="$OPTARG";;
            o) OPENBLOGS="$OPTARG";;
            S) TEXTINPUT="$OPTARG"; READINPUT=1;;
            T) POSTTITLE="$OPTARG";;
            C) CONVERTER="$OPTARG";;
            V) version;;
            *) SHORTUSAGE=1;;
        esac
    done
    shift $(($OPTIND - 1))
    FILES=( "$@" ) # Note use of arrays to preserve whitespace in file
                   # names

    # SET SOME DEFAULT DEFINITIONS
    POSTFORMAT=${POSTFORMAT:-"auto"}
    POSTFORMAT=${POSTFORMAT,,} # make lowercase
    CONVERTER=${CONVERTER:-""}
    WPCATEGORY=${WPCATEGORY:-"Uncategorized"}
    WPPOSTTYPE=${WPPOSTTYPE:-"post"}
    OPENBLOGS=${OPENBLOGS:-""}
    READINPUT=${READINPUT:-0}
    SHOW_EXAMPLES=${SHOW_EXAMPLES:-0}
    SHORTUSAGE=${SHORTUSAGE:-0}
    SHOW_USAGE=${SHOW_USAGE:-0}
    POSTTITLE=${POSTTITLE:-"Posted via: $(uname -n)"}
    TESTCONFIG=${TESTCONFIG:-0}
    FORCEPOSTING=${FORCEPOSTING:-0}
    COLORCODES=${COLORCODES:-1}
    DRYRUN=${DRYRUN:-0}
    RECURSIVEPOSTING=${RECURSIVEPOSTING:-0}
    if (( $RECURSIVEPOSTING ))
    then
        DIRECTORYPOSTING="1"
    else
        DIRECTORYPOSTING=${DIRECTORYPOSTING:-0}
    fi
}

