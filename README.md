# Tools to Interact with Flywheel
## Installation
Anaconda is currently the simpilest way I know to get a python version that will build pyjq.
You also need CC/GCC version 12.

### Anaconda Installation
Need gcc-12, g++-12, and csvkit

```
export FLYWHEELDIR=~/flywheel
git clone https://github.com/brainsciencecenter/flywheel.git $FLYHWHEELDIR

CONTREPO=https://repo.continuum.io/archive
ANACONDAURL=$(wget -q -O - $CONTREPO index.html | grep "Anaconda3-" | grep "Linux" | grep "86_64" | head -n 1 | cut -d \" -f 2)				        
[ -e ~/Downloads ] || mkdir ~/Downloads
wget -O ~/Downloads/anaconda.sh "${CONTREPO}/${ANACONDAURL}"
bash ~/Downloads/anaconda.sh -b -p $HOME/anaconda3

~/anaconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
~/anaconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
~/anaconda3/bin/conda env create -f ${FLYWHEELDIR}/etc/FlywheelEnv.yaml
~/anaconda3/bin/conda init

__conda_setup=$(~/anaconda3/bin/conda 'shell.bash' 'hook' 2> /dev/null)
eval "$__conda_setup"
conda activate FlywheelEnv
unset __conda_setup

CC=gcc-12 CXX=g++-12 CFLAGS="-Wno-error=incompatible-pointer-types -Wno-incompatible-pointer-types" pip install --no-cache-dir --no-binary :all: pyjq

[ -e ~/.config/flywheel ] || mkdir -p ~/.config/flywheel
```

Copy in your ~/.config/flywheel/user.json file to ~/.config/flywheel/user.json

#### Update your environmet variables

```
export PATH=$PATH:$FLYWHEELDIR/bin
export PYTHONPATH=$FLYWHEELDIR/lib
```

#### Test Installation

```
fwget -1 -d all | jq -r '.[].label'
```
should get you a list of the devices and without errors

## Useful things

### fwget

Takes flywheel paths, and fwids and returns the json representation of the object.
Can also be used to download objects/files etc.

### fwsearch

### fwview

### fwDownloadFiles
Download gear output files from a project

```
fwDownloadFiles -v -t /tmp -g ashs -c session -d holder/AlohaTesting3
```

Downloads the output files from the most recent ashs runs to /tmp/holder/AlohaTesting3
(there may be conflicts with the temp files - updates for this in the queue)

The -r option is also useful for summarizing the output files.

```
fwDownloadFiles -v -t /tmp -g ashs -c session -r csv holder/AlohaTesting3
```

prints a csv report of the gear's output files.

## Other dependancies


