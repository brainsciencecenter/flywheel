FROM pyushkevich/itksnap

ENV FLYWHEEL /flywheel/v0
ENV FLYWHEEL_INPUT /flywheel/v0/input
ENV FLYWHEEL_OUTPUT /flywheel/v0/output

WORKDIR ${FLYWHEEL}

RUN mkdir -p ${FLYWHEEL_INPUT}
RUN mkdir -p ${FLYWHEEL_OUTPUT}

RUN apt update

RUN apt install -y unzip wget imagemagick pandoc libxml2-dev libssl-dev libcurl4-openssl-dev texlive-latex-base bc  texlive-fonts-extra texlive-fonts-recommended 

RUN apt install -y r-base r-base-dev 

COPY Rprofile.site /etc/R/
RUN for i in  rmarkdown xml2 rvest latex2exp kableExtra ggplot2 ggthemes wesanderson extrafont fontcm gridExtra ggpubr tinytex; do R --quiet -e "install.packages('$i')"; done

RUN apt install -y python3 python3-pip jq 
RUN pip3 install flywheel-sdk~=6.3.0
RUN pip3 install requests
COPY fwgearutils/ /usr/local/bin/ 

COPY ADNI_metadata_for_R.csv clinical_report.Rmd run run_pipeline.sh make_report.sh trim_neck.sh ${FLYWHEEL}/

# Run the run.sh script on entry.
#ENTRYPOINT ["/flywheel/v0/run"]
