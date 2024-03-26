export PATH=${PATH}:${BASH_BIN}
export PATH=${PATH}:${BASH_BIN}
export PATH=${PATH}:${PWD}/lib

. ${BASH_BIN}/lib-strings.sh
. ${BASH_BIN}/lib-docker.sh
. ${BASH_BIN}/lib-selector.sh
. ${BASH_BIN}/lib-database.sh
. util-runner.sh

function __private_runnerMenu()
{
  clearTerm
  __private_print_os_information
  __runner_menu_environment=${1} 
  __runner_menu_target=${2}

  options=(Quit)
  options+=(Docker-list)
  options+=(Docker-Swarm)
  options+=(Docker-reset)
  options+=(Single-services)
  options+=(Cluster-setting-first)
  options+=(Cluster-services-first)
  options+=(Cluster-for-services)
  options+=(Cluster-for-deploy)
  options+=(Cluster-database)
  options+=(Cluster-documentation)
  options+=(Cluster-observability)
  options+=(Public-Envs)
  options+=(DNS-options)
  options+=(Command-utils)
  echM $'\n'"Pipelines - Infrastructure"$'\n'
  PS3=$'\n'"Choose option:"
  select opt in "${options[@]}"
  do
    if [[ ${opt} == "Quit" ]]; then
      exit 0
    fi
    echo ""
    echo "Action selected: [${opt}]"
    echo ""
    if [[ ${opt} == "Docker-list" ]]; then
      dockerList ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Docker-Swarm" ]]; then
      dockerSwarmConfigure ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Docker-reset" ]]; then
      dockerReset ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Cluster-setting-first" ]]; then
      clusterConfigureSettingFirstMain ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Single-services" ]]; then
      clusterConfigureForSingleServicesMain ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Cluster-services-first" ]]; then
      clusterConfigureFirstMain ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Cluster-database" ]]; then
      clusterConfigureDatabaseMain ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Cluster-for-services" ]]; then
      clusterConfigureForServices ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Cluster-for-deploy" ]]; then
      clusterConfigureForDeployMain ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Cluster-documentation" ]]; then
      clusterConfigureDocumentation ${__runner_menu_environment} ${__runner_menu_target}      
    elif [[ ${opt} == "Cluster-observability" ]]; then
      clusterConfigureObservabilityMain ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Public-Envs" ]]; then
      stackPublicEnvs ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "DNS-options" ]]; then
      systemDNSOptions ${__runner_menu_environment} ${__runner_menu_target}
    elif [[ ${opt} == "Command-utils" ]]; then
      selectorCommands ${__runner_menu_environment} ${__runner_menu_target}
    else
      echR "Invalid option ${opt}"
    fi
    echB
    echG "[ENTER] to continue"
    echG
    read
    return 1
  done
}

function runnerMain()
{
  clearTerm
  utilInitialize "$@"

  if [[ ${PUBLIC_RUNNER_MODE} == test ]]; then
    ./runner-test.sh
    exit 0;
  fi

  clearTerm

  dockerSwarmVerify
  if ! [ "$?" -eq 1 ]; then
    echR "Invalid dockerSwarmVerify"
    exit 0
  fi

  if [[ ${__public_target} == "" ]]; then
    selectorCustomer 1
    if ! [ "$?" -eq 1 ]; then
      echR "Invalid selectorCustomer"
      exit 0
    fi
    export __public_target=${__selector}
  fi

  if [[ ${__public_environment} == "" ]]; then
    selectorEnvironment 1
    if ! [ "$?" -eq 1 ]; then
      echR "Invalid selectorEnvironment"
      exit 0
    fi
    export __public_environment=${__selector}
  fi

  utilPrepareInit "${__public_environment}" "${__public_target}"
  if ! [ "$?" -eq 1 ]; then
    echFail "${1}" "fail on calling utilPrepareInit, ${__func_return}"
    return 0;
  fi

  while :
  do
    __private_runnerMenu "${__public_environment}" "${__public_target}"
  done
}

runnerMain "$@"