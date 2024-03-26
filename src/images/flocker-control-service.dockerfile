#ref 
#   https://hub.docker.com/r/clusterhq/flocker-control-service
#   https://flocker.readthedocs.io/en/latest/flocker-standalone/manual-install.html
FROM clusterhq/flocker-control-service
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"