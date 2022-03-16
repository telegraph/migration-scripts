# Configure the following variables
> Configure USERNAME,PASSWORD and HOST
> Configure SOURCE_USERNAME,SOURCE_PASSWORD and SOURCE_HOST

# List of files

# Backup A2 packages
# backup-a2-package.sh : 
> Backup a2 pages from author and downloads package to the output folder

# backup-a2-package-p1.sh
> Backup a2 pages from publisher and downloads package to the output folder

# Rollback packages under rollback directory
# rollback-a2-package.sh
> Rollback the package in author
# rollback-a2-package-p1.sh
> Rollback the package in publisher

# Upload migrated content 
# upload-package-remote.sh
> Downloads the package from Source and installs in Destination author server
# upload-package-remote-p1.sh
> Downloads the package from Source and installs in Destination publisher server
# upload-package-local-p4.sh
> Upload package to server from local system folder