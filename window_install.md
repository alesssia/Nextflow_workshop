# Installing Nextflow on Windows 10 and 11


## 1. Install Windows Subsystem for Linux v2 (WSL 2)

### Before you start

- To install WSL 2, you will need Administrator (“admin”) privileges on your laptop

	If you have a device provided by an institution that does not give you admin rights, please either request that they:

	- grant you admin rights (temporarily or otherwise) to install WSL 2 yourself OR
	- install WSL 2 for you

	This process may require authorization, which can take some time. Please plan accordingly.
	
- After installing WSL 2, you will need to restart your computer. Make sure you have saved any work.

### What is WLS 2, why Linux, and why Ubuntu?

WSL 2 is a fully fledged Linux environment that runs completely within your Windows 10 or 11 operating system.

We need such a fully fledged Linux environment because Nextflow can be used on any POSIX-compatible system, such as Linux and macOS. 

While many Linux distributions exist, WSL 2 officially supports only a limited set due to how it integrates with Windows. We will use `Ubuntu 24.04 LTS`, as it is the default distribution recommended by both WSL 2 and the Nextflow developers at Seqera.

### Install WLS 2

We will install Ubuntu *via* the Microsoft Store. 

> The [Seqera document linked in the main page](https://seqera.io/blog/setup-nextflow-on-windows/) explains how to perform the installation using the Windows Powershell command prompt. If you prefer that approach, please follow the instruction there or on the [Microsoft website](https://learn.microsoft.com/en-gb/windows/wsl/install).


1. Open the Windows Start Menu (four blue squares in the bottom-left corner of your screen), or press the Windows key on your keyboard and search “store”. Open the Microsoft Store. 

2. In the Microsoft Store search bar, type `wsl ubuntu`, and select the `Ubuntu 22.04.06 LTS` option (if not available, select `Ubuntu 20.04.06 LTS`)
    - If prompted with a pop-up asking whether you want to make changes to your device, select `Yes`
    - The installation may take several minutes depending on your PC performance and internet connection

3. Once the installation is complete, restart the computer.

4. After restarting, reopen the Windows Start Menu. In the search bar, type `Ubuntu`. Select `Ubuntu 22.04.06 LTS` or `Ubuntu 24.04.01 LTS` to open the bash prompt
	- The first time Ubuntu starts, you will be prompted to create a UNIX username and password.
	- The username that you select can be different from your Windows username. 


## 2. Update Ubuntu and install some piece of software within WSL 2

1. After setting your username and password (see above), update Ubuntu from the Linux shell by using the following command	

	```
	sudo apt update && sudo apt upgrade
	```
	
	You may be prompted to enter your password. This is the password you just created for Ubuntu. and will not show up on the screen as you type it in. This is a security feature of the terminal, and is normal behaviour.

2. Install the necessary software dependencies by using the following command	

	```
	sudo apt install git build-essential autoconf automake libtool default-jdk curl
	```

	Again, this step may take several minutes depending on your PC performance and internet connection


3. Verify that `java`, `git`, and `curl` were successfully installed by typing:


	```
	git --version
	java -version
	curl
	```

	Expected output should resemble the following:

	```
	$ git --version
	git version 2.51.1
	$ java -version
	openjdk version "17.0.10" 2024-01-16
	OpenJDK Runtime Environment Temurin-17.0.10+7 (build 17.0.10+7)
	OpenJDK 64-Bit Server VM Temurin-17.0.10+7 (build 17.0.10+7, mixed mode)
	$ curl
	curl: try 'curl --help' or 'curl --manual' for more information
	```

## 3. Install Nextflow within WSL 2


1. Download Nextflow in a temporary directory and install it by using the following command	

	```
	mkdir temp
	cd temp
	curl -s https://get.nextflow.io | bash
	```
	
2. Make it available on your path by using the following command	

	```
	sudo cp nextflow /usr/bin
	```

3. Make sure that Nextflow is executable by executing the following command:

	```
	sudo chmod +x /usr/bin/nextflow
	```
   
4. Verify that `nextflow` was successfully installed by typing:


	```
	nextflow info
	```

	Expected output should resemble the following:

	```
	$  nextflow info
   Version: 25.10.3 build 10983
   Created: 22-01-2026 15:34 UTC (16:34 CEST)
   System: Mac OS X 26.2
   Runtime: Groovy 4.0.28 on OpenJDK 64-Bit Server VM 17.0.10+7
   Encoding: UTF-8 (UTF-8)
	```

## Credits

Since the sources below did a better job than I could, I have honestly just mixed and matched content from them.

- Seqera: https://seqera.io/blog/setup-nextflow-on-windows/
- The Carpenties: https://carpentries.github.io/workshop-template/install_instructions/#shell-windows-wsl-store