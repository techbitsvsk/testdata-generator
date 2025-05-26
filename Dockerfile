# Use Red Hat Universal Base Image 8
FROM registry.access.redhat.com/ubi8/ubi:latest

LABEL maintainer="sravan.vadaga@barclays.com"
LABEL description="Docker image with TPC-DS tools (dsdgen, dsqgen) compiled on UBI 8."

# --- Environment Variables ---
# Set the TPC-DS version you are using (adjust if necessary)
ENV TPC_DS_VERSION=3.2.0 
ENV TPC_DS_HOME=/opt/tpcds
ENV TPC_DS_TOOLS_DIR=${TPC_DS_HOME}/tools

# - dos2unix: To handle potential line ending issues in TPC-DS source files
# - java-11-openjdk-devel: If you plan to use any Java components or run Spark later (optional for dsdgen itself)
RUN dnf -y update && \
    dnf -y install \
        gcc \
        gcc-c++ \
        make \
        patch \
        git \
        dos2unix \
        java-11-openjdk-devel \
    && dnf clean all

# --- Prepare for TPC-DS ---
# Create the directory for TPC-DS
RUN mkdir -p ${TPC_DS_HOME}/tools
WORKDIR ${TPC_DS_HOME}

# --- Add TPC-DS Toolkit ---
# IMPORTANT: Download the TPC-DS toolkit (e.g., v3.2.0.zip) from the TPC website
COPY ./TPC-DS.3.2.0/tools/ ${TPC_DS_HOME}/tools/

# --- Compile TPC-DS Tools ---
WORKDIR ${TPC_DS_TOOLS_DIR}

# Apply dos2unix to source files just in case.
RUN find . -type f \( -name "*.c" -o -name "*.h" -o -name "*.y" -o -name "*.l" -o -name "Makefile*" \) -exec dos2unix {} \;

# Compile the tools.
# Common target is just 'make'. Some versions might have 'make OS=LINUX'
# Or you might need to copy a makefile.suite for your OS (e.g., cp makefile.suite makefile)
# The default makefile often includes targets for dsdgen and dsqgen.
#RUN make -f Makefile.suite OS=LINUX

# --- Setup Environment for TPC-DS Tools ---
ENV PATH="${TPC_DS_TOOLS_DIR}:${PATH}"

# Create a default directory for data generation output
ENV TPCDS_DATA_DIR=/data/tpcds
RUN mkdir -p ${TPCDS_DATA_DIR}

# --- Entrypoint/CMD ---
# You can set an entrypoint to simplify running dsdgen or dsqgen.
# This example will just output help if no command is given.
# To generate data, you would run:
# docker run -v /your/host/output/path:${TPCDS_DATA_DIR} tpcds-ubi8 dsdgen -SCALE_FACTOR 1 -DIR ${TPCDS_DATA_DIR}
# (Assuming you named the image 'tpcds-ubi8')

WORKDIR ${TPC_DS_TOOLS_DIR}
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["echo 'TPC-DS Tools (dsdgen, dsqgen) are compiled in ${TPC_DS_TOOLS_DIR}'; echo 'To generate data: dsdgen -SCALE_FACTOR <SF> -DIR ${TPCDS_DATA_DIR}'; echo 'Example: docker run -v /mydata:/data/tpcds <imagename> \"dsdgen -SCALE_FACTOR 1 -DIR /data/tpcds\"'"]

# Expose a volume for the generated data (optional, but good practice)
VOLUME ${TPCDS_DATA_DIR}