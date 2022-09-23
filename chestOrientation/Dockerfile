FROM python:3.9-slim-buster

WORKDIR /app/
# new
ADD . /app

# depencies for cv2
RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6  -y


# Requirements
COPY ./requirements.txt  .

# Install requirements
RUN pip install -r requirements.txt

# Algorithm
COPY ./inference.py .
COPY ./classifier_functions.py .
COPY ./model.h5  .


CMD mkdir -p /flywheel/v0/input /flywheel/v0/output

CMD ["python", "inference.py"]
