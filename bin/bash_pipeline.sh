#!/bin/bash 

# Genomic processing pipeline

# Initialization
infile=data/Frank.fasta.gz
outfile=data/Frank_filtered.fasta.gz
reportfile=data/Frank_report.txt

# Step 1: Count the number of sequences in a fasta file

n=$(zcat < $infile | grep '^>' | wc -l)
echo "The number of reads in" $infile "is" $n > total_sequences.txt

# Step 2: Count the number of sequences shorter a given length

bash bin/count_short_sequences.sh $infile 100 > filtered_sequences.txt

# Step 3 Filter out sequences shorter than a given length

bash bin/remove_short_sequences.sh $infile 100 $outfile

# Step 4: Generate a small report

cat total_sequences.txt filtered_sequences.txt > $reportfile
