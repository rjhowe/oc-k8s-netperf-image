FROM registry.access.redhat.com/ubi9:latest

COPY appstream.repo /etc/yum.repos.d/centos9-appstream.repo

COPY netperf.diff /tmp/netperf.diff
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && dnf clean all
RUN dnf install -y uperf && dnf clean all

RUN dnf install -y --nodocs make automake --enablerepo=centos9 --allowerasing  && \
    dnf install -y --nodocs gcc git bc lksctp-tools-devel texinfo rsync --enablerepo=*

RUN git clone https://github.com/HewlettPackard/netperf
WORKDIR netperf

RUN git reset --hard 3bc455b23f901dae377ca0a558e1e32aa56b31c4 && \
    git apply /tmp/netperf.diff && \
    ./autogen.sh && \
    ./configure --enable-sctp=yes --enable-demo=yes && \
    make && make install

WORKDIR ../

RUN curl -L https://github.com/esnet/iperf/releases/download/3.16/iperf-3.16.tar.gz | tar xz && \
    cd iperf-3.16 && \
    ./configure; make install && \
    cd .. && \
    rm -rf iperf-3.16


RUN rm -rf netperf && \
    dnf clean all
COPY super-netperf /usr/bin/super-netperf

RUN curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.18/openshift-client-linux.tar.gz | tar xz -C /bin/ && \
    curl -L https://github.com/cloud-bulldozer/k8s-netperf/releases/download/v0.1.27/k8s-netperf_Linux_v0.1.27_x86_64.tar.gz | tar xz -C /bin/


COPY netperf.yml ./
RUN rm afs -rf 
