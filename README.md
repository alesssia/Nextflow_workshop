# Introduction to Workflow Orchestration Managers with Nextflow


This repository contains the material for the *Introduction to Workflow Orchestration Managers* workshop, developed for the *Advanced Bioinformatics module* of the MSc in Genomic Medicine at King’s College London.

The workshop provides a brief introduction to Nextflow, a popular workflow orchestration manager. It includes an overview of its key features with practical examples, and simple guidance on best practices for implementing workflows.

The workshop is delivered as a live coding session, but it can also be followed at your own pace using the materials available in the `tutorials` folder.


### Instructor

- Dr Alessia Visconti: [alessia.visconti@unito.it](mailto:alessia.visconti@unito.it)



## Learning objectives

After the workshop, participants will have gained an understanding of

- how to develop and run a Nextflow pipeline
- how to locate outputs and other relevant files in the `work` directory
- how to save results to a specified output directory
- how to use basic channel factory to provide input to a process
- how to pass and retrieve multiple input/output elements through a channel
- how to use basic operators to manipulate channelss
- how to use channels to chain processes together
- how to use variable inputs provided at runtime via command-line parameters
- how to use Nextflow tools to relaunch a pipeline using cached task execution and to clean up old work directories


## Target audience and prerequisites

The workshop is designed for those interested in improving the efficiency and reproducibility of their, sometimes complex, computational analysis pipeline.

Participants do not need any prior knowledge of the tools presented in the workshop, but they should have a basic understanding of Unix command-line usage and Git. 
Specifically, participants should be familiar with Unix commands such as `ls`, `cd`, and `cat`. Familiarity with the text editor `nano` is helpful but not essential. Participants should also be able to use the `git clone` command.

Participants must have access to a computer with a Mac, Linux, or Windows operating system (not a tablet, Chromebook, etc.) that they have administrative privileges on. They should have a few specific software packages installed (listed below). 


## What do you need to do before joining the workshop?


### 1. Install Nextflow

The installation process may take some time. Please plan accordingly. 

Installation instructions depend on your operating system:

- **Unix or macOS users**:
  Follow the instructions available here:
  [https://www.nextflow.io/docs/latest/install.html](https://www.nextflow.io/docs/latest/install.html)

  Make sure to install Java before installing Nextflow.
  When installing Nextflow, I recommend using the **self-install** method.
  
  Don't forget to check that the Nextflow has been correctly installed using the following command:

  ```
  nextflow info
  ```

- **Windows (10 or 11) users**:
  You will need to install Nextflow via *Windows Subsystem for Linux (WSL)*. To this end, I have created a dedicated installation guide, available [here](window_install.md)
  This guide is a simplified version of the instructions provided by the Nextflow developers at Seqera. Their full, detailed documentation is available at::
  [https://seqera.io/blog/setup-nextflow-on-windows/](https://seqera.io/blog/setup-nextflow-on-windows/)
  If you choose to follow this document, you do not need to install all the software listed there for the workshop, but only the components outlined in the high-level steps below:
  	1. Install Windows PowerShell
	2. Configure the Windows Subsystem for Linux (WSL2)
	3. Obtain and Install a Linux distribution (on WSL2). 
	
		**Important**: the last command should be `sudo apt install net-tools git build-essential autoconf automake libtool`. 
		This will also install Git and a few additional tools that may be useful during the workshop.
  	4. Installing Nextflow (up to and including step 4)


**If you get stuck, please contact me at alessia.visconti@gmail.com to get assistance before the workshop starts.**

### 2. Clone this repository

- You need to clone this repository to a location you can access on your laptop. 
  To do so, run the following command:

	```
	git clone https://github.com/alesssia/Nextflow_workshop.git
	```

- Access the cloned repository using the `cd` bash command, and print its location using the `pwd` bash command:

	```
	cd Nextflow_workshop
	pwd
	```
	
	Expected output should resemble the following:
	
	```
	/Users/visconti/Documents/Teaching/Nextflow_workshop
	```

-  Please write down this path and keep it in a safe place: we will need it during the workshop.

**Windows users**: This should be done *via* the Bash prompt. To access it, reopen the Windows Start Menu. In the search bar, type `Ubuntu`. Select `Ubuntu 22.04.06 LTS` or `Ubuntu 24.04.01 LTS`.


### 3. Read the preparatory material

- I've prepared a short introduction to workflow orchestration managers and Nextflow in particular, which is available [here](preparatory_material.md). Please read it before the workshop starts.



## What could you after following the workshop?

If you became interested in Nextflow during this workshop, I highly recommend exploring the excellent training materials developed by [Seqera](https://seqera.io/). They are available at:
[https://training.nextflow.io/](https://training.nextflow.io/)

Nextflow also has very well-curated documentation, which you can find at:
[https://nextflow.io/docs](https://nextflow.io/docs)

In addition, there is an incredibly vibrant and helpful community, both on the Seqera community forum:
[https://community.seqera.io/](https://community.seqera.io/)
and on Slack:
[https://nextflow.slack.com/](https://nextflow.slack.com/)

Finally, don’t forget to check out the nf-core community at:
[https://nf-co.re/](https://nf-co.re/)

They develop and maintain a curated collection of high-quality, peer-reviewed Nextflow pipelines, along with excellent best practices and tooling.


## License

The material included is this repository is developed and maintained by Alessia Visconti and released under an open-source license [CC BY-NC-SA]([https://creativecommons.org/licenses/by-nc-sa/4.0/]).


:![CC BY-NC-SA imahe](cc_by-nc-sa.png)

## Special thanks:

- [Seqera](https://seqera.io/), for developing the [Hello Nextflow training](https://training.nextflow.io/latest/hello_nextflow/) course. I've drawn on their material for this workshop!
