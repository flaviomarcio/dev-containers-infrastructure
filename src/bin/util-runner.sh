#!/bin/bash

. lib-docker.sh
. lib-database.sh
. lib-selector.sh
. lib-system.sh
. lib-deploy.sh
. util-prepare.sh
. util-install.sh

function __private_clusterConfigure()
{
  local __arg_environment=${1}
  local __arg_target=${2}
  local __arg_stacks="${3}"
  if ! [[ -d ${STACK_INFRA_CONF_DIR} ]]; then
    clusterConfigureSettingFirstMain "${__arg_environment}" "${__arg_target}" "${__arg_stacks}"
    if ! [ "$?" -eq 1 ]; then
      echFail "${1}" "fail on calling clusterConfigureSettingFirstMain"
      return 0;
    fi
  fi
  
  echStart ${1} "Cluster configuring"
  __private_container_install false false "${__arg_stacks}"
  if [[ "$?" -eq 2 || "$?" -eq 1 ]]; then
    echFinished "${1}"
    return 1;
  fi
  echFail "${1}" "fail on calling __private_container_install"
  echFinished "${1}"
  return 0;
}

function __selectStack_yml_list()
{
  local __old_dir=${PWD}
  cd ${STACK_YML_DIR};
  local __args=$(ls *.yml) 
  local __args=$(sed "s/.yml//g" <<< "${__args}")
  local __args=$(echo ${__args} | sort)
  cd ${__old_dir}  
  echo "back ${__args}"  
}

function __selectStack()
{
  unset __func_return
  clearTerm
  echM $'\n'"Stack menu"$'\n'
  PS3="Choose a option: "
  local options=($(__selectStack_yml_list))
  select opt in "${options[@]}"
  do
    export __opt=${opt}
    local __file="${STACK_YML_DIR}/${__opt}.yml"
    if [[ ${__opt} == "back" ]]; then
      return 0;
    elif [[ -f ${__file} ]]; then
      export __func_return=${__opt}
      return 1
    else
      echR "Invalid option ${opt}"
      sleep 1
    fi
  done
  return 0
}

function __private_container_install()
{
  local __environment=${STACK_ENVIRONMENT}
  local __target=${STACK_TARGET}
  local __domain=${STACK_DOMAIN}
  local __repeat=${1}
  local __image_check=${2}
  local __stacks=${3}

  while :
  do

    if [[ ${__stacks} == "" ]]; then
      __selectStack
      if ! [ "$?" -eq 1 ]; then
        return 2;
      fi
      local __stacks=${__func_return}
    fi
    if [[ ${__stacks} == "" ]]; then
      return 1
    fi
    local __stacks=(${__stacks})
    local __stack=
    for __stack in "${__stacks[@]}"
    do
      utilPrepareInit "${__environment}" "${__target}" "${__stack}"
      if ! [ "$?" -eq 1 ]; then
        echFail "${1}" "fail on calling utilPrepareInit, ${__func_return}"
        return 0;
      fi
      installStack 1 \
                    "${__environment}" \
                    "${__target}" \
                    "${__image_check}" \
                    "${__stack}" \
                    "${__domain}" 

      if ! [ "$?" -eq 1 ]; then
        echFail 1 "fail on calling installStack"
        return 0;
      fi
    done

    if [[ ${__repeat} == true ]]; then
      export __stacks=
    else
      break
    fi
  done
  read
  return 1;
}

function clusterConfigureSettingFirstMain()
{
  local __arg_environment=${1}
  local __arg_target=${2}
  export STACK_SCOPE_INITED=
  echStart ${1} "Cluster basic configuration installing"

  utilPrepareInit "${__arg_environment}" "${__arg_target}"
  if ! [ "$?" -eq 1 ]; then
    echFail "${1}" "fail on calling utilPrepareInit, ${__func_return}"
    return 0;
  fi

  utilInfrastructureConfigInstall $(incInt ${1}) "${__arg_environment}" "${__arg_target}"
  if ! [ "$?" -eq 1 ]; then
    echFail "${1}" "fail on calling utilInfrastructureConfigInstall"
    return 0;
  fi

  echFinished "${1}"
  return 1
}

