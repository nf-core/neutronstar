FROM nfcore/base
LABEL description="Docker image containing all requirements for nf-core/neutronstar pipeline"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/nf-core-neutronstar-1.0.0/bin:$PATH
