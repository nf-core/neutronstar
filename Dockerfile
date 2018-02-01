FROM debian:9 

LABEL authors="remi-andre.olsen@scilifelab.se" \
    description="Docker image containing all requirements for NGI-NeutronStar pipeline"

# Install container wide requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    rsync \
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
    cp scripts/*.py /usr/bin && ln -s /usr/bin/run_BUSCO.py /usr/bin/BUSCO.py

# Install pip and Quast
RUN pip install quast

# Install MultiQC
RUN pip install multiqc

# Download and install Supernova (Note! this link will expire)
RUN cd /opt && \
    wget -O - supernova-2.0.0.tar.gz "http://cf.10xgenomics.com/releases/assembly/supernova-2.0.0.tar.gz?Expires=1517526231&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cDovL2NmLjEweGdlbm9taWNzLmNvbS9yZWxlYXNlcy9hc3NlbWJseS9zdXBlcm5vdmEtMi4wLjAudGFyLmd6IiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTE3NTI2MjMxfX19XX0_&Signature=YPI-AtARAhGsscWsbj5n8HJunYWTxyC1C9wo4YdwESDp97VfkSAqkmUYPnJQi0lnpTXzyFwc08p~LNb-RUCmD5T5gbQHJiLT8-x5LOCCC-s~NVMiLHA0HEBfSkKVL1lUwePIZ~TSWomgjZRUpLYVmUAumchBu4O2EC0s4WM0BBfwm~HEqrVtAxyENcWBEgeAzcnkgcK8cxVJPJ0DOLcRIX862AyxOxHGYYw2sY9afX4tlFOgNnHpVgiSbz7g55Bp7VoUDOy-p7x1qla23BEp1kQcl2yYVoMrnvCo-tUzHD1j9mqucAAaCWSFsMGjooqBRFE1jKFdh6SxWNUBza4A3A__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" | \
    tar zx
ENV PATH="/opt/supernova-2.0.0:$PATH"

# Create mount points for UPPMAX folders
RUN mkdir /pica /lupus /crex1 /crex2 /proj /scratch /sw /Users


