FROM jenkins/jenkins:lts-jdk11
LABEL maintainer "services <services@services.com>"

ENV TZ=America/Sao_Paulo
RUN apt update;
RUN apt install -y tzdata;