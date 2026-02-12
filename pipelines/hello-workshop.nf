#!/usr/bin/env nextflow

/**
	Process block
	Each process block describes one step of the workflow
*/

process countSequences {
		
	input:
		tuple val(simpleName), path(infile)

	// List of files that should be created by "script" (below)
	output:
		tuple val(simpleName), path("total_sequences_${simpleName}.txt") // path indicates this is a file 

	// Code (bash script) that is executed in the compute environment
	script:
	"""
	n=\$(zcat < $infile | grep '^>' | wc -l)
	echo "The number of reads in" $infile  "is" \$n > total_sequences_${simpleName}.txt
	"""
}


process countShortSequences {

	input:
		tuple val(simpleName), path(infile) 
		val min_length 
	
	output:
		tuple val(simpleName), path("filtered_sequences_${simpleName}.txt")

	// Arguments:
	//   $1  compressed input FASTA file
	script:
	"""
	n=\$(zcat < $infile |  awk '/^>/ {if (seqlen) print seqlen; seqlen=0; next} {seqlen+=length(\$0)} END {print seqlen}' | awk -v x=${min_length} '\$1 < x' | wc -l)
	echo "The number of reads shorter than" ${min_length} "in" $infile "is" \$n > filtered_sequences_${simpleName}.txt
	"""
}



process removeShortSequences {

	publishDir 'results', mode: 'copy'

	input:
		tuple val(simpleName), path(infile)
		val min_length

	output:
		path "${simpleName}_filtered.fasta.gz"

	// Arguments:
	//   $1  compressed input FASTA file
	//   $2  minimum length (x)
	//   $3  compressed output FASTA file
	script:
	"""
	zcat < $infile | awk -v x=$min_length '/^>/{ if(l>x) print b; b=\$0; l=0; next } {l+=length; b=b ORS \$0}END{if (l>x) print b }' | gzip > ${simpleName}_filtered.fasta.gz
	"""
}


process crateLog {
	
	publishDir 'results', mode: 'copy'

	input: 
		tuple val(simpleName), path(log1), path(log2)

	output:
		path "${simpleName}.log"

	script:
	"""
	cat $log1 $log2 > "${simpleName}.log"
	"""
}


params.min_length = 50


/**
	Workflow block
	Describes how the various steps (processed) should be executed
*/

workflow {
	
	//This is an input channel
	input_ch = channel.fromPath("data/*.fasta.gz")
			  .map { file -> [file.simpleName, file] }

	countSequences(input_ch)
	countShortSequences(input_ch, params.min_length)
	removeShortSequences(input_ch, params.min_length)
		
	log_ch = countSequences.out.combine(countShortSequences.out, by: 0)
	
	crateLog(log_ch)
}
