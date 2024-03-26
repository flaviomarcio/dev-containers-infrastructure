#ref 
#   https://hub.docker.com/r/kong/kong-gateway
FROM kong/kong-gateway
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}