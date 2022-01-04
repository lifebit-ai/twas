################## BASE IMAGE ######################

FROM ubuntu@sha256:cc4755a9f2f76ca73055da11f1bdc01d65ce79202a68b041c67c32770c71954b
# ubuntu:xenial-20200706  amd64

################## METADATA ######################
LABEL software="bcftools" \
      version="1.10" \
      software.version="1.10.2-105-g7cd83b7" \
      about.home="https://github.com/samtools/bcftools" \
      maintainer="Vladyslav Dembrovskyi <vlad@lifebit.ai>"/

################## INSTALLATION ######################
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
#RUN conda env update -n ${ENV_NAME} -f environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
#ENV PATH /opt/conda/envs/${ENV_NAME}/bin:$PATH

# Dump the details of the installed packages to a file for posterity
#RUN conda env export --name ${ENV_NAME} > ${ENV_NAME}_exported.yml

# Initialise bash for conda
#RUN conda init bash

RUN git clone https://github.com/corbinq/GAMBIT.git
RUN chmod +x GAMBIT/bin/GAMBIT
ENV PATH="$PATH:GAMBIT/bin/"
# Copy additional scripts
## bin/report/ files will be flatly copied into bin/ (no report folder)
RUN mkdir /opt/bin/
COPY bin/* /opt/bin/
RUN chmod +x /opt/bin/*
#ENV PATH="$PATH:/opt/bin/"

ENTRYPOINT ["bash"]
