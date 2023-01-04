FROM fedora:36
USER root
RUN dnf -qy install aria2 && dnf clean all
ADD download ./download
RUN mkdir -p /download/data && chmod 777 /download/data
VOLUME /download/data
WORKDIR /download
USER 1001
