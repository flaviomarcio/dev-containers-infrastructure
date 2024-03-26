#ref 
#   https://hub.docker.com/r/dockette/redoc
FROM dockette/redoc:latest
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}
RUN apt update;
RUN apt install -y tzdata;