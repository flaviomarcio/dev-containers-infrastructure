FROM ${STACK_SERVICE_IMAGE_INFLUXDB}
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}