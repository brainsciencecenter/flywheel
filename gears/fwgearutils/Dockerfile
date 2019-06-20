FROM pyushkevich/itksnap

ENV FLYWHEEL /flywheel/v0
ENV FLYWHEEL_INPUT /flywheel/v0/input
ENV FLYWHEEL_OUTPUT /flywheel/v0/output
ENV PYTHONPATH /usr/local/src/flywheel

WORKDIR ${FLYWHEEL}

RUN mkdir -p ${FLYWHEEL_INPUT}
RUN mkdir -p ${FLYWHEEL_OUTPUT}

RUN apt update

RUN apt install -y unzip wget libxml2-dev libssl-dev libcurl4-openssl-dev git

RUN apt install -y python3 python3-pip jq dh-autoreconf
RUN pip3 install flywheel-sdk~=8.0.0 pytz pyjq
RUN pip3 install requests

RUN mkdir -p /usr/local/src/flywheel/gears/fwgearutils
COPY . /usr/local/src/flywheel/gears/fwgearutils
COPY . /usr/local/bin/

# Run the run.sh script on entry.
#ENTRYPOINT ["/flywheel/v0/run"]
