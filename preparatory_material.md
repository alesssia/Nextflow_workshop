# Why are we offering you this workshop?

## What is a workflow?

Data analysis rarely consists of a single analysis step and usually involves a sequence of interconnected tasks. These tasks may include downloading data, performing quality control, cleaning and/or formatting dataset, and, finally, performing computational or statistical analyses. 

This ordered set of steps is called a workflow or a pipeline.

Workflows often require the use of multiple software tools and libraries, each designed for a specific task. You may need `curl` to download data, `FastQC` to perform quality control, and a custom R or python script for data cleaning, formatting, and analysis. Each tool performs one step of the workflow, and their outputs must correctly feed into the next step.

Traditionally, workflows have been assembled using general-purpose scripting or programming languages, most commonly Bash or Python, or, more recently, R. However, managing how tools interact, and ensuring that each step runs in the correct order with the appropriate inputs and outputs, can quickly become complex.

Additionally, these tools may need to be executed in different computing environments, ranging from a personal laptop to high-performance computing (HPC) clusters or cloud-based systems, such as Azure or AWS.

Moreover, data analysis is rarely performed on a single input (for instance, one biological sample), but on hundreds, if not thousands, of them. 

You may start to understand that, as workflows grow in size and are shared across research teams or run on different machines, the use of general-purpose scripting languages can become difficult to maintain, scale, and reproduce.

Using well-structured workflows, developed with dedicated workflow management tool, also helps make data analysis reproducible. Reproducibility means that anyone with the same code and the same data will get exactly the same results. While this seems obvious, there are several reason while a workflow may not be reproducible:

- Different software versions: the workflow developer may have used one version of a program, and the person reproducing it may be working with a different (newer or older) version. Even small version differences can lead to different results.

- Unclear data analysis flow or tool parameters: if steps (commands and parameters) are not documented properly, it’s hard for others to know exactly what was done and how.

