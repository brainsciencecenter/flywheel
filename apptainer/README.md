# flywheel Apptainer container

## Overview

Uses:

-   Ubuntu 22.04 (Jammy)
-   Ubuntu-provided Python 3.10.12 instead of Anaconda

## Build instructions

``` bash
apptainer build flywheel.sif flywheel.def
```

Or use the provided `build_flywheel.sh` script with
appropriate modifications to submit to Slurm to build.
