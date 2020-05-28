#!/usr/bin/python3
# -*- coding: utf-8 -*-

import seaborn as sns
import pandas as pd

bleu = pd.read_csv('bleu.csv')

sns.set()
sns.relplot(x="BLEU", y="Beam Size", col="time", data=bleu);