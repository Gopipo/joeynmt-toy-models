#!/usr/bin/python3
# -*- coding: utf-8 -*-


import re
import argparse
import os
import random 

from pathlib import Path

def sample_sents(path: Path, n: int, setseed=None):
    '''
    Takes a path object, the number of samples. "setseed" may be used to 
    set pseudo random generator to previous state in order to select 
    the corresponding sample from parallel file.
    Returns a list of randomly sampled lines..
    '''
    sents = []          #list of strings, all sentences
    
        
    #initialise or save random seed
    if setseed is not None:
        random.seed(setseed)
    else:
        setseed = random.getstate()
        #adding repeat_enabler in main() somehow broke the seeds without this line.
        random.seed(setseed)
    
    with open(path, 'r', encoding="utf-8") as text:
        for maxindex, l in enumerate(text):
            pass
    if maxindex < n:
        raise Exception("File " +str(path)+ " has fewer lines than sample size")
    index_sample = random.sample(range(maxindex), n)    #creates a list -> O(n)
    index_sample = set(index_sample)                    #O(1)
    
    with open(path, 'r', encoding="utf-8") as text:
        for i, line in enumerate(text):
            if i in index_sample:
                sents.append(line)
                    
    return sents, setseed
    
def collect_path(args):
    '''Collects all filepaths in a given directory (according to restrictions).
    Returns a list of tuples (filepath, filetype)..'''
    path_list = []
    compatible = True
    if args.namerestrict is not None:
        r_names = args.namerestrict.split()
    else:
        r_names=None
    
    if args.langrestrict is not None:
        r_langs = args.langrestrict.split()
    else:
        r_langs=None
        
    for dirpath, dirname, filenames in os.walk(args.path):
        #exclude embedded directories
        if dirpath != "data":
            continue
        for name in filenames:
            if r_names is not None:
                compatible = False
                if any(name.startswith(element) for element in r_names):
                    compatible = True
            if compatible:
                if r_langs is not None:
                    compatible = False
                    if any(name.endswith(element) for element in r_langs):
                        compatible = True
            if compatible:
                filetype = re.search(r"^(\w+).", name).group(1)
                filepath = os.path.join(dirpath, name)
                path_list.append((filepath, filetype))
                
    return path_list
            

def check_args(args):
    if args.langrestrict is not None:
        r_langs = args.langrestrict.split()
        for element in r_langs:
            if len(element) != 2:
                raise Exception("Please enter only 2-letter language codes \
                                according to ISO 639-1 separated by whitespaces")
                                
    return None
    
def parse_args():
    parser=argparse.ArgumentParser(description="Collect filenames in directory;\
            optional: -n -namerestrict -langrestrict")
    
    parser.add_argument("path", type=Path, help="path of target directory")
    parser.add_argument("-n", type=int, 
                        help="sample size for train files",
                        default=100000,
                        required=False)

    parser.add_argument("-namerestrict", 
                        type=str, 
                        help="restrict file selection to filenames starting \
                        with entered string, whitespace separated", 
                        required=False)
                        
    parser.add_argument("-langrestrict", 
                        type=str, 
                        help="restrict file selection to entered language codes,\
                        whitespace separated", 
                        required=False)
                        
    args = parser.parse_args()
    
    return args
    
def main():
    args = parse_args()
    
    check_args(args)
    
    path_list = collect_path(args)
    
    previousname = ''
    for file, filetype in path_list:
        #in case of resampling this evaluates None only on raw files -> skips rest
        repeat_enabler =  re.search(r"^\w+.\w+\.\w+-\w+\.\w+\.", file)
        if filetype == "train" and (repeat_enabler is None):
            print(file)
            #fix same seed for corresponding files
            name = re.search(r"^\w+.(\w+\.\w+-\w+)", file).group(1)
            if name == previousname:
                sents, seed = sample_sents(file, args.n, setseed=seed)
            else:
                sents, seed = sample_sents(file, args.n)
            previousname = name
            
            newfile = file.split('.')
            newfile = newfile[0]+"."+newfile[1]+".sample."+newfile[2]
            outpath = (newfile)
            with open(outpath, "w", encoding="utf-8") as outfile:
                for element in sents:
                    outfile.write(element)
           

if __name__ == "__main__":
    main()