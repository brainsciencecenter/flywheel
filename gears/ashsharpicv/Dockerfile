FROM pyushkevich/itksnap

ENV FLYWHEEL /flywheel/v0
ENV FLYWHEEL_INPUT /flywheel/v0/input
ENV FLYWHEEL_OUTPUT /flywheel/v0/output

RUN mkdir -p ${FLYWHEEL_INPUT}
RUN mkdir -p ${FLYWHEEL_OUTPUT}

RUN pip install flywheel-sdk
RUN pip install requests

RUN apt install -y unzip wget imagemagick pandoc libxml2-dev libssl-dev libcurl4-openssl-dev texlive-latex-base bc  texlive-fonts-extra texlive-fonts-recommended jq 

RUN apt install -y r-base r-base-dev 
COPY Rprofile.site /etc/R/
RUN for i in  rmarkdown xml2 rvest latex2exp kableExtra ggplot2 ggthemes wesanderson extrafont fontcm gridExtra ggpubr tinytex; do R --quiet -e "install.packages('$i')"; done

RUN mkdir /root/.alfabis
COPY server cookie_305dad76e49b37979abd9da422169312.jar /root/.alfabis/

COPY ADNI_metadata_for_R.csv clinical_report.Rmd run run_pipeline.sh make_report.sh trim_neck.sh ${FLYWHEEL}/
RUN echo 35.184.111.29 dss.itksnap.org >> /etc/hosts

# Run the run.sh script on entry.
#ENTRYPOINT ["/flywheel/v0/run"]
