# hash:sha256:df89bf20b512602710bd86c1879d1f7bdd142286c288ddd2337380da2246cda5
FROM registry.apps.codeocean.com/codeocean/mambaforge3:22.11.1-4-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

ARG GIT_ASKPASS
ARG GIT_ACCESS_TOKEN
COPY git-askpass /

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates=20211016ubuntu0.22.04.1 \
        git=1:2.34.1-1ubuntu1.8 \
    && rm -rf /var/lib/apt/lists/*

RUN conda install -y --channel=bioconda --channel=conda-forge \
        seqkit==2.4.0 \
        star==2.7.10b \
    && conda clean -ya

RUN pip install -U --no-cache-dir \
    code-ocean-aux-tools==1.0.9
