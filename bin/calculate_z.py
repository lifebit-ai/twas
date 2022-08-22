#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import pandas as pd
import numpy as np
import argparse



"""This function uses argparse functionality to collect arguments."""
parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input',
                    metavar='<str: input.txt',
                    type=str,
                    required=False,
                    help="""Path to the output file with the metadata
                            comments to be added to the final VCF.""")
parser.add_argument('-o', '--output',
                    metavar='<str: output.txt',
                    type=str,
                    required=False,
                    help="""Path to the output file with the metadata
                            comments to be added to the final VCF.""")
args = parser.parse_args()

df = pd.read_csv(args.input, sep=' ')

df['ZSCORE'] = df['BETA']/df['SE']

df[['#CHR','POS','REF','ALT','SNP_ID','N','ZSCORE']].to_csv(args.output,sep='\t',index=False)
