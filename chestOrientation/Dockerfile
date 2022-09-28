FROM python:3.9-slim-buster

# depencies for cv2
RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6  -y


# Requirements
COPY ./requirements.txt  .

# Install requirements
RUN pip install -r requirements.txt

# Algorithm
RUN mkdir /app
WORKDIR /app
COPY ./inference.py /app
COPY ./classifier_functions.py /app
COPY ./model.h5  /app
COPY ./run /app

RUN mkdir -p /flywheel/v0/input /flywheel/v0/output

CMD ["/app/run"]

