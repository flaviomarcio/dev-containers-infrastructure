#ref 
#   https://hub.docker.com/r/pantsel/konga/
FROM pantsel/konga:latest
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}