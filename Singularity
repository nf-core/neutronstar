From:nfcore/base
Bootstrap:docker

%labels
    DESCRIPTION Singularity image containing all requirements for nf-core/neutronstar pipeline
    VERSION 1.0dev

%environment
    PATH=/opt/conda/envs/nf-core-neutronstar-1.0dev/bin:$PATH
    export PATH

%files
    environment.yml /

%post
    /opt/conda/bin/conda env create -f /environment.yml
    apt-get install -y --no-install-recommends g++ make
    /opt/conda/bin/pip install quast
    /opt/conda/bin/conda clean -a
