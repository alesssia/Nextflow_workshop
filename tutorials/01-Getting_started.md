### SETUP (teacher)

- Open a terminal with the "Teaching" profile
- run `unalias ls`
- remove `results` and `work` directory, and all the `.nextflow` files


### SETUP (students)

- clone the repo
- install Java and NF
- watch a video/read some material


# Genomic analysis, the old way


## What we're going to do

We are going to run a simple “genomic” analysis pipeline. Using three phage genomes in FASTA format, we will:

- Count the number of sequences in a fasta file
- Count the number of sequences shorter a given length
- Filter out sequences shorter than a given length
- Generate a small report

This will allow me to introduce the main NF concepts: processes, channels, workflows, and modules.
We won’t cover containers, and we may or may not take advantage of nf-core resources, depending on the time available.

Things will get complicated soon enough, NF is famous for having an incredibly steep learning curve, but that's a (cognitive) effort well spent. It may become incredibly useful in your professional life.

Please try to follow along. Interrupt me as soon as you get lost, since we’ll be building the workflow one step at a time.

If you’re really lost and/or a bit shy, don’t worry. I’ve divided the material into FIXME chapters, each accompanied by a corresponding NF script. We’ll start together from `Hello-basic.nf` and progressively move to `FIXME.nf`. At the start of each chapter, you can always switch to the corresponding script, for instance if the script you're working on is completely broken and you can't fix it.

I agree, it seems very complicated. Again, don’t worry—I’ll explain everything during the workshop.


## How one does this **without** an orchestration manager

Let's go back to our task (the genomic pipeline) and see how we would approach it without a workshop orchestrator, such as NF.

To do so, let's first look at the structure of the Github repo I've asked you to clone.

```
cd /Users/visconti/Documents/Teaching/undergrads/Nextflow/
ls
```

You’ll see several folders. One of them is data, which contains the phage genomes we’ll be working with.

```
ls data
````

I didn’t make up their names—they really are called like this:

```
cat data/README.txt
```

Let’s take a look at what one of these genomes looks like. Since the file is compressed, we first need to decompress it.

```
zcat < data/Frank.fasta.gz | head
```

I'm using the input redirection operator (<>) because zcat won't work on MacOS without it. Linux users can simply type `zcat filename`.
This is a very long file, so I’m piping the output to the `head` command to display only the first 10 lines.

You may notice that each sequence in a FASTA file starts with a single-line header (beginning with the ">" character), followed by the sequence data on subsequent lines.

How can we use this information to count the number of sequences in the file?

Since each sequence has its own header, and all headers start with ">", we could count the number of lines that begin with this character. To do this, we decompress the file, extract lines starting with > using the bash command `grep`, and then count them. The "^" symbol indicates “start of line”.


```
zcat < data/Frank.fasta.gz | grep '^>' | wc -l 
```

We can polish this a bit by assigning the result to a Bash variable and printing a more readable message:

```
n=$(zcat < data/Frank.fasta.gz | grep '^>' | wc -l)
echo "The number of reads in data/Frank.fasta.gz is" $n 
```

You may notice that the input filename is hard-coded. We can improve this by using another variable:

```
infile=data/Frank.fasta.gz
n=$(zcat < $infile | grep '^>' | wc -l)
echo "The number of reads in" $infile "is" $n 
```

Please note that the value of a Bash variable is accessed using the $ sign.
This adds flexibility, which will be very useful later on.

Now let’s redirect the output to a file:

```
echo "The number of reads in" $infile "is" $n > total_sequences.txt
cat total_sequences.txt
```

We’ve now completed the first step of our pipeline!

To move on to the second step (counting all sequences shorter than a given length) we’ll use a Bash script that I’ve already prepared for you.

If we list the contents of the cloned GitHub repository again, you’ll see a bin folder containing several Bash scripts.

```
ls bin
```

We won’t go into the details of these scripts, as they’re out of scope for this tutorial. However, I want to show you one of them so you understand how it works.

```
cat bin/count_short_sequences.sh
``` 

The script starts with a short description explaining what it does and which parameters it expects:

```
It counts the number reads shorter than a given length x in a compressed FASTA file and write the results on a output file
$1 (the first parameter) is the compressed input file
$2 (the second parameter) is the minimum length x
````

The body of the script then:
- Decompresses the genome
- Uses awk to compute the length of each sequence and filter those shorter than x
- Prints a short summary

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

To perform the third step (removing the identified short sequences and producing a new compressed FASTA file), I've provided you with a second bash script.


```
ls bin
cat bin/remove_short_sequences.sh
```

The arguments are again the compressed input file and the minimum length x, but this time there is a third argument specifying the output file.

So, let's define a new bash variable for the output file, and run our script:

``
outfile=data/Frank_filtered.fastq.gz
bash bin/remove_short_sequences.sh $infile 100 $outfile
ls data/
```

The final step is to create a simple report by concatenating the files containing the total number of reads and the number of reads that survived the filtering step:


```
cat total_sequences.txt filtered_sequences.txt > data/Frank_report.txt
ls data
cat data/Frank_report.txt
```

In the bin folder, there is also a script that executes the entire pipeline we’ve described so far:

```
ls bin
cat bin/bash_pipeline.sh
```

If we run it, it will process the genome of the Bacillus phage Frank.
But what if we wanted to process the Bacillus phage Hari instead?

We could manually change the value of the input variable and re-run everything—but there must be a better way. And this is exactly where NF shines.

So let’s move on to the first chapter: Hello, process!