function clusterConfigureFirstMain()
{
  local __arg_environment=${1}
  local __arg_target=${2}
  local __arg_stacks="traefik registry"
  if [[ ${STACK_DNS_SERVER_ENABLE} == true ]]; then
    local __arg_stacks="${__arg_stacks} dnsmasq"
  fi

  __private_clusterConfigure "${__arg_environment}" "${__arg_target}" "${__arg_stacks}"
  if [[ "$?" -eq 2 || "$?" -eq 1 ]]; then
    return 1;
  fi
  return 0
}

function clusterConfigureDatabaseMain()
{
  local __arg_environment=${1}
  local __arg_target=${2}

  unset __arg_stacks
  local __arg_stacks="${__arg_stacks} influxdb"
  local __arg_stacks="${__arg_stacks} postgres"
  local __arg_stacks="${__arg_stacks} minio"
  local __arg_stacks="${__arg_stacks} redis"
  local __arg_stacks="${__arg_stacks} rabbitmq"
  

  __private_clusterConfigure "${__arg_environment}" "${__arg_target}" "${__arg_stacks}"
  if [[ "$?" -eq 2 || "$?" -eq 1 ]]; then
    return 1;
  fi
  return 0
}


function clusterConfigureForDeployMain()
{
  local __arg_environment=${1}
  local __arg_target=${2}

  unset __arg_stacks
  local __arg_stacks="${__arg_stacks} gocd"
  local __arg_stacks="${__arg_stacks} jenkins"
  local __arg_stacks="${__arg_stacks} portainer"

  __private_clusterConfigure "${__arg_environment}" "${__arg_target}" "${__arg_stacks}"
  if [[ "$?" -eq 2 || "$?" -eq 1 ]]; then
    return 1;
  fi
  return 0
}

function clusterConfigureDocumentation()
{
  __private_container_install false true "wikijs bookstack"
  if [[ "$?" -eq 2 || "$?" -eq 1 ]]; then
    return 1;
  fi
}

function clusterConfigureForServices()
{
  __private_container_install false true "keycloak nexus airflow kong-api konga rabbitmq minio vault" #camunda
  if [[ "$?" -eq 2 || "$?" -eq 1 ]]; then
    return 1;
  fi
}

function clusterConfigureObservabilityMain()
{
  local __arg_environment=${1}
  local __arg_target=${2}

  unset __arg_stacks
  local __arg_stacks="${__arg_stacks} prometheus"
  local __arg_stacks="${__arg_stacks} prometheus-pushgateway"
  local __arg_stacks="${__arg_stacks} prometheus-node-exporter"
  local __arg_stacks="${__arg_stacks} prometheus-blackbox-exporter"
  local __arg_stacks="${__arg_stacks} prometheus-alert-manager"
  local __arg_stacks="${__arg_stacks} prometheus-alert-manager-calert"

  local __arg_stacks="${__arg_stacks} cadvisorZFS"

  local __arg_stacks="${__arg_stacks} grafana-dashboard"
  local __arg_stacks="${__arg_stacks} grafana-tempo"
  local __arg_stacks="${__arg_stacks} grafana-loki"
  local __arg_stacks="${__arg_stacks} grafana-promtail"
  local __arg_stacks="${__arg_stacks} grafana-k6-tracing"

  #opentelemetry

  __private_clusterConfigure "${__arg_environment}" "${__arg_target}" "${__arg_stacks}"
  if [[ "$?" -eq 2 || "$?" -eq 1 ]]; then
    return 1;
  fi
  return 0
}

function clusterConfigureForSingleServicesMain()
{
  __private_container_install true true ""
  return 1
}

function systemDNSOptions()
{
  opt=$(selectorDNSOption)
  if [[ ${opt} == "etc-hosts" ]]; then
   systemETCHostApply
  elif [[ ${opt} == "print" ]]; then
    systemETCHostPrint
  fi 
  return 1
}