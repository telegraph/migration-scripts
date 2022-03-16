# create package

This is a simple bash script tool who reads the configured input file (containing a list of paths)
and in base of the number of chunks preconfigured create a package with these filters build it and download it in output folder

> Open the script "create-package.sh" and setup the configuration section: (update USERNAME,PASSWORD)
  
> How to run it:

    bash create-package.sh
> The script also generate in output folder the file info.log with the following information:  
> cat info.log | cut -d ":" -f 1 | uniq -c
    
    500 sample-package-1 
    500 sample-package-2 
# update package
This is a simple bash script tool who reads the configured input file (containing a list of paths)
and in base of the number of chunks preconfigured create a package with these filters upload package and installs in the server

# List of sh files
> Configure USERNAME, PASSWORD

# create-package.sh 
> backup a2 pages from author and downloads package to the output folder
# create-package-p1.sh
> backup a2 pages from publisher and downloads package to the output folder
# upload-package.sh
> upload the package to author and installs the package
# upload-package-p1.sh
> upload the package to publisher and installs the package