#!/bin/bash

if [[ ${BASH_BIN} == "" ]]; then
  BASH_BIN="$(dirname ${PWD})/bash-bin"
fi

. ${BASH_BIN}/lib-strings.sh
. ${BASH_BIN}/lib-stack.sh

function __private_envsLoadTraefik()
{
  unset __func_return
  local __domain=${1}

  # if [[ ${STACK_TRAEFIK_PASS} == "" ]]; then
  #   export STACK_TRAEFIK_PASS=$(echo ${STACK_SERVICE_DEFAULT_USER} | sed -e 's/\\$/\\$\\$/g')
  # else
  #   export STACK_TRAEFIK_PASS=$(echo ${STACK_TRAEFIK_PASS} | sed -e 's/\\$/\\$\\$/g')
  # fi

  envsSetIfIsEmpty STACK_TRAEFIK_USER ${STACK_SERVICE_DEFAULT_USER}
  envsSetIfIsEmpty STACK_TRAEFIK_PASS ${STACK_SERVICE_DEFAULT_PASS}
  envsSetIfIsEmpty STACK_TRAEFIK_API_ENABLED false
  envsSetIfIsEmpty STACK_TRAEFIK_DASHBOARD_ENABLED false
  envsSetIfIsEmpty STACK_TRAEFIK_API_INSECURE true
  envsSetIfIsEmpty STACK_TRAEFIK_TLS_ENABLED false

  envsSetIfIsEmpty STACK_TRAEFIK_TLS_DOMAIN ${__domain}
  envsSetIfIsEmpty STACK_TRAEFIK_TLS_DOMAIN_SANS "*.${__domain}"

  envsSetIfIsEmpty STACK_TRAEFIK_PORT_HTTP "${STACK_PROXY_PORT_HTTP}"
  envsSetIfIsEmpty STACK_TRAEFIK_PORT_HTTPS "${STACK_PROXY_PORT_HTTPS}"
  envsSetIfIsEmpty STACK_TRAEFIK_PORT_REGISTRY 5000
  envsSetIfIsEmpty STACK_TRAEFIK_PORT_POSTGRES 5432
  envsSetIfIsEmpty STACK_TRAEFIK_PORT_RABBITMQ 5672
  envsSetIfIsEmpty STACK_TRAEFIK_PORT_INFLUXDB 8086
  envsSetIfIsEmpty STACK_TRAEFIK_PORT_MYSQL 3306
  envsSetIfIsEmpty STACK_TRAEFIK_PORT_REDIS 6379
  envsSetIfIsEmpty STACK_TRAEFIK_PORT_MSSQL 1433

  envsSetIfIsEmpty STACK_LDAP_DOMAIN "${STACK_TARGET}.int"
  envsSetIfIsEmpty STACK_LDAP_ROOT_DN "dc=${STACK_TARGET},dc=int"

  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_USER
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PASS

  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_API_ENABLED
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_DASHBOARD_ENABLED
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_API_INSECURE
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_TLS_ENABLED
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_TLS_DOMAIN
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_TLS_DOMAIN_SANS
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PORT_HTTP
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PORT_HTTPS
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PORT_REGISTRY
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PORT_POSTGRES
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PORT_RABBITMQ
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PORT_INFLUXDB
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PORT_MYSQL
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PORT_REDIS
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_TRAEFIK_PORT_MSSQL

  return 1
}

function __private_envsLoadHaProxy()
{
  unset __func_return

  envsSetIfIsEmpty STACK_PROXY_PORT_HTTP "${STACK_PROXY_PORT_HTTP}"
  envsSetIfIsEmpty STACK_PROXY_PORT_HTTPS "${STACK_PROXY_PORT_HTTPS}"

  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_PROXY_PORT_HTTP
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_PROXY_PORT_HTTPS

  return 1
}

function __private_envsLoadGoCD()
{
  #gocd
  envsSetIfIsEmpty STACK_GOCD_REGISTER_KEY "ff4a24e0-281f-4006-89c7-7c2c33cd7fda"
  envsSetIfIsEmpty STACK_GOCD_WEB_HOOK_SECRET "d68a4f11-f10f-4f45-9729-dfcf8c316eb7"
  envsSetIfIsEmpty STACK_GOCD_SERVER_ID "84737b87-05b7-4de7-925c-66e475a9a684"
  envsSetIfIsEmpty STACK_GOCD_GIT_REPOSITORY
  envsSetIfIsEmpty STACK_GOCD_GIT_BRANCH
  envsSetIfIsEmpty STACK_GOCD_AGENT_REPLICAS 1

  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_GOCD_REGISTER_KEY
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_GOCD_WEB_HOOK_SECRET
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_GOCD_SERVER_ID
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_GOCD_GIT_REPOSITORY
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_GOCD_GIT_BRANCH
  envsFileAddIfNotExists ${PUBLIC_STACK_TARGET_ENVS_FILE} STACK_GOCD_AGENT_REPLICAS
  return 1
}

