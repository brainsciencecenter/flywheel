FROM pyushkevich/itksnap

ENV FLYWHEEL /flywheel/v0
ENV FLYWHEEL_INPUT /flywheel/v0/input
ENV FLYWHEEL_OUTPUT /flywheel/v0/output

WORKDIR ${FLYWHEEL}

RUN mkdir -p ${FLYWHEEL_INPUT}
RUN mkdir -p ${FLYWHEEL_OUTPUT}

RUN apt update

RUN apt install -y unzip wget libxml2-dev libssl-dev libcurl4-openssl-dev 

RUN apt install -y python3 python3-pip jq 
RUN pip3 install flywheel-sdk~=8.0.0
RUN pip3 install requests
COPY fwgearutils/ /usr/local/bin/ 

COPY run run_pipeline.sh ${FLYWHEEL}/

# Run the run.sh script on entry.
#ENTRYPOINT ["/flywheel/v0/run"]
