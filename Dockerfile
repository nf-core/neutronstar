FROM nfcore/base
LABEL description="Docker image containing all requirements for nf-core/neutronstar pipeline"

COPY environment.yml /
RUN apt-get install -y --no-install-recommends g++ make && \
conda env create -f /environment.yml && /opt/conda/bin/pip install quast && conda clean -a
ENV PATH /opt/conda/envs/nf-core-neutronstar-1.0dev/bin:$PATH
