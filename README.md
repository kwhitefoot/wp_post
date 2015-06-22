# A Command Line WordPress Blog Poster


A Bash script to post your files and media to WordPress blogs.

# Status

It works.  However, several options are still inconsistent because of
the change to handle only one blog instead of multiple blogs.

# Downloads

[Download the latest version](https://github.com/kwhitefoot/wp_post/archive/master.zip)
for use on your desktop or server.

# Documentation

There isn't much yet.

[Documentation](https://github.com/kwhitefoot/wp_post)

## Installation

To install,

* download *wp_post* and all the other files prefixed with *wp\_\** and
  put them anywhere you like.

* create an alias to run `wp-post` as a bash script

  In Ubuntu, for example, you can add this entry to your
  *~/.bash_aliases* file:

  `alias wp_post='/path/to/your/wp_post'`

* Download the *plugins* directory and its contents and put it in the
  same place as the *wp\_\** scripts.  A plugin is a script that is
  sourced by the main script to provide functions that converts from a
  markup format to html and extracts things like titles and
  categories.  A plugin for multimarkdown is provided.
  

## Use

You can get available commands by typing:

  `wp_post -h`, or

examples by typing:

  `wp_post -e`


## Plugins

A plugin is intended to be sourced, included, when the command line
includes the *-C xxx* option where xxx is the name of the plugin.

Plugins contain a function called `convert` that takes a single argument
that is the path to the file to be converted.

Some global variables are explicitly provided for plugins to use:

* TEMP_DIR: path to a directory to be used for any transient files,
            this includes the output html file

* CONFIG: an associative array containing the blog url, username,
          password.


Before the `convert` function returns it must set the following global
variables:

* CONVERTED_FILE: points at the file containing the html.

* CONVERTED_TITLE: to be used as the title of the post.

* CATEGORIES: a simple array containing the category names to be
              applied to the post.

It is convenient to name the plugin script after the actual command
that does the conversion.  There will be no collision because the
plugin scripts are not maked as executable and are not in the path.

## Coding guidelines

Very much not rules.

A few self imposed guidlines to make the code a little easier to
maintain.

* Global variables should be in _ALL CAPS_.
* Local variables should be all lower case and declared with _local_.
* Start functions with a set of _local_ variables naming the
  arguments.
