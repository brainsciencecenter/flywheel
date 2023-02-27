# nvidia/cuda:11.0.3-base. Specify hash:
FROM nvidia/cuda@sha256:7258839ddbf814d0d6da6c730293bd4ba7b8d1455da84948bb7e4f10111a8b91

LABEL maintainer="support@flywheel.io"

ENV FLYWHEEL="/flywheel/v0"
WORKDIR ${FLYWHEEL}

CMD apt update
CMD apt install -y kmod wget 


COPY run ${FLYWHEEL}
CMD chmod 755 ${FLYWHEEL}/run



