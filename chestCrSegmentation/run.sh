#!/usr/bin/env bash 

IMAGE=chest-x-ray-segmentation:0.1.11

# Command:
docker run --rm \
        --entrypoint='/bin/bash' -it\
	-e PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\
	-e NVARCH=x86_64\
	-e LD_LIBRARY_PATH=/usr/local/cuda-11.0/targets/x86_64-linux/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64\
	-e LANG=C.UTF-8\
        --gpus all \
	-e FLYWHEEL=/flywheel/v0\
	-v /data/holder/Despina/flywheel/chestCrSegmentation/config.json:/flywheel/v0/config.json\
	-v /data/holder/Despina/flywheel/chestCrSegmentation/manifest.json:/flywheel/v0/manifest.json\
        -v /data/holder/Despina/data/input:/flywheel/v0/input \
        -v /data/holder/Despina/data/output:/flywheel/v0/output \
	$IMAGE

#        --entrypoint='/flywheel/v0/run'\
#        --entrypoint='/bin/bash' -it\
