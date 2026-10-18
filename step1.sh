#!/bin/bash
#remove the first 4 rows of metaphlan bugs-list.tsv
set -e

for file in *.tsv; do
    base="${file%.tsv}"
    
    awk -F '\t' -v OFS='\t' '
        NR <= 4 { next }
        {
            # Delete column 2 and shift remaining columns left
            for (i = 2; i < NF; i++) {
                $i = $(i+1)
            }
            NF--  # Drop the extra trailing column
            print
        }
    ' "$file" > "${base}-modified.tsv" || exit 1
done
