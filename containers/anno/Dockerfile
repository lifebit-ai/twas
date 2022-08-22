FROM ubuntu:18.04

LABEL name = "quay.io/lifebitai/anno:1.0.1" \
      version="1.0.0" \
      description="Dockerfile for TabAnno (for annotation of GWAS summary statistics) " \
      author="eva@lifebit.ai" 

RUN apt-get update && \
    apt-get install -y \
              build-essential \
              bash \
              git \
              autoconf \
              zlib1g-dev \
              libbz2-dev \
              liblzma-dev \
              libcurl4-gnutls-dev \
              libssl-dev \
              libgsl0-dev \
              libperl-dev \
              procps \
              curl \
              tabix \
              jq


RUN git clone https://github.com/zhanxw/anno.git && cd anno/ && make release
RUN chmod +x /anno/anno
ENV export PATH="$PATH:anno/anno"

ENTRYPOINT []
