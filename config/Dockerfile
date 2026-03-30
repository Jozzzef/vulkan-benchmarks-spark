FROM fedora:44

RUN dnf -y update && \
    dnf clean all

RUN dnf install -y git vim which gcc python3 python3-pip java-25-openjdk tar gzip && dnf clean all
RUN java --version

# PYSPARK INSTALL
RUN python3 -m pip install pandas pyarrow pyspark

# SPARK INSTALL
ARG SPARK_VERSION=4.1.1
ARG HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
# download to file spark.tgz, unzip to SPARK_HOME location
RUN curl -fSL https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    -o /tmp/spark.tgz && \
    mkdir -p ${SPARK_HOME} && \
    tar -xzf /tmp/spark.tgz --strip-components=1 -C ${SPARK_HOME} && \
    rm -f /tmp/spark.tgz
ENV PATH=${SPARK_HOME}/bin:${PATH} \
    PYTHONPATH=${SPARK_HOME}/python:$PYTHONPATH \
    PYSPARK_PYTHON=python3
RUN spark-submit --version

#copy in the executable binaries you wish to use for the testing
RUN mkdir -p /working_directory/binaries
WORKDIR /working_directory
COPY ./binaries ./binaries
# this is the directory your log files must be placed in: ../logs from the binary's point of view
RUN mkdir ./logs
# copy the binaries to run but do not run untill the actual deployments from pyspark are made
COPY ./executor_run_binaries.sh ./executor_run_binaries.sh
