FROM pyushkevich/itksnap

ENV FLYWHEEL /flywheel/v0
ENV FLYWHEEL_INPUT /flywheel/v0/input
ENV FLYWHEEL_OUTPUT /flywheel/v0/output

WORKDIR ${FLYWHEEL}

RUN mkdir -p ${FLYWHEEL_INPUT}
RUN mkdir -p ${FLYWHEEL_OUTPUT}

RUN apt update

RUN apt install -y git unzip wget imagemagick pandoc libxml2-dev libssl-dev libcurl4-openssl-dev texlive-latex-base bc  texlive-fonts-extra texlive-fonts-recommended autoconf libtool libssh2-1-dev

RUN apt install -y r-base r-base-dev 

COPY Rprofile.site /etc/R/
RUN R -e "install.packages('devtools'); require('devtools'); install_version('cowplot', version = '0.9.3', repos = 'https://ftp.osuosl.org/pub/cran/');"
RUN for i in  rmarkdown xml2 rvest latex2exp kableExtra ggplot2 ggthemes wesanderson extrafont fontcm gridExtra ggpubr tinytex; do R --quiet -e "install.packages('$i')"; done

RUN apt install -y python3 python3-pip jq 
RUN pip3 install flywheel-sdk~=12.2.1 pytz tzlocal
RUN pip3 install requests
RUN pip3 install globre

RUN git clone https://github.com/doloopwhile/pyjq.git /usr/local/pyjq; cd /usr/local/pyjq; python3 /usr/local/pyjq/setup.py install
RUN git clone https://github.com/brainsciencecenter/flywheel.git /usr/local/flywheel

COPY ADNI_metadata_for_R.csv clinical_report.Rmd run run_pipeline.sh make_report.sh trim_neck.sh ${FLYWHEEL}/

RUN touch /tmp/$(date +%F-%T)

# Run the run.sh script on entry.
#ENTRYPOINT ["/flywheel/v0/run"]
