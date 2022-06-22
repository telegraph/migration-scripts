# create package

This is a simple bash script tool who reads the configured input file (containing a list of paths)
and in base of the number of chunks preconfigured create a package with these filters build it and download it in output folder

> Open the script "create-package.sh" and setup the configuration section:

    INPUT_FILE="./input/input-urls.txt"
    OUTPUT_FILE="./output"
    PACKAGE_NAME="sample-package"
    CHUNKS=500
    USERNAME="admin"
    PASSWORD="admin"
    PROTOCOL="http://"
    HOST="localhost"
    PORT="4502"
    DELETE_MODE="false"

> How to run it:

    bash create-package.sh

> The script also generate in output folder the file info.log with the following information: 

    /aem-scripts-tools/WEB-1860/create-package/output
    MacBook-Pro:output furioj$ ls -l
    total 1464
    -rw-r--r--  1 furioj  709105253  435059  9 Oct 10:26 info.log
    -rw-r--r--  1 furioj  709105253   20941  9 Oct 10:26 sample-package-1.zip
    -rw-r--r--  1 furioj  709105253   20271  9 Oct 10:26 sample-package-10.zip
    -rw-r--r--  1 furioj  709105253   19735  9 Oct 10:26 sample-package-11.zip
    -rw-r--r--  1 furioj  709105253   21535  9 Oct 10:26 sample-package-12.zip
    -rw-r--r--  1 furioj  709105253    9993  9 Oct 10:26 sample-package-13.zip
    -rw-r--r--  1 furioj  709105253   21003  9 Oct 10:26 sample-package-2.zip
    -rw-r--r--  1 furioj  709105253   20587  9 Oct 10:26 sample-package-3.zip
    -rw-r--r--  1 furioj  709105253   18336  9 Oct 10:26 sample-package-4.zip
    -rw-r--r--  1 furioj  709105253   22507  9 Oct 10:26 sample-package-5.zip
    -rw-r--r--  1 furioj  709105253   20796  9 Oct 10:26 sample-package-6.zip
    -rw-r--r--  1 furioj  709105253   20420  9 Oct 10:26 sample-package-7.zip
    -rw-r--r--  1 furioj  709105253   19975  9 Oct 10:26 sample-package-8.zip
    -rw-r--r--  1 furioj  709105253   20679  9 Oct 10:26 sample-package-9.zip

> cat info.log | cut -d ":" -f 1 | uniq -c
    
    500 sample-package-1 
    500 sample-package-2 
    500 sample-package-3 
    500 sample-package-4 
    500 sample-package-5 
    500 sample-package-6 
    500 sample-package-7 
    500 sample-package-8 
    500 sample-package-9 
    500 sample-package-10 
    500 sample-package-11 
    500 sample-package-12 
    119 sample-package-13 
