#! /bin/zsh

########################################################################
# name: dot_h!
#
# Create and update .h files for a given c file
# FIXME:
#   1. Update to allow for a given path for .h, then default to same 
#      directory
#   2. Update -i to work w/ more than 1 file at a time
########################################################################

#Colors
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

# Path to the ignore file used for this directory 
IGNORE_FILE='.dot_h.ignore'

# Directory where the shell script lives
BASEDIR=$(dirname "$0")

function help {
    echo "Interface for .h files for .c files. Should also work for .cpp files as well"
    echo "Using -u flag creates / updates a .h file"
    echo "  -i flag updates / creates a .ignore file"
    echo "Usages:"
    echo "  ./dot_h.sh -u {filename}"
    echo "  ./dot_h.sh -i {function_name} {file_name}"
}

########################################################################
# FUNCTIONALITY:
#   Read all of the function names in the given .c file ($1), and 
#   convert to format needed for a .h file 
#
# INPUT : 
#   $1: STR => Path to file
#
# OUTPUT:
#   $result: STR => Function names found in file seperated by a newline
########################################################################
function fnget {
    result=$(cat $1 | # Read the file being passed in 
        grep '.*{' | # { == start of function
        grep -v -e 'if ' -v -e 'else ' -v -e 'switch ' -v -e $'do ' -v -e 'while ' -v -e 'for ' -v -e '\" ' -v -e '  ' -v -e 'struct ' | # Omit built-ins that also use {
        sed -e 's/ {/;/g' \-e 's/;.*/;/g');  # convert { => ;
    }

#################################################################################
# FUNCTIONALITY:
#   Read all of the function names in the given .c file ($1), and 
#   convert to format needed for a .h file 
#
# INPUT : 
#   $1=SOURCE: STR => Path to source file (.c)
#   $2=DESTINATION: STR => Path to destination file (.h or .dot_h.ignore)
#
# OUTPUT:
#   $result: STR => Function names found in SOURCE that we have not added 
#   before or are specified inside of our .dot_h.ignore or DESTINATION; 
#   seperated by a newline
#################################################################################
function update {
    # File that we are reading from 
    SOURCE_FILENAME=$1

  # File that we are writing into
  DEST_FILENAME=$2

  # The functions that defined inside of source file
  fnget $SOURCE_FILENAME
  FUNCTIONS=$result
  OUT=$result

  # if destination exists, find diff between new funcs and funcs already defined
  if [[ -f $DEST_FILENAME ]]
  then
      USED_FUNCTIONS=$(cat $DEST_FILENAME);
      OUT=$(diff <( printf '%s\n' "$FUNCTIONS" ) <( printf '%s\n' "$USED_FUNCTIONS" ) | grep "<" | sed -e 's/< //g') ;
  fi

  # If there is an ignore file, check make sure not to add those 
  if [[ -f $IGNORE_FILE ]] then
      IGNORE_CONTENTS=$(cat $IGNORE_FILE)
      go build $BASEDIR/dot_h.go
      OUT=$(go run $BASEDIR/dot_h.go $IGNORE_CONTENTS $OUT);
      rm dot_h
  fi

  if [[ $OUT != '' ]] then 
      echo "New Functions:";
      echo -e "${GREEN}$OUT";
  else
      echo "nothing new added"
  fi
  result=$OUT
}


#################################################################################
# MAIN
# 
# FUNCTIONALITY:
# Interface for making building .h files autonomous. Create an ignore file using
# the -i flag to choose which functions to not be placed inside of .h file 
# (currently only works 1 @ a time). Then run w/ -u flag to create / update 
# .h file w/ new changes. => Use both continously throughout the project
#
# INPUT : 
#   $1=FLAG: -x => What mode are we in
#
#   case FLAG == -u:
#    $2=FILENAME => .c file that is associated with .h file
#   
#   case FLAG == -i:
#    $2=FN => Function name that we do not want to be in our .h file
#    $3=FILE => File to find the function name that we do not want
#
#
# OUTPUT:
#   case FLAG == -u:
#     Create or update FILENAME.h (substitute .c for .h) to have the desired
#     exported functions. 
#
#   case FLAG == -i:
#     Create or update .dot_h.ignore with FN from FILE
#
#################################################################################

# if num args != 3
if [[ $# < 2 ]] 
then
    help
    exit -1;
fi

# -u => update, -i => ignore
FLAG=$1

# Update / create the .h file
if [[ $FLAG == '-u' ]]
then

    # if num args != 3
    if [[ $# < 2 ]]
    then
        echo "Usage: ./doth.sh -u {filename}.c"
        exit -1
    fi

    # The destination .h file
    if [[ $2 == 'print' ]]
    then
        SOURCE=$3
        FILENAME=$(echo $3 | sed -e s/.c/.h/g);
    else
        SOURCE=$2
        FILENAME=$(echo $2 | sed -e s/.c/.h/g);
    fi
    update $SOURCE $FILENAME
    FUNCTIONS=$result
    if [[ $2 == 'print' ]]
    then
        exit 0
    fi

    # If .h file does not exist, then write in header guards
    if [[ ! -f $FILENAME ]]
    then
        HEADER=$(echo $FILENAME | sed -e 's/\./_/g' | tr '[:lower:]' '[:upper:]')
        echo "#ifndef " $HEADER "\n#define " $HEADER "\n">> $FILENAME
    fi

    # remove #endif on to the very end of the file
    sed -i.bak 's/#endif/\x0/g' $FILENAME && rm $FILENAME.bak
    sed -i.bak 'N;s/\n\#endif//' $FILENAME && rm $FILENAME.bak

    # If there are new functions, write them into the file
    if [[ $FUNCTIONS != '' ]] then
        echo $FUNCTIONS >> $FILENAME
    fi

    # rewrite #endif to very end of file 
    echo "#endif" >> $FILENAME
fi

# Update / create ignore .file
if [[ $FLAG == '-i' ]]
then
    if [[ $2 == 'print' ]]
    then
        echo -e "Ignored files ${RED}"
        cat $IGNORE_FILE
        echo -e "${NC}"
        exit 0
    fi
    # if num args != 3
    if [[ $# < 3 ]]
    then
        echo "Usage: ./doth.sh -i {filename}.c {fn name}"
        echo "       ./doth.sh -i print"
        exit -1
    fi
    FN=$3
    FILE=$2

    update $FILE $IGNORE_FILE
    FUNCTIONS=$result
    echo -e "${NC}Ignoring"

    NUM_ARG=1
    for FN in "$@"
    do
        if [[ $NUM_ARG > 2 ]]
        then
          # The functions that are in the .c file passed in
          IGNORE=$(echo $FUNCTIONS | grep $FN)
          echo -e "${RED}$IGNORE${NC}"
          echo $IGNORE >> $IGNORE_FILE
        fi
        NUM_ARG=$(($NUM_ARG+1))
    done

fi

