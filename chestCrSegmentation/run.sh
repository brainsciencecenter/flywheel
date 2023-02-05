#!/usr/bin/env bash 

IMAGE=chest-xray-segmentation:0.1.0

# Command:
docker run --rm \
	-it --entrypoint /bin/bash\
	-e PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\
	-e LANG=C.UTF-8\
	-e GPG_KEY=E3FF2839C048B25C084DEBE9B26995E310250568\
	-e PYTHON_VERSION=3.8.16\
	-e PYTHON_PIP_VERSION=22.0.4\
	-e PYTHON_SETUPTOOLS_VERSION=57.5.0\
	-e PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/1a96dc5acd0303c4700e02655aefd3bc68c78958/public/get-pip.py\
	-e PYTHON_GET_PIP_SHA256=d1d09b0f9e745610657a528689ba3ea44a73bd19c60f4c954271b790c71c2653\
	-e FLYWHEEL=/flywheel/v0\
	-v /home/holder/Work/Despina/flywheel/chestCrSegmentation/config.json:/flywheel/v0/config.json\
	-v /home/holder/Work/Despina/flywheel/chestCrSegmentation/manifest.json:/flywheel/v0/manifest.json\
	-v /home/holder/Work/Despina/chestCrSegmentation/input:/flywheel/v0/input\
	-v /home/holder/Work/Despina/chestCrSegmentation/output:/flywheel/v0/output\
	$IMAGE 
