#ref
#   https://hub.docker.com/r/camunda/camunda-bpm-platform
#   https://github.com/camunda/docker-camunda-bpm-platform
#   https://docs.camunda.io/docs/self-managed/platform-deployment/docker/
#FROM camunda/camunda-bpm-platform:run
FROM camunda/camunda-bpm-platform:latest
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}