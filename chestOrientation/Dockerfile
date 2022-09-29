FROM python:3.9-slim-buster

ENV FLYWHEEL=/flywheel/v0
WORKDIR ${FLYWHEEL}

# depencies for cv2
RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6  -y
RUN python3 -m pip install --upgrade pip

# Requirements
COPY ./requirements.txt ${FLYWHEEL}/

# Install requirements
RUN pip install -r ${FLYWHEEL}/requirements.txt

COPY inference.py classifier_functions.py model.h5 run ${FLYWHEEL}/

RUN [ -d ${FLYWHEEL}/output ] || mkdir -p ${FLYWHEEL}/output
RUN chmod +x ${FLYWHEEL}/run
ENTRYPOINT ["./run"]

