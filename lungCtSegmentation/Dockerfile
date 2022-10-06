FROM python:3.8-buster as base

ENV FLYWHEEL=/flywheel/v0
WORKDIR ${FLYWHEEL}

COPY run.py requirements.txt ${FLYWHEEL}/

RUN pip install -r requirements.txt

RUN chmod +x run.py
ENTRYPOINT ["./run.py"]