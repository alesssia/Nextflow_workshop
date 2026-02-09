# Hello channels!


We’ll continue modifying our `hello-process.nf` file. However, if at any point you got lost, you can refer to the script `hello-channel.nf`, also located in the `template` folder, which contains all the edits we’ve made so far.

If—and only if—you got lost, run the following command:

```
mv pipelines/hello-channel.nf pipelines/hello-process.nf
```

This will overwrite your current file with the version we’ve built up to this point.
Alright, let’s continue. Open the file with:

```
nano hello-process.nf
```


Here, we are already using one NF channel created with the `fromPath` command. NF offers multiple commands for creating channels, called *channel factories* in NF lingo.

So far, this command takes a single file as input—but we actually have three *Lactobacillus* phages to process. Let’s modify it so it takes as input any file ending with `.fasta.gz` inside the `data` folder:

```
workflow {
	
	//This is an input channel
	input_ch = channel.fromPath("data/*.fasta.gz")
	
   countSequences(input_ch)
}

``` 

Now save and close the file, then run the workflow:


```
run pipelines/hello-process.nf
```


You should now see that NF runs three tasks (`[100%] 3 of 3 ✔`). Before looking at the results, let’s pause to introduce a few more concepts that will be useful when developing your pipeline.

I mentioned earlier that each NF task has its own hash, but here we see three tasks and only one hash. What happened?

NF overwrites the hash each time a new process is started. To see all the hashes generated during a run, we can use the following command-line parameter:


```
nextflow run pipelines/hello-process.nf -ansi-log false
```

```
[da/be5b31] Submitted process > countSequences (1)
[b5/b366f6] Submitted process > countSequences (2)
[14/b1afb1] Submitted process > countSequences (3)
```


ow the output is different, and the three hashes for the three processes are shown. This can be very useful for debugging, as it allows you to identify which task failed and inspect the corresponding work directory.

Let’s take a moment to unpack what happened here. With a simple edit (adding a wildcard), Nextflow understood that:

- it needed to process multiple files
- it had to initiate a separate process for each file
- each process could run in parallel

This is just one example of the magic Nextflow provides: transparent, automatic parallelization across multiple samples.

Nextflow channels are designed to let us operate on their contents using operators. Let’s start with a simple one called `view()`. It allows you to inspect the contents of a channel.


```
nano hello-process.nf
```

```
workflow {
	
	//This is an input channel
	input_ch = channel.fromPath("data/*.fasta.gz")
							.view()
	
   countSequences(input_ch)
}
```


```
run pipelines/hello-process.nf
```

Using `view()`, NF prints the contents of a channel to the console. Again, this is very useful for debugging.

Let me stress one important peculiarity of Nextflow. As we’ve seen, Nextflow takes care of parallelization, but it does not process files in the order in which they are provided. In this example, we will expect `Frank`, `Hari`, and `JackRabbit`, but Nextflow may process them in any order.
Never rely on the input order being preserved.

Now let’s go back and check the results of the execution. What do we expect?
Since NF ran three tasks, we would expect three output files. Let’s check:

```
ls results
```

Sure enough, there is only one file! This happened because the output filename is hardcoded in the NF process, and each task execution overwrote the previous one.

So how do we make the filenames unique? A common approach is to include some unique piece of metadata from the inputs (received through the input channel) in the output filename. For example, we could use the phage name.

To do this, we first need to extract the phage name from the input path.

NF provides a very useful operator for this: `.map()`.

```
nano hello-process.nf
```

```
workflow {
	
	//This is an input channel
	input_ch = channel.fromPath("data/*.fasta.gz")
							.map { file -> [file.simpleName, file] }
							.view()
	
   //countSequences(input_ch)
}
```

Notice that we’re using curly braces with `map`, creating what’s called a *closure*. The code inside the closure is executed once for each item in the channel.
We define a temporary variable for the value being processed—here we call it `file`, but it could be any arbitrary name. This variable is only available within the scope of the closure.

The `simpleName` property returns the filename without the extension, while `name` returns the filename with the extension.

At this point, the workflow will not run correctly: we still need to fix a few things. 
For now, comment out the call to the process and just explore the result of the `map`.

Save the file, exit, and execute.


```
run pipelines/hello-process.nf
```

```
[JackRabbit, /Users/visconti/Documents/Teaching/undergrads/Nextflow/data/JackRabbit.fasta.gz]
[Frank, /Users/visconti/Documents/Teaching/undergrads/Nextflow/data/Frank.fasta.gz]
[Hari, /Users/visconti/Documents/Teaching/undergrads/Nextflow/data/Hari.fasta.gz]
````

This may look like a double input, but it’s actually a single one (note the square brackets). 
Specifically, this input is a tuple, so we need to update the process input definition accordingly:

```
input:
	tuple val(simpleName), path(infile) 
```

We can then use these values inside the script:

```
 script:
 """
 n=\$(zcat < $infile | grep '^>' | wc -l)
 echo "The number of reads in" $infile  "is" \$n > total_sequences_${simpleName}.txt
 """
```

Note that I’m not escaping the dollar sign for `simpleName` because it is a Nextflow variable. I’m enclosing it in curly brackets because Bash interpolation can be tricky, and using curly brackets is safer and more explicit.

Let’s also update the output definition.

```
output:
	path "total_sequences_${simpleName}.txt"  
```

Note that I switched from single quotes to double quotes. This is one of those Nextflow interpolation quirks. You’ll learn all these quirks the hard way as you keep using Nextflow! It can have a steep learning curve!

Before saving, uncomment the process call in the workflow (`countSequences(input_ch)`). We can also clean up the `view` statements now that the mechanism is clear, and finally uncomment the call to the process.

```
workflow {
	
	input_ch = channel.fromPath("data/*.fasta.gz")
							.map { file -> [file.simpleName, file] }
							
   countSequences(input_ch)
}
```

```
run pipelines/hello-process.nf
```

It seems to have run without any issues. Let’s check the results folder:

```
ls results
```

Sure enough, our three files are here! Let’s take a look at their contents:

```
cat results/total_sequences_*.txt
```

We’ve now had a first taste of Nextflow channels and operators. Nextflow offers many operators that can perform both strange and useful tasks, but their behaviour can sometimes be tricky to follow. If you ever feel lost, don’t hesitate to consult the Nextflow documentation: it’s one of the best out there. 

Also, feel free to abuse the `.view()` operator to inspect what’s happening inside your workflow!

Now, let’s move on to the third chapter: **Hello, workflow!**













