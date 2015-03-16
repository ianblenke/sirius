FROM ubuntu:12.04

RUN apt-get update

# OpenJDK 7
RUN DEBIAN_FRONTEND=noninteractive apt-get install -V -y default-jdk openjdk-7-jdk
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

# Oracle's JVM
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python-software-properties && \
#    add-apt-repository ppa:webupd8team/java && \
#    apt-get update
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer
#ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ant wget unzip

COPY . /sirius

WORKDIR /sirius

# Stop apt from being interactive
RUN mkdir -p /etc/apt/apt.conf.d; \
    ( echo 'APT::Get::Assume-Yes "true";'; \
      echo 'APT::Get::Show-Upgraded "true";'; \
      echo 'APT::Quiet "true";'; \
      echo 'DPkg::Options {"--force-confdef";"--force-confmiss";"--force-confold"};'; \
      echo 'DPkg::Pre-Install-Pkgs {"/usr/sbin/dpkg-preconfigure --apt";};' ) \
    > /etc/apt/apt.conf.d/local

RUN cd sirius-application; \
    for script in get-* ; do \
      export PATH=$PATH:/sirius/sirius-application/speech-recognition/kaldi/scripts ; \
      DEBIAN_FRONTEND=noninteractive bash -x ./$script ; \
    done

RUN bash -x ./sirius-application/compile-sirius-servers.sh

RUN bash -x ./sirius-web/get-web-deps.sh

