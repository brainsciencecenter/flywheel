#!/usr/bin/env bash 

IMAGE=lung-ct-segmentation:0.1.0

# Command:
docker run --rm -it --entrypoint='bash'\
	-e PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\
	-e LANG=C.UTF-8\
	-e GPG_KEY=E3FF2839C048B25C084DEBE9B26995E310250568\
	-e PYTHON_VERSION=3.8.14\
	-e PYTHON_PIP_VERSION=22.0.4\
	-e PYTHON_SETUPTOOLS_VERSION=57.5.0\
	-e PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/5eaac1050023df1f5c98b173b248c260023f2278/public/get-pip.py\
	-e PYTHON_GET_PIP_SHA256=5aefe6ade911d997af080b315ebcb7f882212d070465df544e1175ac2be519b4\
	-e FLYWHEEL=/flywheel/v0\
	-v /home/holder/Work/Despina/flywheel/lungCtSegmentation/config.json:/flywheel/v0/config.json\
	-v /home/holder/Work/Despina/flywheel/lungCtSegmentation/manifest.json:/flywheel/v0/manifest.json\
	-v /home/holder/Work/Despina/lungCtSegmentation/input:/flywheel/v0/input\
	$IMAGE
