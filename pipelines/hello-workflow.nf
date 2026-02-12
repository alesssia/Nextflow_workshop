#!/usr/bin/env nextflow

/**
	Process block
	Each process block describes one step of the workflow
*/

process countSequences {
	
	publishDir 'results', mode: 'copy'
		
	input:
		path infile

	// List of files that should be created by "script" (below)
	output:
		path 'total_sequences.txt' // path indicates this is a file 

	// Code (bash script) that is executed in the compute environment
	script:
	"""
	n=\$(zcat < $infile | grep '^>' | wc -l)
	echo "The number of reads in" $infile  "is" \$n > total_sequences.txt
	"""
}

/*
process countShortSequences {
	
	publishDir 'results', mode: 'copy'

	input:

	output:

	// Arguments:
	//   $1  compressed input FASTA file
	script:
	"""
	n=\$(zcat < $1 |  awk '/^>/ {if (seqlen) print seqlen; seqlen=0; next} {seqlen+=length(\$0)} END {print seqlen}' | awk -v x=100 '\$1 < x' | wc -l)
	echo "The number of reads shorter than 100 in" $1 "is" \$n > filtered_sequences.txt
	"""
}
*/

/*
process removeShortSequences {

	input:

	output:

	// Arguments:
	//   $1  compressed input FASTA file
	//   $2  minimum length (x)
	//   $3  compressed output FASTA file
	script:
	"""
	zcat < $1 | awk -v x=$2 '/^>/{ if(l>x) print b; b=$0; l=0; next } {l+=length; b=b ORS $0}END{if (l>x) print b }' | gzip > $3
	"""
}
*/

/*
process crateLog {

	input:

	output:

	script:
	"""
	cat total_sequences.txt filtered_sequences.txt > $reportfile
	"""
}
*/


/**
	Workflow block
	Describes how the various steps (processed) should be executed
*/

workflow {
	
	//This is an input channel
	input_ch = channel.fromPath("data/*.fasta.gz")
			  .map { file -> [file.simpleName, file] }

	countSequences(input_ch)
//	countShortSequences()
//	removeShortSequences()
//	crateLog()
}
