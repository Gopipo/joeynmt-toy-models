#! /bin/bash

scripts=`dirname "$0"`
base=$scripts/..

data=$base/data
tools=$base/tools

mkdir -p $base/shared_models

src=$1
trg=$2

# cloned from https://github.com/bricksdont/moses-scripts
MOSES=$tools/moses-scripts/scripts

bpe_num_operations=2000
bpe_vocab_threshold=10

#################################################################

# measure time

SECONDS=0

# tokenize test files:

cat $data/test.$src-$trg.$src | $MOSES/tokenizer/escape-special-chars.perl -l $src > $data/test.$src-$trg.tokenized.$src
cat $data/test.$src-$trg.$trg | $MOSES/tokenizer/escape-special-chars.perl -l $trg > $data/test.$src-$trg.tokenized.$trg


# tokenize sample train file

cat $data/train.$src-$trg.sample.$src | $MOSES/tokenizer/escape-special-chars.perl -l $src > $data/train.$src-$trg.tokenized.$src
cat $data/train.$src-$trg.sample.$trg | $MOSES/tokenizer/escape-special-chars.perl -l $trg > $data/train.$src-$trg.tokenized.$trg

# learn BPE model on train (concatenate both languages)

subword-nmt learn-joint-bpe-and-vocab -i $data/train.$src-$trg.tokenized.$src $data/train.$src-$trg.tokenized.$trg \
	--write-vocabulary $base/shared_models/vocab.$src-$trg.$src $base/shared_models/vocab.$src-$trg.$trg \
	-s $bpe_num_operations -o $base/shared_models/$src-$trg.bpe

# apply BPE model to train, test and dev

for corpus in train test; do
	subword-nmt apply-bpe -c $base/shared_models/$src-$trg.bpe --vocabulary $base/shared_models/vocab.$src-$trg.$src --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.$src-$trg.tokenized.$src > $data/$corpus.$src-$trg.bpe.$src
	subword-nmt apply-bpe -c $base/shared_models/$src-$trg.bpe --vocabulary $base/shared_models/vocab.$src-$trg.$trg --vocabulary-threshold $bpe_vocab_threshold < $data/$corpus.$src-$trg.tokenized.$trg > $data/$corpus.$src-$trg.bpe.$trg
done

# build joeynmt vocab

python $tools/joeynmt/scripts/build_vocab.py $data/train.$src-$trg.bpe.$src $data/train.$src-$trg.bpe.$trg --output_path $base/shared_models/vocab.$src-$trg.txt

# file sizes

for corpus in train test; do
	echo "corpus: "$corpus
	wc -l $data/$corpus.$src-$trg.bpe.$src $data/$corpus.$src-$trg.bpe.$trg 
done

wc -l $base/shared_models/*

# sanity checks

echo "At this point, please check that 1) file sizes are as expected, 2) languages are correct and 3) material is still parallel"

echo "time taken:"
echo "$SECONDS seconds"
