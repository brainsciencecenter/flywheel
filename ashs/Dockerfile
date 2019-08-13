#FROM pyushkevich/itksnap
FROM ashs/fwgearutils

RUN mkdir -p /usr/local/src/flywheel/gears/ashs /flywheel/v0/input/t1 /flywheel/v0/input/t2

COPY fwgearutils/ /usr/local/bin/ 

COPY . /usr/local/src/flywheel/gears/ashs
COPY run run_pipeline.sh /flywheel/v0/
