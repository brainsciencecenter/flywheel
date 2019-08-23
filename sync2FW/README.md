# XNAT 2 Flywheel

Script pushs XNAT projects to flywheel.

Takes XNAT project, or project/subject and pushes to flywheel. 
Needs to keep a log of what it pushed and where so it doesn't need to redo things (can be forced to redo it)
and give the progress to the user.
Also so it restart an interrupted transfer

## XNAT Directory Structure

On tesla:

XNATBaseDir=/data/XNAT/archive

Under archive are a list of projects eg: NACC-SA
XNATProject=/data/XNAT/archive/NACC-SA

Under the project are subject directories


/data/XNAT/archive/NACC-SC/arc001/107970_01_FlorbetabenPET_20180607/SCANS/201/DICOM/

fw import dicom [flags] [folder] [group_id] [project_label]
positional arguments:	 
folder 	The path to the folder to import
group_id  	The id of the group
project_label       	The label of the project
optional arguments:	 
 -h, --help	show this help message and exit
--de-identify	

De-identify DICOM files, e-files and p-files prior to upload
--jobs JOBS, -j JOBS	

The number of concurrent jobs to run (e.g. compression jobs)
--concurrent-uploads CONCURRENT_UPLOADS	The maximum number of concurrent uploads
--compression-level {-1,0,1,2,3,4,5,6,7,8}	

The compression level to use for packfiles. -1 for default, 0 for store
--symlinks   	follow symbolic links that resolve to directories
