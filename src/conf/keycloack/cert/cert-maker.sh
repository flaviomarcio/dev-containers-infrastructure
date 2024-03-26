#!/bin/bash

. ${BASH_BIN}/lib-ssl.sh

#gen certfile.crt certfile.key certfile.pem
certCreate certfile

#gen keyfile.crt keyfile.key keyfile.pem
certCreate keyfile