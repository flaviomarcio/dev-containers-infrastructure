#ref
# https://hub.docker.com/r/linuxserver/wikijs

FROM linuxserver/wikijs:2.5.301
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}
#RUN apt update;
#RUN apt install -y tzdata;