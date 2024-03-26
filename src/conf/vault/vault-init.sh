#!/usr/bin/env sh

#set -ex

#ref
#   construido baseando-se em:
#       https://github.com/ahmetkaftan/docker-vault/blob/master/docker-compose.yml

function unseal () {
  vault operator unseal $(grep 'Key 1:' /vault/file/keys | awk '{print $NF}')
  vault operator unseal $(grep 'Key 2:' /vault/file/keys | awk '{print $NF}')
  vault operator unseal $(grep 'Key 3:' /vault/file/keys | awk '{print $NF}')
}

function init () {
  vault operator init > /vault/file/keys
}

function log_in () {
  export ROOT_TOKEN=$(grep 'Initial Root Token:' /vault/file/keys | awk '{print $NF}')
  vault login ${ROOT_TOKEN}
}

function create_token () {
  vault token create -id ${STACK_VAULT_TOKEN}
  if [[ ${STACK_VAULT_TOKEN} != ${STACK_VAULT_TOKEN_DEPLOY} ]]; then
    vault token create -id ${STACK_VAULT_TOKEN_DEPLOY}
  fi
}

function kv_enable(){
  vault secrets enable -version=2 kv
}

function hostIsAvailable(){ 
  local __status=$(vault status -format=json 2>/dev/null)
  if [[ ${__status} == "" ]]; then
    return 0;
  fi

  local __check=$(echo ${__status} | grep "\"initialized\": true")
  if [[ ${__check} == "" ]]; then
    return 0;
  fi

  return 1;
}

hostIsAvailable
if ! [ "$?" -eq 1 ]; then
  echo "vault server is off"
  echo "  - ${VAULT_ADDR}"
  echo ""
  echo "restarting"
  sleep 2
  exit 0;
else
  echo "vault server is on"
  echo "  - ${VAULT_ADDR}"
  sleep 2
fi

export STACK_VAULT_TOKEN_FILE=/vault/file/vault-keys
if [[ -f ${STACK_VAULT_TOKEN_FILE} ]]; then
  echo "vault server has bean configured"
  echo "  - ${STACK_VAULT_TOKEN_FILE}"
  echo ""
  echo "finished"
  sleep infinity
  exit 0;
fi


if [ -s /vault/file/keys ]; then
   unseal
else
   init
   unseal
   log_in
   create_token
   kv_enable
fi

echo "# KEYS">${STACK_VAULT_TOKEN_FILE}
echo "  - INIT_KEY_FILE = /vault/file/keys">>${STACK_VAULT_TOKEN_FILE}
echo "  - ROOT_TOKEN = ${ROOT_TOKEN}">>${STACK_VAULT_TOKEN_FILE}
echo "  - STACK_VAULT_TOKEN = ${STACK_VAULT_TOKEN}">>${STACK_VAULT_TOKEN_FILE}
echo "  - STACK_VAULT_TOKEN_DEPLOY = ${STACK_VAULT_TOKEN_DEPLOY}">>${STACK_VAULT_TOKEN_FILE}

echo ""
cat ${STACK_VAULT_TOKEN_FILE}

vault status > /vault/file/status
echo "finished"
sleep infinity
exit 0;