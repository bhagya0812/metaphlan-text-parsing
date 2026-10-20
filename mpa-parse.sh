#!/bin/bash
set -e
file=""
level=""
while getopts "f:l:" opt;do
    case {opt} in
    f)file="$OPTARG";;
    l)level="$OPTARG";;
    *)echo "Usage $0 -f<file_pattern? -l<level_number>";exit 1;;
if [-z "$file"] | [-z "$level"]; then
    echo "Error: both -f and -l are required"
    exit 1
fi
if [[! "$lfile"== *.tsv]]; then
    echo "Error: file needs to be tsv format"
    exit 1
fi
if [[!"$level"=~ ^[1-6]$]]; then
    echo "Error: taxa levels are between 1-6"
    exit 1
fi
for f in $file; do
    base="${f%.tsv}"
        
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
    ' "$f" > "${base}-modified.tsv" || exit 1
done

for file in *-modified.tsv;do
base="${file%-modified.tsv}"
#remove the pesky strain level entries that have the exact same rel_ab and artificially inflate total abundance
#split that single column of classification into 7 columns and keep rel_ab
    grep -vE "GGB|SGB|CFGB" "${file}" | awk -F '\t' -v OFS='\t' '{split($1, tax, "|"); $1= tax[1] OFS tax[2] OFS tax[3] OFS tax[4] OFS tax[5] OFS tax[6] OFS tax[7];print}' "{file}" > "${base}-modified-split.tsv" &&
 #Step 2: Filter by user-specified level using dynamic tab columns and output final abundance file
    awk -F '\t' -v OFS='\t' -v lvl="$level" '
        BEGIN {
            split("Kingdom Phylum Class Order Family Genus Species", rank_names, " ");
        }
        NR==1 {
            header = rank_names[1];
            for (i = 2; i <= lvl; i++) {
                header = header OFS rank_names[i];
            }
            print header OFS "rel_ab";
            next;
        }
        {
            # Check columns directly via awk field variables ($lvl and $(lvl+1))
            if ($(lvl) != "" && $(lvl+1) == "") {
                line = $1;
                for (i = 2; i <= lvl; i++) {
                    line = line OFS $i;
                }
                print line OFS $8;
            }
        }' "${base}-modified-split.tsv" > "${base}-level${level}-abundance.tsv"

    rm -f "${base}-modified-split.tsv"
    echo ""Completed! Output saved to: ${base}-level${level}-abundance.tsv"
done
