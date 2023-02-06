#!/usr/bin/env bash 

IMAGE=lung-ct-segmentation:0.1.2

# Command:
docker run --rm --entrypoint='./run'\
	-e PATH=/usr/local/flywheel/bin:/flywheel/v0:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\
	-e LANG=C.UTF-8\
	-e GPG_KEY=E3FF2839C048B25C084DEBE9B26995E310250568\
	-e PYTHON_VERSION=3.8.15\
	-e PYTHON_PIP_VERSION=22.0.4\
	-e PYTHON_SETUPTOOLS_VERSION=57.5.0\
	-e PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/6d265be7a6b5bc4e9c5c07646aee0bf0394be03d/public/get-pip.py\
	-e PYTHON_GET_PIP_SHA256=36c6f6214694ef64cc70f4127ac0ccec668408a93825359d998fb31d24968d67\
	-e PYTHONPATH=/flywheel/v0\
	-e FLYWHEEL=/flywheel/v0\
	-v /home/holder/Work/Despina/flywheel/lungCtSegmentation/config.json:/flywheel/v0/config.json\
	-v /home/holder/Work/Despina/flywheel/lungCtSegmentation/manifest.json:/flywheel/v0/manifest.json\
	-v /home/holder/Work/Despina/lungCtSegmentation/input:/flywheel/v0/input\
	-v /home/holder/Work/Despina/lungCtSegmentation/output:/flywheel/v0/output\
	$IMAGE

#export PYTHONPATH=${FLYWHEEL}/networks:/usr/local/pyjq:/usr/local/flywheel/lib


