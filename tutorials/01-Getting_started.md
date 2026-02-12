# Chapter 1: Getting started


## What we'll do during the workshop

We are going to run a simple “genomic” analysis pipeline to process phage samples. Specifically, we will develop a four-step workflow that takes phage genomes in FASTA format as input (three in our case study) and:

- counts the number of sequences;
- counts how many sequences are shorter a given length;
- filters out sequences shorter than a given length; and
- generates a short report

This case study will help us introduce three core NF components: processes, channels, and workflows.
We will not cover module or containers, and we will not take advantage of nf-core resources. 

Things may start to feel complex fairly quickly. NF is famous for having an incredibly steep learning curve, but the cognitive effort is well worth it. Mastering these concepts can beincredibly useful in your professional life.

Please try to follow along, and interrupt me whenever something is unclear. We will build the workflow step by step, so it’s important that everyone stays with me. 

f at any point you feel lost (or just a bit shy about asking questions) don’t worry. The material is divided into four chapters, each with a corresponding NF script. We will begin together with `Hello-process.nf` and progressively work our way to `Hello-workshop.nf`.

The workshop is designed as a live coding session. Please, follow along by watching my terminal and coding with me. You don't need to take notes: each chapter s available as a markdown file that you can review later.

Let's start!

## Traditional approach

In the preparatory material, I mentioned that workflows have been traditionally assembled using general-purpose scripting or programming languages. I've also pointed out that managing how tools interact, and ensuring that each step runs in the correct order with the appropriate inputs and outputs, can quickly become complex.

You don’t have to take my word for it. Let’s explore this together.

Let’s return to our genomic pipeline and implement it using a “traditional” approach.

Let’s examine the structure of the GitHub repository I asked you to clone 

```
cd /Users/visconti/Nextflow/
ls
```

This is the path I asked you to kept it in a safe place.

You’ll see several folders. One of them is 'tutorials` which contains a transcription that closely follows what I’m saying in the live coding session. We are now at Chapter 1 *"Getting Started"*.

```
ls tutorials
````

Another folder is `data`, which contains the phage genomes we’ll be working with:

```
ls data
````

I didn’t make up their names: they really are called Frank, Hari and Jackrabbit!

```
cat data/README.md
```

Let’s take a look at what one of these genomes looks like. Since the file is compressed, we first need to decompress it:

```
zcat < data/Frank.fasta.gz | head
```

I'm using the input redirection operator (`<`) because `zcat` will not work on macOS (my operatying system) without it. Linux users can omit it.

The file is quite long (we will see in a moment it is has more than 480k sequences), so I’m piping the output to the `head` command to display only the first 10 lines.

You may notice that, in a FASTA file, each sequence begins with a single-line header starting with the `>` character, followed by the sequence data on subsequent lines.

How can we use this information to count the number of sequences in the file?

Since each sequence has its own header, and all headers start with `>`, we can count the number of lines that begin with this character. To do so, we decompress the file, extract lines starting with `>` using the  `grep` bash command, and then count them using the `wc -l` bash command. 

```
zcat < data/Frank.fasta.gz | grep '^>' | wc -l 
```

The `^` symbol indicates “start of line”.

We can improve this by assigning the result to a Bash variable and printing a readable message:

```
n=$(zcat < data/Frank.fasta.gz | grep '^>' | wc -l)
echo "The number of reads in data/Frank.fasta.gz is" $n 
```

You may have noticed that the input filename is hard-coded. We can make our analysis more flexible by assigning it to another variable:

```
infile=data/Frank.fasta.gz
n=$(zcat < $infile | grep '^>' | wc -l)
echo "The number of reads in" $infile "is" $n 
```

Note that the value of a Bash variable is accessed using the `$` sign.

Now let’s redirect the output to a file:

```
echo "The number of reads in" $infile "is" $n > total_sequences.txt
cat total_sequences.txt
```

We’ve now completed the first step of our pipeline!

To proceed to the second step (counting all sequences shorter than a given length), we’ll use a Bash script that I’ve already written for you.

If we list the contents of the cloned GitHub repository again, we’ll see a `bin` folder containing several Bash scripts:

```
ls 
ls bin
```

We won’t go into the details of these scripts, as they’re beyond scope of this workshop. However, I'd like to show you one of them, so you understand how it works.

```
cat bin/count_short_sequences.sh
``` 

The script begins with a short description explaining what it does and which parameters it expects:

```
Count the number of sequences shorter than a given length (x) in
a compressed FASTA file

Arguments:
  $1  compressed input FASTA file
  $2  minimum length (x)
````

The body of the script then:
- decompresses the genome;
- uses `awk` to compute the length of each sequence and filter those shorter than a given length `x`; and 
- prints a short summary.

Let’s try it out:

```
bash bin/count_short_sequences.sh $infile 100 
bash bin/count_short_sequences.sh $infile 50
```

Once again, let’s redirect the output to a file:

```
bash bin/count_short_sequences.sh $infile 100 > filtered_sequences.txt
cat filtered_sequences.txt
```

We’ve now completed the second step of our pipeline!

To perform the third step (removing the identified short sequences and producing a new compressed FASTA file), I've provided you with a second bash script:


```
cat bin/remove_short_sequences.sh
```

The arguments are again the compressed input file and the minimum length `x`, but this time there is a third argument specifying the output file.

So, let's define a new bash variable for the output file, and run our script:

```
outfile=data/Frank_filtered.fastq.gz
bash bin/remove_short_sequences.sh $infile 100 $outfile
ls data/
```

Our filtered genome is here!

The final step is to create a simple report by concatenating the files containing the total number of reads with the file containing the number of reads that survived the filtering step:


```
cat total_sequences.txt filtered_sequences.txt > data/Frank_report.txt
ls data
cat data/Frank_report.txt
```

In the `bin` folder, there is also a script that executes the entire pipeline we’ve described so far:

```
ls bin
cat bin/bash_pipeline.sh
```

If we run it, it will process the genome of the *Bacillus* phage Frank.
But what if we wanted to process the *Bacillus* phage Hari instead?

We could manually change the input and output variable and re-run everything. This operation is quite error prone. Let's do it the "proper' way by using a workflow manager. 

Lset’s move on to the second chapter: Hello, process!


