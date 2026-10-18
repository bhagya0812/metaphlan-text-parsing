#!/bin/bash

for file in *-modified.tsv;do
base="${file%-modified.tsv}"
#remove the pesky strain level entries that have the exact same rel_ab and artificially inflate total abundance
#split that single column of classification into 7 columns and keep rel_ab
    grep -vE "GGB|SGB" "${file}" | awk -F '\t' -v OFS='\t' '{split($1, tax, "|"); $1= tax[1] OFS tax[2] OFS tax[3] OFS tax[4] OFS tax[5] OFS tax[6] OFS tax[7];print}' "{file}" > "${base}-modified-split.tsv" &&

#provide uniform column headers 
    awk -F '\t' -v OFS='\t' 'NR==1 {print "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species", "rel_ab";next}{print}' "${base%}-modified-split.tsv" > "${base}-split-renamed.tsv" &&

#extract at required classification level: $1 is Kingdom, $2 is Phylum, $3 is Class and so on
    awk -F '\t' 'NR == 1 || $6 != ""' "${base%}-split-renamed.tsv" > "${base}-split-renamed-genus.tsv"
done
