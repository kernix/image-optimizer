from debian:stretch-slim

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    imagemagick \
    libperl-dev \
    pngquant \
    libjpeg62-turbo-dev \
    libjpeg-progs

# Create work directory
ARG WORK_DIR=/var/www
RUN mkdir -p $WORK_DIR

# Add scripts
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/image-optimizer.sh /image-optimizer.sh
RUN chmod +x entrypoint.sh image-optimizer.sh

ENV WORK_DIR $WORK_DIR

WORKDIR $WORK_DIR

ENTRYPOINT ["/entrypoint.sh"]