FROM debian:bullseye
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}
#RUN echo 'deb http://deb.debian.org/debian bullseye-backports main' > /etc/apt/sources.list.d/backports.list

RUN apt update;
RUN apt install -y tzdata mc git sudo;
RUN apt install -y sudo telnet curl iputils-ping tar zip mc htop iproute2 wget bash-completion postgresql-client postgresql-common
RUN apt upgrade -y;