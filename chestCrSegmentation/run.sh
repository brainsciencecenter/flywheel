#!/bin/bash

IMAGE=chest-xray-segmentation:0.1.0

# Command:
docker run --rm -it --entrypoint='/bin/bash'\
	-e PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\
	-e FLYWHEEL=/flywheel/v0\
	-v /home/holder/Work/Despina/flywheel/chestCrSegmentation/config.json:/flywheel/v0/config.json\
	-v /home/holder/Work/Despina/flywheel/chestCrSegmentation/manifest.json:/flywheel/v0/manifest.json\
	-v /home/holder/Work/Despina/chestCrSegmentation/input:/flywheel/v0/input\
	-v /home/holder/Work/Despina/chestCrSegmentation/output:/flywheel/v0/output\
	$IMAGE

