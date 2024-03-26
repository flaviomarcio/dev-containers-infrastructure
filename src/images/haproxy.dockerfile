FROM haproxy:latest
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

# RUN mkdir -p /cert
# RUN mkdir -p /usr/local/etc/haproxy
# ADD ${STACK_INFRA_CONF_DIR}/haproxy/cert/haproxy.pem /cert/haproxy.pem
# ADD ${STACK_INFRA_CONF_DIR}/haproxy/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg