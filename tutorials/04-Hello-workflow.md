# Chapter 4: Hello workflow!


We’ll now abandon our `hello-process.nf` file and move on to a new template pipeline, `hello-workflow.nf`.
This file provides the skeleton of the pipeline we described at the beginning of the class.

Open the file with:

```
nano pipelines/hello-workflow.nf
```

We can see that it includes the four steps we described, each isolated in its own process. Some of them are commented out, and the input and output declarations for all of them are currently empty.

In the body of each script, I’ve reported the Bash commands we saw at the start of the lesson, when we were still processing the files directly from the shell. These scripts are all located in the `bin` folder of this repository.

Clearly, there’s a lot of work to do—so let’s get started.

Let’s think about our pipeline.
We have three independent steps, each of which takes the original input files as input: `countSequences`, `countShortSequences`, and `removeShortSequences`. We’ve already addressed the first one, so let’s move on to the second.

The first thing to do is to specify the input of `countShortSequences` in the workflow declaration, documenting it:

```
nano pipelines/hello-workflow.nf
```

```
countShortSequences(input_ch)
```

and edit the input and output in the corresponding process. Since it has the same input as `countSequences`, we can copy it from there:

```
input:
	tuple val(simpleName), path(infile) 
```

Let’s also fix the parameters and remove the hard-coded parts in the script body.

`$1` is the input file, which in this case corresponds to `$infile` (a NF variable, so no dollar-sign escaping is needed; it appears once in the first line and once in the second). Be careful of not editing the `\$1` inside the `awk` command. 

The same applies to the output file (`${simpleName}`; it appears once in the second line).

Note that all other dollar signs do need to be escaped, since they belong to the Bash script:

```
n=\$(zcat < $infile |  awk '/^>/ {if (seqlen) print seqlen; seqlen=0; next} {seqlen+=length(\$0)} END {print seqlen}' | awk -v x=100 '\$1 < x' | wc -l)
echo "The number of reads shorter than 100 in" $infile "is" \$n > filtered_sequences_${simpleName}.txt
```

Last but not least, let’s specify the output. We can again copy from the process above, changing the file name to match the output of this process:

```
output:
	path "filtered_sequences_${simpleName}.txt" 
```

Hopefully this is enough, and our script is ready to run:

```
nextflow run pipelines/hello-workflow.nf
```

Let’s check the output:

```
ls results
cat results/filtered_sequences_Frank.txt
```

Thankfully, the expected files are there!

Let’s move on to the next bit. If we open the NF script again, you’ll notice that the minimum read length is hard-coded in the script. How can we pass it as a parameter instead?

First, we need to tell the process that it now takes two inputs: the input file and the minimum length. To do so, we add a second line to the input block:

```
input: 
	tuple val(simpleName), path(infile) 
	val min_length 
```

The `val` keyword tells NF that `min_length` is a variable. 

Next, we edit the script body to accommodate this parameter. We replace the hard-coded value (100) with `${min_length}`. It appears twice: once in the first line and once in the second.

```
n=\$(zcat < $infile |  awk '/^>/ {if (seqlen) print seqlen; seqlen=0; next} {seqlen+=length(\$0)} END {print seqlen}' | awk -v x=${min_length} '\$1 < x' | wc -l)
echo "The number of reads shorter than" ${min_length}" in" $infile "is" \$n > filtered_sequences_${simpleName}.txt
```

Now this process requires two inputs. How do we provide them?

The most flexible option is to pass the parameter from the command line, using the special `params` variable. In the workflow, we update the process invocation like this:

```
countShortSequences(input_ch, params.min_length)
```

Note that the input is positional: if in the `input` directive we specify the file first and then the variable, the process call must follow the same order.

Then we can run the pipeline with:

```
nextflow run pipelines/hello-workflow.nf --min_length 100
```

We use the double dash (`--`) because this is a script parameter. NF options use a single dash (`-`, do you remember `-before` and `-f` when we ran the clean up?)

Let’s check the output again:

```
cat results/filtered_sequences_Frank.txt
```

Now let’s try a different minimum length:

```
nextflow run pipelines/hello-workflow.nf --min_length 40
```

As expected, the output is different:

```
cat results/filtered_sequences_Frank.txt
```

Sometimes it’s useful to define sensible default values for our parameters, so let’s do that now.

Between the `process` and the `workflow block`, add:

```
params.min_length = 50
```

Now we can run the pipeline without explicitly specifying the parameter:

```
nextflow run pipelines/hello-workflow.nf
cat results/filtered_sequences_Frank.txt
```

Now it’s your turn. Try to complete the third step of the pipeline (filter out sequences shorter than a given length), using the process we just implemented as an example.

Things to keep in mind while doing this:

- what is my input?
- is it a single input (e.g. a file), or do I need additional values or parameters?
- what is my output?
- should I publish the output (i.e. make it available once the pipeline completes)?

But also:

- which variables are NF variables?
- which variables are Bash variables?
- for which variables do I need to escape the dollar sign?

You wouldn’t believe how much time I’ve spent debugging issues caused by confusing NF and Bash variables!

**Solution**

In the `process` block:

```
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

```

Regarding dollar-sign escaping: we need to escape `$0` twice in the script body. All other variable are NF variables and therefore do not need escaping.

In `workflow` block:

```
removeShortSequences(input_ch, params.min_length)
```

Let's test it:

```
nextflow run pipelines/hello-workflow.nf
ls results/
```

Our filtered FASTA file are here!

We only have a final step left! We need to generate a short report by concatenating the two files outputted by the first and second processes.

Let’s start by editing the script body of the `createLog()` process. This helps us understand what inputs we need and what we expect as output, including which files should be saved (copied) in the `results` folder:

```
cat total_sequences.txt filtered_sequences.txt > $reportfile
```

We need the files created in the first two steps and a name for the output file. 
So, let’s update it to:

```
cat $log1 $log2 > "${simpleName}.log"
```

`$log1` and `$log2` are the files produced in the first two steps. To keep the output name consistent with the other processes, I've used the name of the *Lactobacillus* phage (stored in `${simpleName}`).

Here, we don’t escape the dollar sign, because these are NF variables.

Now it’s clear what we expect as input: two files and a variable. These elements all belong to the same sample, therefore we can define them as a tuple in the `input` directive:

```
input: 
	tuple val(simpleName), path(log1), path(log2)
```

Why did we define two inputs, a tuple and a variable, for the `removeShortSequences()` process? Because the variable, `min_length` was shared across all task executions. Therefore it should not be grouped with the sample-specific information usually stored in tuples.

I prefer to always pass variables before files, but there’s no strict rule about argument order in NF.

The output is now clear: it’s a file that we want to copy, because this log is what we want to read after the computation is complete:

```
publishDir 'results', mode: 'copy'

input: 
	tuple var(simpleName), path(log1), path(log2) 

 output:
 	path "${simpleName}.log"
```

How do we build and pass this tuple as input to the `createLog` process?

We take advantage of the fact that the output of a process is actually a channel, which we can access as `processName.out`.

Here, we want to combine `countSequences.out` and `countShortSequences.out`, making sure that the two files from `Frank` are paired together, the two from `Hari` are paired together, and so on.

NF provides the `combine()` operator for this. If we went to the NF manual, we would read that:

> *“The combine operator produces the combinations (i.e., cross product, ‘Cartesian’ product) of two source channels. The `by` option can be used to combine items that share a matching key.”*

This is exactly what we need—we just need a matching key. In our case, the matching key is the *Lactobacillus* name (stored in `$simpleName`), which is also the variable we want in input. Win win!

Let's now create this combined channel in the `workflow` block, and then work backward to set up everything else we need in the other processes:

```
log_ch = countSequences.out.combine(countShortSequences.out, by: 0)
								   .view()
```

