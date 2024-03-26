#FROM gvenzl/oracle-xe:11
#FROM gvenzl/oracle-xe:latest
#FROM gvenzl/oracle-free
FROM container-registry.oracle.com/database/free:latest
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"