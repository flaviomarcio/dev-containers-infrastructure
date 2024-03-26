FROM rabbitmq:3-management
LABEL maintainer "${STACK_ADMIN_USERNAME} <${STACK_ADMIN_EMAIL}>"

ENV TZ=${STACK_TZ}
RUN apt update;
RUN apt install -y tzdata;

#RUN rabbitmq-plugins enable --offline rabbitmq_mqtt rabbitmq_federation_management rabbitmq_stomp