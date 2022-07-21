FROM ubuntu:20.04

ENV FLYWHEEL /flywheel/v0
ENV FLYWHEEL_INPUT /flywheel/v0/input
ENV FLYWHEEL_OUTPUT /flywheel/v0/output

WORKDIR ${FLYWHEEL}

RUN mkdir -p ${FLYWHEEL_INPUT}
RUN mkdir -p ${FLYWHEEL_OUTPUT}

RUN apt update

RUN DEBIAN_FRONTEND="noninteractive" apt update; apt install -y curl git
RUN DEBIAN_FRONTEND="noninteractive" apt install -y python3 python-is-python3 unzip wget imagemagick pandoc libxml2-dev libssl-dev libcurl4-openssl-dev texlive-latex-base bc 
RUN DEBIAN_FRONTEND="noninteractive" apt install -y texlive-fonts-extra texlive-fonts-recommended autoconf libtool libssh2-1-dev

RUN apt install -y r-base r-base-dev libfontconfig1-dev cmake

COPY Rprofile.site /etc/R/
RUN R -e "install.packages('devtools'); require('devtools'); install_version('cowplot', version = '0.9.3', repos = 'https://ftp.osuosl.org/pub/cran/');"
RUN R -e "install.packages('devtools'); require('devtools'); "
RUN for i in  rmarkdown xml2 rvest latex2exp kableExtra ggplot2 ggthemes wesanderson extrafont fontcm gridExtra ggpubr tinytex; do R --quiet -e "install.packages('$i')"; done

RUN apt install -y python3 python3-pip jq 
RUN pip3 install flywheel-sdk~=16.9.1 pytz tzlocal
RUN pip3 install requests
RUN pip3 install globre

RUN git clone https://github.com/doloopwhile/pyjq.git /usr/local/pyjq; cd /usr/local/pyjq; python3 /usr/local/pyjq/setup.py install
RUN git clone https://github.com/brainsciencecenter/flywheel.git /usr/local/flywheel

COPY ADNI_metadata_for_R.csv clinical_report.Rmd run run_pipeline.sh make_report.sh trim_neck.sh ${FLYWHEEL}/

RUN touch /tmp/$(date +%F-%T)

RUN wget -O /tmp/itksnap.tgz https://sourceforge.net/projects/itk-snap/files/itk-snap/Experimental/itksnap-experimental-master-Linux-gcc64-qt4.tar.gz/download
RUN tar -C /usr/local/bin --strip-components=2 -xf /tmp/itksnap.tgz itksnap-3.8.2-alpha-20200410-Linux-gcc64-qt4/bin
RUN ls -l /usr/local/bin

# Run the run.sh script on entry.
#ENTRYPOINT ["/flywheel/v-1/run"]
