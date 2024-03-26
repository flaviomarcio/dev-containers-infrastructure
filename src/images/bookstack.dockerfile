#FROM linuxserver/bookstack:23.12.2
FROM lscr.io/linuxserver/bookstack
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}