#ref
#   https://hub.docker.com/_/wordpress
FROM wordpress
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}
#RUN apt update;
#RUN apt install -y tzdata;