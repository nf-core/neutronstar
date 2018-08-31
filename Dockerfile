FROM nfcore/base
LABEL description="Docker image containing all requirements for nf-core/neutronstar pipeline"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
RUN apt-get install -y --no-install-recommends build-essential && pip install --upgrade pip && pip install quast
ENV PATH /opt/conda/envs/nf-core-neutronstar-1.0dev/bin:$PATH
