#!/bin/bash -e

# Count the number of sequences shorter than a given length (x) in 
# a compressed FASTA file
#
# Arguments:
#  $1  compressed input FASTA file
#  $2  minimum length (x)

n=$(zcat < $1 |  awk '/^>/ {if (seqlen) print seqlen; seqlen=0; next} {seqlen+=length($0)} END {print seqlen}' | awk -v x=$2 '$1 < x' | wc -l)
echo "The number of reads shorter than" $2 "in" $1 "is" $n 
