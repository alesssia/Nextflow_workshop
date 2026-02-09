#!/usr/bin/env nextflow

/**
	Count the number of sequences in a FASTA file
*/


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

/**
	Workflow block
	Describes how the various steps (processed) should be executed
*/

workflow {
	
	//This is an input channel
	input_ch = channel.fromPath("data/Frank.fasta.gz")
	
   countSequences(input_ch)
}
