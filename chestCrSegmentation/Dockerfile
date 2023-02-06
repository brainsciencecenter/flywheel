FROM tensorflow/tensorflow:latest-gpu

ENV FLYWHEEL=/flywheel/v0
WORKDIR ${FLYWHEEL}

RUN apt update
RUN apt full-upgrade -y

RUN apt install python-dev -y

RUN /usr/local/bin/python -m pip install --upgrade pip 

RUN /usr/local/bin/python -m pip install --upgrade pip 

RUN apt install -y ninja-build
RUN apt install -y cuda-nvcc-11-8
RUN apt install -y libcublas-dev-11-8
RUN apt install -y nvidia-utils-515
RUN apt install -y dcmtk dcm2niix
RUN apt install vtk-dicom-tools -y

COPY requirements.txt ${FLYWHEEL}/
RUN pip install -r requirements.txt


RUN ls -l /dev/

COPY cc_attention ${FLYWHEEL}/cc_attention
COPY dataset ${FLYWHEEL}/dataset
COPY libs ${FLYWHEEL}/libs
COPY models ${FLYWHEEL}/models
COPY networks ${FLYWHEEL}/networks
COPY segment_cxr.py ${FLYWHEEL}
COPY utils ${FLYWHEEL}/utils

RUN mkdir -p ${FLYWHEEL}/input ${FLYWHEEL}/output

RUN cat models/XLSor.pth.a? > models/XLSor.pth

#RUN pip install inplace-abn

COPY toNifti ${FLYWHEEL}/
COPY run ${FLYWHEEL}/
RUN chmod +x run

ENTRYPOINT ["./run"]