Here, `by: 0` tells NF that the matching key is in position 0 of the tuple (NF counts from 0, like Python, if you're familiar with it).

I've also added a `.view()` operator to inspect the channel before running the pipeline to make sure the combination is correct.


We only miss the matching key from the first two processes. Remember it needs to be in position 0  of an output tuples

In `countSequences()` we edit output as:

```
output:
	tuple val(simpleName), path("total_sequences_${simpleName}.txt")
```

This will output (or emit, in NF lingo) a tuple, where the first element (position 0) is the matching key.

We do the same in `countShortSequences()`:

```
output:
	tuple val(simpleName), path("filtered_sequences_${simpleName}.txt" )	 
```

Before testing the `log_ch`, let's add a `view()` operator to see if the first two processes return what we expect:

```
countSequences.out.view()
countShortSequences.out.view()


//log_ch = countSequences.out.combine(countShortSequences.out, by: 0)
//								   .view()
```

let's run:

```
nextflow run pipelines/hello-workflow.nf
```

We got what we expected:

```
[Hari, /Users/visconti/Nextflow/work/39/b91a08c54dc0a4c3732932cd44250f/filtered_sequences_Hari.txt]
[Frank, /Users/visconti/Nextflow/work/1d/58283d06880f40cba1f16d3fe4065b/filtered_sequences_Frank.txt]
[JackRabbit, /Users/visconti/Nextflow/work/47/b6eb8feafd54e4830da0043a0ab247/filtered_sequences_Frank.txt]
[Hari, /Users/visconti/Nextflow/work/cc/65d072f3a6a08760c8e5feed0791d9/total_sequences_Hari.txt]
[Frank, /Users/visconti/Nextflow/work/be/96b4f13161e6b8fc1f3798c1383970/total_sequences_Frank.txt]
[JackRabbit, /Users/visconti/Nextflow/work/61/5742c80ba45cfb3a3be0e06dd8b01b/total_sequences_JackRabbit.txt]
```

Now both channels have the matching key in position 0. Let’s see if the `combine()` operator we discussed earlier works as expected (we can remove the `view()` from the single channel):

```
log_ch = countSequences.out.combine(countShortSequences.out, by: 0)
   						   .view()
```

That’s exactly what we wanted:


```
[JackRabbit, /Users/visconti/Nextflow/work/39/04b6ae96cc763db701b5bd908e891a/total_sequences_JackRabbit.txt, /Users/visconti/Nextflow/work/c5/c4163d880c8c46826e22102a1a8bca/filtered_sequences_Frank.txt]
[Hari, /Users/visconti/Nextflow/work/3a/72d848d383830f519b7b3e83a6185a/total_sequences_Hari.txt, /Users/visconti/Nextflow/work/5b/6c072c552017399f6c0dc11456710c/filtered_sequences_Hari.txt]
[Frank, /Users/visconti/Nextflow/work/58/a2afabaa2755a28a47b0241d6b8696/total_sequences_Frank.txt, /Users/visconti/Nextflow/work/92/2b2612ce98ec48ec955a84e498309c/filtered_sequences_Frank.txt]
```

Now we can call our final process, `createLog()`, using this `log_ch` as input (and remove the `view()` from above):

```
log_ch = countSequences.out.combine(countShortSequences.out, by: 0)

crateLog(log_ch)
```

Finally, let's run the pipeline and check the results:

```
nextflow run pipelines/hello-workflow.nf
ls results/
cat results/Frank.log
```

We can now see that the `results` directory is quite busy and a bit cluttered.

Do we really need the files created by `countSequences()` and `countShortSequences()` here? 
Probably not. How do we remove them? By deleting the `publishDir` directive from these two processes.
Let's do it!

Before re-running our modified pipeline, let's remove all files from our `results` directory:

```
rm results/*.*
```

We are ready to test the workflow execution:

```
nextflow run pipelines/hello-workflow.nf
ls results/
```

Success! We have developed our first NF pipeline!

Suppose that now we accidentally delete a file we still need:

```
rm results/Frank.log
```

Oh no! Do we need to re-run everything? Actually, no. We can use the NF option `-resume`.

With `-resume`, processes that have already been executed with the same code, settings, and inputs, and for which the output is still available, will be skipped.  This means NF will only run processes that have changed or that receive new inputs or parameters, or for which the output is not available. 

Let’s try it:

```
nextflow run pipelines/hello-workflow.nf -resume -ansi-log false
```

Here, I’ve also added `-ansi-log false` so that each task is printed on a separate line.

Quick reminder about dashes:

- we use a single dash (`-`) for NF options like `resume` and `ansi-log`; and
- we use a double dash (`--`). For process parameters passed to out pipeline (such as `--min_length` earlier).

We can see that all process are marked as cached. NF noticed that all process outputs are already available in the respective `work` directories, and that the process code hasn’t changed. Therefore, it only executes the missing `publishDir` directive for the `Frank.log` file we deleted.

This works because the `work` directories are intact. If we had cleaned them up with  `nextflow clean` then the cached outputs would no longer be available, and NF would re-run all processes.

Let's try it:

```
nextflow log
nextflow clean -before nostalgic_moriondo -f
nextflow clean nostalgic_moriondo -f
nextflow log

nextflow run pipelines/hello-workflow.nf -resume -ansi-log false
```

All processes ran again from scratch!

When is `-resume` useful?

- during pipeline development: we can iterate more quickly, since only the process(es) we’re actively working on will be re-run to test your changes; and 
- in production: if something goes wrong, we can fix the issue and relaunch the pipeline, which will resume from the point of failure, saving time and computational resources.

We have now covered all the material for this workshop.

What we haven’t covered are:

- modules, which allow us to reuse processes in other workflows;
- containers, which make our analysis more reproducible by freezing the execution environment;
- config files, which allow us to customise the behaviour of a pipeline, adapt it to different environments, and optimise resource usage without changing the workflow code itself; and
- nf-core: a community effort to develop and maintain a curated set of scientific pipelines as well as a set of tooling and guidelines that promote open development, testing, and peer review.

I hope this workshop has given you a taste of the power of NF, and that you’ll use it to develop your own pipelines!

Remember that the four chapters we covered during the workshop (*"Getting started"*, *"Hello processes"*, *"Hello channels"*,and *"Hello workflows"*)  are available in the `tutorials` folder of the cloned repository:

```
ls tutorials
```

Finally, the final version of the NF pipeline we developed together is available in the `pipelines` subfolder as `hello-workshop.nf`:

```
ls pipelines
```

I hope you enjoyed this workshop as much as I did!

