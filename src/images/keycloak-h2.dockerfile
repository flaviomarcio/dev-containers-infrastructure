FROM quay.io/keycloak/keycloak:latest
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}

RUN /opt/keycloak/bin/kc.sh build