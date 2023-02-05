FROM python:3.8-buster as base

ENV FLYWHEEL=/flywheel/v0
WORKDIR ${FLYWHEEL}

RUN apt update
RUN apt full-upgrade -y

RUN apt install gfortran-8 -y
RUN apt-get install -y libatlas-base-dev gfortran
RUN apt-get install python-dev -y

RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install numpy 

COPY requirements.txt ${FLYWHEEL}
RUN pip install -r requirements.txt

COPY lungmask ${FLYWHEEL}/lungmask
COPY model ${FLYWHEEL}/model
COPY segmentation.py ${FLYWHEEL}
COPY run ${FLYWHEEL}/

RUN cat model/unet_r231_v0_0.pkl.* > model/unet_r231_v0_0.pkl

RUN chmod +x run
ENTRYPOINT ["./run"]
