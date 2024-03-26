#ref 
#   https://hub.docker.com/_/sonarqube
#FROM sonarqube:10.3.0-community
#FROM sonarqube:lts-community
FROM bitnami/sonarqube:latest
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}
# RUN apt update;
# RUN apt install -y tzdata;