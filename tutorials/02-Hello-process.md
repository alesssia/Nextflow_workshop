# Chapter 2: Hello processes!


If we list the contents of the cloned GitHub repository again, we’ll see a `pipelines` folder containing several NF scripts:

```
ls pipelines
```

In this chapter we will use the NF script `Hello-process.nf`. This is a very bare example, so let's take a closer look at it.

We will be editing our file using a shell-based text editor called `nano`. I have chosen it because it is usually already installed on most machines, it is relatively simple to use, and it is more than sufficient for what we are going to do today. Please feel free to use your favourite editor if you prefer.


```
nano pipelines/hello-process.nf
```

A NF script involves two main components: one or more processes, and the workflow itself.

Each process describes the operation(s) that the corresponding step in the pipeline should perform, while the workflow describes the dataflow logic that connects the various steps.

A process is defined using the keyword `process`, followed by the step name, and its body, delimited by curly brackets. In this example, we have a process called `countSequences` that reads an input file (directive: `input; we understand it is a file because it's specified using the keyword `path), does something (directive: `script`) and writes an output to a file named `total_sequences.txt` (directives: `output`).

Please note this NF quirk: we need to escape the Bash dollar sign (`$`) within the script body (*e.g.*, `n=\$(`) but not the NF dollar sign (`$infile`). This is due to the way NF performs string interpolation for Bash and NF variables. Whenever you are unsure whether to escape or not, ask yourself: *“Is it a NF variable (no escape) or a Bash variable (escape)?"*


Let's now move to the `workflow` block. 
The workflow definition starts with the keyword `workflow`, followed by the workflow body, which is again delimited by curly braces.

Within the body, we see our first definition of a channel, an important data structure in NF. For the time being, just note a few points (we will explore the logic of NF channels in detail in the next chapter):

1. this channel specifies a file, as indicated by the keyword `path`;
2. this channel is passed as input to the process `countSequences`.
3. the input filename is hardcoded in the script,
4. as a convention, channel names terminates with `_ch`

We have not yet modified the file, but let's exit using the `nano` command for save and exit, to get familiar with them. We need to use `Ctrl+O` to write out, `Enter` to confirm the file name, and `Ctrl+X` to exit.


Now let's execute this workflow with

```
nextflow run pipelines/hello-process.nf
```

The output should look something like this:

```
N E X T F L O W   ~  version 25.10.3

Launching `pipelines/hello-process.nf` [zen_lagrange] DSL2 - revision: c00ad06a38

executor >  local (1)
[42/028ad9] countSequences (1) [100%] 1 of 1 ✔
```

This output provides the following information:

- the NF version;
- which script was run, along with a randomly generated name for this workflow execution. Each of us will have a different name, so do not worry if yours differs from mine, these names are generated randomly by NF; and
- which steps of the workflow have been executed. For example, `countSequences` ran once and was 100% completed (1 analysis out of 1, our hard-coded Frank phage).

NF generates a hash for each task. Again, each of us will have a different hash, as these are generated randomly.

Each process may run one or more times, and each execution is called a task. Each task has its own hash and its own directory, which corresponds to the file structure within the work directory created by NF.

What does this mean in practice? Let's see this by listing the contents of our folder:

```
ls
```

We can see that there is now a directory called `work`, which has been created by NF. Let’s check its contents:

```
ls work
```

You can see that it contains a subfolder matching the first part of our hash, `42`:

```
ls work/42
```

If we list the contents of this subfolder, we can see another subfolder whose name partially matches the second part of our hash. Let’s also list the contents of this subfolder:

```
ls work/42/028ad9 [autocomplete]
```

We can see the input file (`Frank.fasta.gz`) and the output file (`total_sequences.txt`).
However, let’s take a closer look using:

```
ls -la work/42/028ad9 [autocomplete]
```

First, there are multiple hidden files (those starting with a dot):

- `.command.begin` includes instructions for beginning of the execution; 
- `.command.run` is the full script run by NF to execute the process call;
- `.command.sh` is the command that was actually run by the process call, and that is the one included in the `script` body of a process. Let's look at it:

```
cat work/42/028ad93c883853abfeaea5c73c1b6f/.command.sh
```

- `.command.out` and `.command.err` are `stdout` and `stderr` and tell NF were output and error messages should be emitted;
- `.command.log` is their combination; and
- `.exitcode` is the exit code resulting from the command, usually, an exit code of zero indicates that the computation has happened without errors.

The next thing to notice is that our input file has not been copied here; instead, it is a symlink, a type of file that acts as a virtual pointer to the actual file stored elsewhere in the file system. In this case, the actual file is located at:

```
/Users/visconti/Nextflow/data/
```

This allows us to keep all computation in an isolated location (our `work` subfolder) whiteout duplicating any data.

We can also see our output file, `total_sequences.txt`.

We may agree that having the output file buried within all these nested directories is not very convenient. To fix this, we can instruct NF to create a `results` folder where our output will be saved.

```
nano pipelines/hello-process.nf
```

add a directive above input

```
	publishDir 'results', mode: 'copy'
```


This command tells NF to copy the output file to a directory called `results`. If the directory does not exist, NF will create it automatically.

Let’s run the workflow again:

```
nextflow run pipelines/hello-process.nf

ls 
ls results
cat results/total_sequences.txt
```

Not all files created by a process need to be listed in the process’s output section. For instance, intermediate files don't need to not be copied, allowing us to delete them once the workflow has finished.

Speaking of this, let’s see how to perform a clean-up using some NF commands:

```
nextflow log
```

This command displays a list of all workflow runs, along with their (randomly generated) names. 

Remember that each time we re-run a workflow, it generates a new (randomly-generated) name and a new (randomly-generated) hash, creating a different `work` subfolder. 

Let’s run it again:

```
nextflow run pipelines/hello-process.nf
```

and again:

```
nextflow run pipelines/hello-process.nf
```

Let’s now take a look at the contents of the `work` subfolders:

```
ls -R work/
```

If we want to remove all files generated during a specific workflow run, we can copy its name and use the following command:

```
nextflow log
nextflow clean reverent_neumann -f [select the first]
nextflow log
```

Instead of removing workflow runs one by one, we can use the `-before` option to delete all runs that were executed before a specific run:

```
nextflow clean -before agitated_hawking  -f [select the last]
nextflow log
```

Let's remove all of them:

```
nextflow clean adoring_brenner -f 
nextflow log
```

If we now list the content of the `work` subfolder:

```
ls -R work/
```

Everything has been deleted, which is why it is important to “copy” all the files we need using `publishDir`.

We have now grasped the basics of NF processes.
So, let’s move on to the third chapter: Hello, channels!


