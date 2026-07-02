# flywheel Apptainer container

## Overview

Uses:

-   Ubuntu 22.04 (Jammy)
-   Ubuntu-provided Python 3.10.12 instead of Anaconda
-   Latest [Flywheel CLI](https://flywheel-io.gitlab.io/tools/app/cli/0.34/flyw/) installed 
    using [https://storage.googleapis.com/flywheel-dist/fw-cli/stable/install.sh](https://storage.googleapis.com/flywheel-dist/fw-cli/stable/install.sh)

## Build instructions

``` bash
apptainer build flywheel.sif flywheel.def
```

Or use the provided `build_flywheel.sh` script with
appropriate modifications to submit to Slurm to build.
