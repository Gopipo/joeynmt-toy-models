# joeynmt-toy-models


Based on: https://github.com/joeynmt/joeynmt

# Changes made

Added variants for word level and bpe of vocabsize 2k and 3k to configs/ and scripts/train and scripts/evaluate

Added tools/sentsampler.py for random sentence sampling.

Added scripts/multicall_preprocess.sh for easy preprocessing of multiple language pairs.

Amended scripts/preprocess.sh to train two bpe vocab sizes

Plots with seaborn

plot.py (- Due to time constraints, no results present in bleu.csv -)

# Requirements

- This only works on a Unix-like system, with bash.
- Python 3 must be installed on your system, i.e. the command `python3` must be available
- Make sure virtualenv is installed on your system. To install, e.g.

    `pip install virtualenv`

# Steps

Clone this repository in the desired place and check out the correct branch:

    git clone https://github.com/bricksdont/joeynmt-toy-models
    cd joeynmt-toy-models
    checkout ex4

Create a new virtualenv that uses Python 3. Please make sure to run this command outside of any virtual Python environment:

    ./scripts/make_virtualenv.sh

**Important**: Then activate the env by executing the `source` command that is output by the shell script above.

Download and install required software:

    ./scripts/download_install_packages.sh

Download data:

    ./scripts/download_data.sh
    
For small data sample sentences with sentsampler.py (default 10k for dev set + 100k for train set). sentsampler takes 1 possitional argument: the directory name where the data is stored.

    ./tools/sentsampler.py data

Preprocess data (language pairs to be preprocessed may be adjusted in the script):

    ./scripts/multicall_preprocess.sh

Then train a model:

For word level models:

    ./scripts/train_word2k.sh

For models using bpe:

    ./scripts/train_bpe2k.sh
    ./scripts/train_bpe3k.sh
    
The training process can be interrupted at any time, and the best checkpoint will always be saved.
    
To evaluate the models:

    ./scripts/evaluate_bpe.sh
    ./scripts/evaluate_word.sh
    
For translations with alternative beam size:

-Remove low_resource_bpe3k from line27 of evaluate_bpe

-Change testing parameter beam_size

Then run 

    ./scripts/evaluate_bpe.sh

again.



