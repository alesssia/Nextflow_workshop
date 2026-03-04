#!/bin/bash -e

# Pipeline for processing phage genomes

# Setting input/output file
infile=data/Frank.fasta.gz
minlength=100
outfile=results/Frank_filtered.fasta.gz
logfile=results/Frank.log

mkdir -p results

# Step 1: Count the number of sequences in a FASTA file
n=$(zcat < $infile | grep '^>' | wc -l)
echo "The number of reads in" $infile "is" $n > results/total_sequences.txt

# Step 2: Count the number of sequences shorter a given length
bash bin/count_short_sequences.sh $infile $minlength > results/filtered_sequences.txt

# Step 3 Filter out sequences shorter than a given length
bash bin/remove_short_sequences.sh $infile $minlength $outfile

# Step 4: Generate a short report
cat results/total_sequences.txt results/filtered_sequences.txt > $logfile
