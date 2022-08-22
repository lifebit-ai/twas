FROM ubuntu@sha256:cc4755a9f2f76ca73055da11f1bdc01d65ce79202a68b041c67c32770c71954b
# ubuntu:xenial-20200706  amd64

LABEL name = "quay.io/lifebitai/ptwas" \
      version="1.0.0_089aa00" \
      description="Dockerfile for PTWAS (GAMBIT tool)" \
      author="eva@lifebit.ai" 

USER root

RUN apt-get update && \
    apt-get install -y \
              build-essential \
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


RUN git clone https://github.com/corbinq/GAMBIT.git
RUN chmod +x GAMBIT/bin/GAMBIT
ENV PATH="$PATH:GAMBIT/bin/"


ENTRYPOINT []