function utilPrepareInit()
{
  local __stack_environment=${1}
  local __stack_target=${2}
  local __stack_name=${3}

  if [[ ${__stack_name} == "" ]];then
    stackEnvsLoad "${__stack_environment}" "${__stack_target}"
    if ! [ "$?" -eq 1 ]; then
      export __func_return="fail on calling stackEnvsLoad, ${__func_return}"
      return 0;
    fi
  else
    stackEnvsLoadByStack "${__stack_environment}" "${__stack_target}" "${__stack_name}"
    if ! [ "$?" -eq 1 ]; then
      export __func_return="fail on calling stackEnvsLoadByStack, ${__func_return}"
      return 0;
    fi
  fi

  __private_envsLoadTraefik ${STACK_DOMAIN}
  if ! [ "$?" -eq 1 ]; then
    export __func_return="fail on calling __private_envsLoadTraefik: ${__func_return}"
    return 0;
  fi

  __private_envsLoadHaProxy ${STACK_DOMAIN}
    if ! [ "$?" -eq 1 ]; then
    export __func_return="fail on calling __private_envsLoadHaProxy: ${__func_return}"
    return 0;
  fi

  __private_envsLoadGoCD
    if ! [ "$?" -eq 1 ]; then
    export __func_return="fail on calling __private_envsLoadGoCD: ${__func_return}"
    return 0;
  fi

  export STACK_ACTIONS_DIR=${STACK_RUN_BIN}/actions
  export STACK_YML_DIR=${ROOT_DIR}/stack
  export STACK_IMAGES_DIR=${ROOT_DIR}/images
  export STACK_CONFIG_LOCAL_DIR=${ROOT_DIR}/conf

  stackInitTargetEnvFile

  return 1
}

function utilInfrastructureConfigInstall()
{
  echStep "${1}" "Copying configuration" __private_scopeInstall
  echProperty "${1}" "Dir ${STACK_CONFIG_LOCAL_DIR}"

  local e1=$(incInt ${1})
  local e2=$(incInt ${e1})

  if [[ ${STACK_CONFIG_LOCAL_DIR} == "" ]]; then
    echFail "${1}" "fail invalid env \${STACK_CONFIG_LOCAL_DIR}"
    return 0;
  fi

  if ! [[ -d ${STACK_CONFIG_LOCAL_DIR} ]]; then
    echFail "${1}" "fail dir not found : ${STACK_CONFIG_LOCAL_DIR}"
    return 0;
  fi

  if [[ -d ${STACK_INFRA_CONF_DIR}  ]]; then
    local OLD_DIR=${STACK_INFRA_CONF_DIR}_old  
    echCommand "${1}" "rm -rf ${OLD_DIR}"
    echCommand "${1}" "mv ${STACK_INFRA_CONF_DIR} ${OLD_DIR}"
  fi
  local __config_dir=$(dirname ${STACK_INFRA_CONF_DIR})
  if ! [[ -d ${__config_dir} ]]; then
    mkdir -p ${__config_dir}
    if ! [[ -d ${__config_dir} ]]; then
      echFail "${1}" "fail on create dir: ${__config_dir}"
      return 0;
    fi
  fi
  echTitle "${1}" "Copying: settings"
  echProperty "${1}" "from: ${STACK_CONFIG_LOCAL_DIR}"
  echProperty "${1}" "to: ${STACK_INFRA_CONF_DIR}"
  echCommand "${1}" "cp -rf ${STACK_CONFIG_LOCAL_DIR} ${STACK_INFRA_CONF_DIR}"

  local __filters=()
  local __filters+=(crt)
  local __filters+=(key)
  local __filters+=(csr)
  local __filters+=(pem)
  local __filters+=(ca)
  local __filters+=(sh)
  local __filters+=(cfg)
  local __filters+=(conf)
  local __filters+=(yml)
  local __filters+=(yaml)
  local __filters+=(hcl)
  local __filters+=(json)
  local __filters+=(properties)
  local __filters+=(xml)
  local __filters+=(sql)
  local __filters+=(ldif) #ldap
  local __filter=
  for __filter in ${__filters[*]};
  do
    echTitle "${1}" "Parsing: *.${__filter}"
    if [[ ${__filter} == "crt" || ${__filter} == "key" || ${__filter} == "csr" || ${__filter} == "pem" || ${__filter} == "ca" ]]; then
      echCommand "${e1}" "--ignore" "No parser action, just copy"
    else
      local __files=($(find ${STACK_INFRA_CONF_DIR} -iname "*.${__filter}" | sort))
      local __file=
      for __file in ${__files[*]};
      do
        local __fileName=$(basename ${__file})
        local __file_temp="/tmp/$(basename ${__file}).tmp"
        #echCommand "${e1}" "--ignore" "cat ${__fileName}>${__file_temp}" 
        cat ${__file}>${__file_temp}
        #echCommand "${e1}" "--ignore" "envsubst < ${__fileName} > ${__fileName}" 
        envsubst < ${__file_temp} > ${__file}
        if [[ ${__filter} == "sh" ]]; then
          #echCommand "${e1}" "--ignore" "chmod +x ${__fileName}"
          chmod +x ${__file}
        fi
        #echo ""
      done
    fi
  done  

  echFinished "${1}" 1 __private_scopeInstall
  return 1
}