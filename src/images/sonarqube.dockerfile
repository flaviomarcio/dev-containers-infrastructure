#ref 
#   https://hub.docker.com/_/sonarqube
FROM sonarqube:community
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}