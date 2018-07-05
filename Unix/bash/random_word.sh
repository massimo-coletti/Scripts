#!/bin/bash

#==============================================================#
# Prints a random word from an installed dictionary.           #
# With a numeric argument, prints random word of given length. #
# For now this script supports Debian Linux (Ubuntu etc...)    #
#==============================================================#

usage_and_exit() {
    echo "Usage: $script_name [word length]"
    exit 1
}

help_and_exit() {
    echo "Prints a random word from an installed dictionary."
    echo "With a numeric argument, prints random word of given length."
    usage_and_exit
}

build_fixed_len_word_file() {
    local len="$1"

    # Verify value is numeric
    if ! [[ $len =~ ^[0-9]+$ ]] ; then
        echo "Word length must be a positive integer: $len"
        usage_and_exit
    fi

    if [ $len -lt 1 ]; then
        echo "Length must be a positive number"
        usage_and_exit
    fi

    # Filter words of given length
    word_file=/tmp/zrand_word_$$
    grep "^.\{$len\}\$" "$dict" > "${word_file}"

    # Verify there are words of given length
    [ -s "${word_file}" ] || \
    { echo "No words found of given length ($1)"; cleanup; exit 1; }
}

cleanup() {
    # If needed, delete temp file
    if [ "${word_file}" != "$dict" ]; then
        rm -f "${word_file}"
    fi
}

#------#
# Main #
#------#

script_name=random_word.sh

# On Debian, the dictionary file is provided by 'wamerican-insane' package
dict=/usr/share/dict/american-english-insane
[ -f "$dict" ] || { echo "Dictionary $dict not found"; exit 1; }
[ -s "$dict" ] || { echo "Dictionary $dict is empty" ; exit 1; }

if [ $# -eq 0 ]; then
    # We want words of any length
    word_file="$dict"
elif [ $# -eq 1 ]; then
    [ "$1" = '--help' ] && help_and_exit
    # We only want words of given length
    build_fixed_len_word_file "$1"
else
    usage_and_exit
fi

line_count=$( wc -l "${word_file}" | awk '{print $1}' )
# echo "file '${word_file}' contains ${line_count} lines"

# Choose a random number between 1 and line_count
rand=$(( ($RANDOM * $RANDOM) % ${line_count} ))
(( rand++ ))

# Print line corresponding to rand
sed "${rand}q;d" "${word_file}"

cleanup

# End of script
