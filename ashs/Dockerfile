FROM ubuntu

ENV FLYWHEEL /flywheel/v0
ENV FLYWHEEL_INPUT /flywheel/v0/input
ENV FLYWHEEL_OUTPUT /flywheel/v0/output

WORKDIR ${FLYWHEEL}

RUN mkdir -p ${FLYWHEEL_INPUT}
RUN mkdir -p ${FLYWHEEL_OUTPUT}

COPY sources.list.save /etc/apt/sources.list
RUN apt update

RUN DEBIAN_FRONTEND="noninteractive" apt install -y curl git python unzip wget imagemagick pandoc libxml2-dev libssl-dev libcurl4-openssl-dev texlive-latex-base bc  texlive-fonts-extra texlive-fonts-recommended autoconf libtool libssh2-1-dev

RUN apt install -y r-base r-base-dev 

RUN apt install -y python3 python3-pip jq 
RUN pip3 install flywheel-sdk~=14.3.3 pytz tzlocal
RUN pip3 install requests
RUN pip3 install globre

RUN git clone https://github.com/doloopwhile/pyjq.git /usr/local/pyjq; cd /usr/local/pyjq; python3 /usr/local/pyjq/setup.py install
RUN git clone https://github.com/brainsciencecenter/flywheel.git /usr/local/flywheel

COPY run run_pipeline.sh ${FLYWHEEL}/

RUN touch /tmp/$(date +%F-%T)

RUN wget -O /tmp/itksnap.tgz https://sourceforge.net/projects/itk-snap/files/itk-snap/Experimental/itksnap-experimental-master-Linux-gcc64-qt4.tar.gz/download
RUN tar -C /usr/local/bin --strip-components=2 -xf /tmp/itksnap.tgz itksnap-3.8.2-alpha-20200410-Linux-gcc64-qt4/bin
RUN ls -l /usr/local/bin

# Run the run.sh script on entry.
#ENTRYPOINT ["/flywheel/v0/run"]
