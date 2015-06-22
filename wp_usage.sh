
# Show help if asked.
function q_show_help() {
    echo "function: $FUNCNAME"
    (( "$SHORTUSAGE" )) && shortusage
    (( "$SHOW_USAGE" )) && usage
    (( "$SHOW_EXAMPLES" )) && examples
    echo "aa"
}

# Show usage summary and exit.
function shortusage() {
    echo $"Usage:

    $POSTER_SH [-d configfile] (-a address:user:pass(:active|:inactive)) | -r address:user | -t address:user | -l | -x)

    $POSTER_SH [-d configfile] [-f format] [-c category] [-p post-type] [-o (home|post)] [-vsF] file1 file2 file3 ...
    $POSTER_SH [-d configfile] [-f format] [-c category] [-p post-type] [-o (home|post)] [-vsF] -S content [-T title]
    $POSTER_SH [-d configfile] [-f format] [-c category] [-p post-type] [-o (home|post)] [-vsF] [-T title] < file
    pipe | $POSTER_SH [-d configfile] [-f format] [-c category] [-p post-type] [-o (home|post)] [-vsF] [-T title]

    $POSTER_SH [-heV] # for more extended usage help, examples and version info
    "
    exit EXIT_USAGE
}


# Show detailed usage and exit.
function usage() {
    echo $"Usage:

  -h Show usage
  -e Show examples
  -v Be more verbose
  -s Be less verbose
  -x Test the configuration

  -F Force posting even if the cache claims that the files have
     already been posted.

  -D directory
     Post a directory

 Post multiple files (you can use partial matching (*) to specify
 multiple files):

    $POSTER_SH file1 file2 ...

 Post files in the directories specified (non-recursive):

    $POSTER_SH -D dir1 dir2 file1 file2 ...

  Recursively post directories, implies -D:

    $POSTER_SH -R dir1 dir2 file1 file2 ...

  Read redirected content from this 'file':

    $POSTER_SH < file

  Read piped content from this 'pipe'

    pipe | $POSTER_SH

  Content from argument to -S option:

    $POSTER_SH [options] ... [-S content]

  Be used with above three type of input to specify title of the post
  created (doesn't work with first):

    $POSTER_SH [options] ... [-T title]

  Do a dry run - do not actually post anything to blogs:

    $POSTER_SH [options] ... [-n]

  Do not colorize output - useful when you want to log output to file:

    $POSTER_SH [options] ... [-0]

  Use this file to read (or modify) blog settings:

    $POSTER_SH [options] ... [-d configuration_file]

    $POSTER_SH [options] ... [-a address:user:pass(:active|:inactive)]    # add a new blog to be used with CLI Poster
    $POSTER_SH [options] ... [-r address:user]                            # remove the specified blog & user from CLI Poster
    $POSTER_SH [options] ... [-t address:user]                            # toggle active state for the specified blog & user
    $POSTER_SH [options] ... [-l]                                         # list all the blogs that are in use
    $POSTER_SH [options] ... [-x]                                         # test logins for the configured blogs

    $POSTER_SH [options] ... [-f format]                                  # make compatible with syntaxhighlighter (is always on by default)
    $POSTER_SH [options] ... [-c category]                                # use this category for posting (defaults to: Uncategorized)
    $POSTER_SH [options] ... [-p post-type]                               # use this post-type for posting (defaults to: post)
    $POSTER_SH [options] ... [-v|s]                                       # verbose/short output (shows url for created posts etc. or only show total errors)
    $POSTER_SH [options] ... [-o (home|post)]                             # open homepage or (all) post pages where we have posted (gnome only)

    $POSTER_SH [-h|e|V]                                                   # show usage instructions, examples, and|or version info

    NOTE: <address> should not contain http:// or https://
    e.g. nikhgupta.com is a valid <address>

    NOTE: <format> can be one of these (default is 'auto' which
    automatically formats the post based on file extension and
    mimetypes):

        off, auto, actionscript3, shell, coldfusion, c-sharp, cpp,
        css, pascal, diff, erlang, groovy javascript, java, javafx,
        perl, php, text, powershell, python, ruby, scala, sql, vb,
        xml, html"

    if [ "$SHOW_EXAMPLES" == "1" ]
    then
        echo; examples
    fi
    exit $EXIT_USAGE
}


# Show examples and exit.
function examples() {
    echo $"Examples:

  Post file to blog (post title will be the name of the file):

    $POSTER_SH file1

  Post these files to the blog (post titles will be the names of these
  files):

    $POSTER_SH file1 file2 file3

  Post all files in current directory:

    $POSTER_SH *    

  Post all files that start with '.bash' in 'home' directory (possibly
  not a wise thing to do):

    $POSTER_SH ~/.bash*                                                   

  Get redirected output from 'file1' and post it to the default blog
  (title will be 'Posted via: `uname -n`'):

    $POSTER_SH < file1                     
                               
  Post '~/.bashrc':

    $POSTER_SH < ~/.bashrc                                                

  Get piped output from previous command and post to all the blog:

    cat ~/.bashrc | $POSTER_SH                                            

  Title will be 'Posted via: $(uname -n)' and can be changed by
  passing '-T' option:

    free -m | $POSTER_SH                                                  

  You can also post how long your system has been up to your blog, and
  guess CRON! ;):

    uptime | $POSTER_SH                                                   

  Create a post from the string passed to '-S' option

    $POSTER_SH -S \"some random string/paragraph\"                          

  You can custom create any post by using -S (for content) and -T (for
  title) options:

    $POSTER_SH -S \"\`df -h\`\" -T \"Disk Usage Data\"                         

  Read blog settings from the specified file, and post 'file1' to the
  blog:

    $POSTER_SH -d ~/somewhere/.config file1                                

  Custom config file, test this configuration and then post the
  redirected input:

    $POSTER_SH -xd ~/somewhere/.config -r blog.wordpress.org:nikhgupta < ~/.bashrc

  Test the configuration and then post the piped input:

    free -m | $POSTER_SH -x

  Create a post with this title and piped content, show verbose output
  and then open the post page in browser:

    cat ~/.bash_history | $POSTER_SH -t wordpress.org:nikhgupta -o post -v -T 'bash history for me'

  Create a custom post for 'stats' post type, in 'disk-usage' category
  with current time as Title:

    df -h | $POSTER_SH -c \"disk-usage\" -p \"stats\" -T \"\`date -R\`\"

  Show very little output, create a post in 'php-source' category, use
  'php' syntax highlighting, and then open the homepage:

    $POSTER_SH -f 'php' -c 'php-source' -o home -s index.php

  NOTE: for syntax highlighting, syntax highlighter plugin must be
  installed on the blog!"

    exit $EXIT_USAGE
}
