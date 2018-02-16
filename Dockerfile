FROM debian:9 

LABEL authors="remi-andre.olsen@scilifelab.se" \
    description="Docker image containing all requirements for NGI-NeutronStar pipeline"

# Install container wide requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    perl \
    build-essential \
    gcc \
    cmake \
    ca-certificates \
    python \
    python-dev \
    bamtools \
    libbamtools-dev \
    libpython-stdlib \
    libjsoncpp1 \
    libboost-iostreams-dev \
    libsqlite3-dev \
    libboost-graph-dev \
    liblpsolve55-dev \
    zlib1g-dev \
    git \
    && rm -rf /var/lib/apt/lists/*  && apt-get clean

# Install pip
RUN wget -O /opt/get-pip.py https://bootstrap.pypa.io/get-pip.py \
    && python /opt/get-pip.py \
    && rm -rf /opt/get-pip.py 


# Install BUSCO v3
# Usage notes:
#   docker run -it -v /your_mnt/:/your_mnt/ remiolsen/ngi-neutronstar cp -r /root/augustus/config $PWD/augustus_config 
#   docker run -it -v /your_mnt/:/your_mnt/ remiolsen/ngi-neutronstar cp -r /root/busco/config/config.ini.default $PWD/busco_config/config.ini
#   docker run -v /your_mnt/:/your_mnt/ remiolsen/ngi-neutronstar /bin/bash -c "export BUSCO_CONFIG_FILE=$PWD/busco_config/config.ini; export AUGUSTUS_CONFIG_PATH=$PWD/augustus_config; BUSCO.py --in ..."

# install augustus
RUN cd /root && wget -O - http://bioinf.uni-greifswald.de/augustus/binaries/augustus.current.tar.gz | tar zx && \
 cd augustus/ && make && make install
RUN cp -r /root/augustus/scripts/* /usr/bin/
# install hmmer
RUN cd  && wget -O - http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz | tar zx && \
 cd hmmer-3.1b2-linux-intel-x86_64/ && ./configure && make && make install
# install ncbi blast
RUN cd /root && wget -O - https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.7.1+-x64-linux.tar.gz | tar zx  && \
 cp ncbi-blast*/bin/* /usr/bin/
# install busco
RUN cd /root && git clone http://gitlab.com/ezlab/busco && cd busco && python setup.py install && \ 
    cp scripts/*.py /usr/bin && ln -s /usr/bin/run_BUSCO.py /usr/bin/BUSCO.py && mkdir /usr/config

# Install Quast
RUN pip install quast

# Install MultiQC
RUN pip install multiqc

# Download and install Supernova (Note! this link will expire)
RUN cd /opt && \
    wget -O - supernova-2.0.0.tar.gz "http://cf.10xgenomics.com/releases/assembly/supernova-2.0.0.tar.gz?Expires=1518839324&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cDovL2NmLjEweGdlbm9taWNzLmNvbS9yZWxlYXNlcy9hc3NlbWJseS9zdXBlcm5vdmEtMi4wLjAudGFyLmd6IiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTE4ODM5MzI0fX19XX0_&Signature=HSRudLVmXMJG~S9TAOjrfEqwFo2AUz8Rw4aHhHyxHboxb26ho-ydpn-kiAef7FZTEYAJsBVuL2tBkx8R6BGnw6MLt1Y-C43On9J45vGLuox5mHUu8qNj5HN0CE7ijvZlRVOrETJgpscg44uf1-fd~-gjigO7XyeJOH6MCimRCQwVXJa3TVU2LSj0IGVGZEHJPARfXE6SI~Phaar2CUOTcKOT2Gn1DjyIWTKhShWMLHn79bwVAzrJvgCDVxj4zt3vvKsjKTz2Z4eGK-QKS0TcwZE9KLd1sz~W-zJQSadLRltmNJT3YcNTW11J4A3YC~PMoW~mnFP5rzicIhscBExLog__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" | \
    tar zx
ENV PATH="/opt/supernova-2.0.0:$PATH"
