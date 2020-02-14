from debian:stretch-slim

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    imagemagick \
    libperl-dev \
    pngquant \
    libjpeg62-turbo-dev \
    libjpeg-progs

# Create container user
RUN useradd --shell /bin/bash -u 1024 -o -c "" -m image-optimizer

# Create work directory
ARG WORK_DIR=/var/www
RUN mkdir -p $WORK_DIR
RUN chown -R image-optimizer $WORK_DIR

# Add scripts
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/image-optimizer.sh /image-optimizer.sh
RUN chmod +x entrypoint.sh image-optimizer.sh

ENV WORK_DIR $WORK_DIR

WORKDIR $WORK_DIR

USER image-optimizer

ENTRYPOINT ["/entrypoint.sh"]