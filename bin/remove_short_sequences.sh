#!/bin/bash -e

# Filter out sequences shorter than a given length (x) in 
# a compressed FASTA file, creating a new compressed FASTA file
#
# Arguments:
#  $1  compressed input FASTA file
#  $2  minimum length (x)
# 	$3  compressed output FASTA file

zcat < $1 | awk -v x=$2 '/^>/{ if(l>x) print b; b=$0;l=0;next } {l+=length;b=b ORS $0}END{if(l>x) print b }' | gzip > $3
