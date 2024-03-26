#!/bin/bash

export CERT_NAME=${1}

if [[ ${CERT_NAME} == "" ]];then
    CERT_NAME=server
fi

../../cert/cert-maker.sh ${CERT_NAME}