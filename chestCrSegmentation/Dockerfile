FROM python:3.8-buster as base

ENV FLYWHEEL=/flywheel/v0
WORKDIR ${FLYWHEEL}

RUN apt update
RUN apt full-upgrade -y

RUN apt install vtk-dicom-tools -y

RUN apt install python-dev -y
RUN /usr/local/bin/python -m pip install --upgrade pip

COPY requirements.txt ${FLYWHEEL}/
RUN pip install -r requirements.txt

COPY cc_attention ${FLYWHEEL}/cc_attention
COPY dataset ${FLYWHEEL}/dataset
COPY libs ${FLYWHEEL}/libs
COPY models ${FLYWHEEL}/models
COPY networks ${FLYWHEEL}/networks
COPY segment_cxr.py ${FLYWHEEL}
COPY utils ${FLYWHEEL}/utils

COPY run ${FLYWHEEL}/
RUN chmod +x run

ENTRYPOINT ["./run"]
