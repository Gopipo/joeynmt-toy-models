#! /bin/bash

scripts=`dirname "$0"`

#all available language pairs
language_pairs=( "de,en" "de,it" "de,nl" "de,ro" 
                 "en,de" "en,it" "en,nl" "en,ro" 
                 "it,de" "it,en" "it,nl" "it,ro" 
                 "nl,de" "nl,en" "nl,it" "nl,ro" 
                 "ro,de" "ro,it" "ro,nl" "ro,en")

#use preprocess.sh on every language pair
for lang in "${language_pairs[@]}"; do IFS=","; set -- $lang;
    echo "working on: "$1"-"$2
    . $scripts/preprocess.sh $1 $2
done

echo "Ensure that all language pairs have 3 vocab files and 1 bpe file in ./shared_models"