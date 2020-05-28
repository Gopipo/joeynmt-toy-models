#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data
configs=$base/configs

translations=$base/translations

mkdir -p $translations

src=de
trg=en
langpair=$src-$trg

# cloned from https://github.com/bricksdont/moses-scripts
MOSES=$base/tools/moses-scripts/scripts

num_threads=8
device=5

# measure time

SECONDS=0

for model_name in low_resource_bpe2k low_resource_bpe3k; do

    echo "###############################################################################"
    echo "model_name $model_name"

    translations_sub=$translations/$model_name

    mkdir -p $translations_sub

    CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $configs/$model_name.yaml < $data/test.$langpair.bpe.$src > $translations_sub/test.$langpair.bpe.$model_name.$trg

    # undo BPE (this does not do anything: https://github.com/joeynmt/joeynmt/issues/91)

    cat $translations_sub/test.$langpair.bpe.$model_name.$trg | sed 's/\@\@ //g' > $translations_sub/test.$langpair.tokenized.$model_name.$trg

    # undo tokenization

    cat $translations_sub/test.$langpair.tokenized.$model_name.$trg | $MOSES/tokenizer/detokenizer.perl -l $trg > $translations_sub/test.$langpair.$model_name.$trg

    # compute case-sensitive BLEU on detokenized data

    cat $translations_sub/test.$langpair.$model_name.$trg | sacrebleu $data/test.$langpair.$trg

done

echo "time taken:"
echo "$SECONDS seconds"