- Variations across workstations and operating systems: as show in the paper presenting Nextflow [doi:0.1038/nbt.3820](https://doi.org/10.1038/nbt.3820), even when software versions and data analysis step are clearly presented, different operating system can sometimes lead to different results.

For all these reasons (complexity, scalability, portability, and reproducibility) we need workflow management systems!


## What is a workflow manager?

Workflow Management Systems, such as [Snakemake](https://snakemake.github.io/), [Galaxy](https://usegalaxy.org/), and [Nextflo2](https://nextflow.io/), are tools designed to help design, develop, and manage even very complex data analysis workflows. They are widely used in bioinformatics, but  have also been applied in imaging, physics, chemistry and many other scientific disciplines.

Key features of Workflow Management Systems are

- **Software management.** Workflow Management Systems help ensure that the correct software is used for each step of a workflow. This is often achieved through the use of containers.
  A container image is a stand-alone, executable package that includes everything needed to run a piece of software: the program itself, its libraries, dependencies, and configuration files. Containerised software will always run consistently, regardless of the computing environment.
  For instance, if an analysis step uses a custom script that requires R v4.3 along with the lme v4.1.1 and ggplot v2.4.0.1 R package, you could create a container that includes your script, the correct version of R and of these two packages. The Workflow Management System will then ensure that this step is run is executed within that container.

- **Portability and interoperability.** Workflows usually need to run on different computers or systems. For instance, you may develop a workflow on your own laptop (*e.g.*, a MacBook Pro with macOS Tahoe v26.2, my machine), but then execute it in on a HPC cluster (*e.g.*, x86_64 machine with Ubuntu 22.04.5 LTS, CREATE). A Workflow Management System by separating the workflow logic (the steps and the way the need to be executed) from the execution environment (the physical machine and its operating system), allows you to do this seamlessly.

- **Reproducibility.** Workflow Management Systems record all steps, inputs, outputs, parameters and software versions (collectively know as provenance [doi:10.1145/1376616.1376772](https://doi.org/10.1145/1376616.1376772)), making it possible to reproduce exactly the same results when using the same data.

- **Run-time management.** Workflow Management Systems track which steps of a workflow have already been completed for which samples and which steps/samples still need to run. For instance, if you're processing 1,000 samples and your computer crashes halfway through, a Workflow Management system can resume from where the processing stopped instead of reanalysing all samples. Similarly, if you later add new samples, only those new samples will be processed.

- **Parallelisation.** When processing large datasets including multiple samples, especially on HPC clusters, it is  common to process multiple samples simultaneously (in parallel) to reduce the total runtime. A Workflow Management system handles parallelisation in a way that is transparent from the user.

In summary, Workflow Management Systems save time, reduce errors, and make scientific analyses easier to reproduce, share, and maintain, even for extremely complex multi-step pipelines.


## Why Nextflow?

This is a very difficult question! I first discovered Nextflow (I believe) in 2016. Learning it was extremely challenging (the learning curve is real, and I still struggle with it sometimes), but it has also been extremely rewarding.  It offered all the features I needed plus an incredibly welcoming and helpful community.

Fast forward ten yers, Nextflow is now widely used in bioinformatics. It has all the features one needs to develop production-ready workflow, and many ready-to-use pipelines are shared through [nf-core](https://nf-co.re/), a global community collaborating to build open-source Nextflow components and pipelines. This makes it easy to adopt well-tested workflows without building everything from scratch. The community is still incredibly welcoming and helpful, just much bigger. 

So, what are the key features that make Nextflow so powerful?

- **Fast prototyping,** Despite Nextflow has a relatively steep learning curve and sometimes a complex, not-always-intuitive syntax, it allows you to rapidly build workflows without getting involved in low-level programming details. Moreover, Nextflow makes it easy to reuse existing scripts and tools (module), enabling the developing and testing of new workflows quickly. 

- **Reproducibility and container support.** Nextflow ensures that workflows are fully reproducible. It supports container technologies, such as Docker and Singularity, as well as the package manager Conda, to manage software dependencies. Additionally, Nextflow automatically tracks all inputs, outputs, parameters, and software versions.  Combined with GitHub integration for version control, this allows you to create self-contained pipelines that can be run again later (on your own computer, a collaborator’s machine, an HPC cluster, or a cloud platform) and produce exactly the same results. This is q cornerstone of scientific collaboration and open science.

- **Portability and interoperability.** Nextflow separates the workflow logic (the steps of the analysis) from the execution environment (how and where it runs). This means the same pipeline can run on a laptop, an HPC cluster, or a cloud service without modifying the workflow itself. One Nextflow limitation is its intrinsic reliance on POSIX-compatible systems, such as Linux and macOS. This makes using Nextflow on Windows more cumbersome, as you may have noticed when installing it via WSL 2. However, keep in mind that most bioinformatics software is developed and tested only on POSIX systems, so this isn’t really Nextflow’s fault.

- **Flexibility.** Nextflow allows you to mix and match tools written in different programming languages (*e.g.*, bash, Python, R) and incorporate existing scripts and tools. This makes workflows highly flexible.

- **Simple parallelism.** Nextflow automatically identifies independent tasks that can be run simultaneously, making it straightforward to execute analysis in parallel. This automatic parallelisation speeds up analyses, especially for workflows with large datasets or many independent steps. 

- **Scalable and efficient.** Nextflow can handle workflows of any size, from small local analyses with a handful of steps and/or samples to massive pipelines processing thousands of samples in a extremely complex multi-step flow. Because it automatically manages computational resources and can seamlessly run multiple steps in parallel, it is well suited for large-scale scientific projects.

- **Continuous checkpoints and re-entrancy.** During execution, Nextflow tracks all intermediate results. If a workflow stops unexpectedly (*e.g.*, due to a crash, or a system shutdown), or if new data are added, it can resume from the last successful completed step without re-running completed tasks. 

In summary, Nextflow allows you to quickly develop even very complex workflows, run them anywhere. It handles complex analyses efficiently, and reproduces results reliably. It lets you focus on the science instead of the technical headaches of challenges multiple tools, software versions, and computing environments, saving time you can dedicate for that break that you definitely deserve for having reached the end of this reading!
