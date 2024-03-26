#!/bin/bash

. ${BASH_BIN}/lib-strings.sh
. ${BASH_BIN}/lib-docker.sh
. ${STACK_RUN_BIN}/util-prepare.sh

function __private_docker_image_build_ignored()
{
  local __stack_name=${1}
  local __docker_file=${2}

  if [[ ${__docker_file} != "" ]]; then
    if ! [[ -f ${__docker_file} ]]; then
      export __func_return="Dockerfile not found: $(basename ${__docker_file})"
      return 1;
    fi
  fi

  if [[ ${__stack_name} == "registry" ]]; then
    export __func_return="Docker Registry ignored"
    return 1;
  elif [[ ${__stack_name} == "traefik" ]]; then
    export __func_return="Docker Traefik ignored"
    return 1;
  else
    return 0
  fi
}


function __private_docker_envsubst()
{
  if [[ ${1} == "" ]]; then
    return 0
  fi
  local __files=(${1})
  local __file_src=
  for __file_src in "${__files[@]}"
  do
    if [[ -f ${__file_src} ]]; then
      local __file_ori=${__file_src}.ori
      cat ${__file_src}>${__file_ori}
      envsubst < ${__file_ori} > ${__file_src}
      rm -rf ${__file_ori}
    fi
  done  

  return 1;
}

function __private_dockerImageBuildSingle()
{
  local __image_name=${2}
  local __dockerfile_src=${3}
  local __destine_dir=${4}
  echStart "${1}" "Building image"
  if [[ ${__dockerfile_src} == "" ]]; then
    echFail "${1}" "\${__dockerfile_src} is empty"
    return 0;
  elif ! [[ -f ${__dockerfile_src} ]]; then
    echFail "${1}" "Invalid dockerfile: ${__dockerfile_src}"
    return 0;
  elif [[ ${__destine_dir} == "" ]]; then
    echFail "${1}" "\${__destine_dir} is empty"
    return 0;
  elif ! [[ -d ${__destine_dir} ]]; then
    echFail "${1}" "Invalid destine-dir: ${__destine_dir}"
    return 0;
  fi
  
  local __source_dir="$(dirname ${__dockerfile_src})"
  local __dockerfile_dst="${__destine_dir}/${__image_name}.dockerfile"

  echProperty "${1}" "stack name [${__image_name}]"
  echProperty "${1}" "dockerfile"
  echProperty "${1}" "  local-dir: ${__source_dir}"
  echProperty "${1}" "    fileName: $(basename ${__dockerfile_src})"
  echProperty "${1}" "  destine-dir: ${__destine_dir}"
  echProperty "${1}" "    fileName: $(basename ${__dockerfile_dst})"

  local __docker_tag=${STACK_REGISTRY_DNS_PUBLIC}/${__image_name}

  cd ${__destine_dir}

  echAction "$(incInt ${1})" "Building..."
  echCommand "$(incInt ${1})" "cp -rf ${__dockerfile_src} ${__dockerfile_dst}"
  __private_docker_envsubst ${__dockerfile_dst}
  echCommand "$(incInt ${1})" "docker --log-level ERROR build --quiet --file ${__dockerfile_dst} -t ${__image_name} . -q"
  echCommand "$(incInt ${1})" "docker --log-level ERROR image tag ${__image_name} ${__docker_tag}"
  echCommand "$(incInt ${1})" "docker --log-level ERROR push ${__docker_tag}"
  if [[ ${PUBLIC_RUNNER_MODE} != debug ]]; then
  echCommand "$(incInt ${1})" "rm -rf ${__dockerfile_dst}"
  fi
  echFinished "$(incInt ${1})"
  echFinished "${1}"
  return 1
}

function __private_dockerComposeBuild()
{
  local __image_name=${2}
  local __compose_file_src=${3}
  local __destine_dir=${4}

  echStart "${1}" "Deploy container"
  if [[ ${__image_name} == "" ]]; then
    echFail "${1}" "Invalid env \${__image_name}"
    return 0;
  elif [[ ${__compose_file_src} == "" ]]; then
    echFail "${1}" "Invalid env \${__compose_file_src}"
    return 0;
  elif ! [[ -f ${__compose_file_src} ]]; then
    echFail "${1}" "Invalid docker compose file: ${__compose_file_src}"
    return 0;
  elif [[ ${__destine_dir} == "" ]]; then
    echFail "${1}" "Invalid env \${__destine_dir}"
    return 0;
  elif ! [[ -d ${__destine_dir} ]]; then
    echFail "${1}" "Invalid destine dir: ${__destine_dir}"
    return 0;
  fi

  local __file_dir=$(dirname ${__compose_file_src})

  local __service_name=$(echo ${__image_name} | sed 's/_/-/g')

  local __stack_env_file=$(echo ${__compose_file_src} | sed 's/yml/env/g')
  local __compose_file_dst="$(dirname ${__compose_file_src})/"

  local __compose_file_src="./$(basename ${__compose_file_src})"
  local __stack_env_file="./$(basename ${__stack_env_file})"
  local __compose_file_dst="${__destine_dir}/${__service_name}.yml"

  echProperty "${1}" "stack name: ${__service_name}"
  echProperty "${1}" "compose file"
  echProperty "${1}" "  local-dir: ${__file_dir}"
  echProperty "${1}" "    fileName: $(basename ${__compose_file_src})"
  echProperty "${1}" "  destine-dir: ${__destine_dir}"
  echProperty "${1}" "    fileName: $(basename ${__compose_file_dst})"
  echAction  "${1}" "Deploying"

  cd ${__file_dir}

  if [[ -f ${__compose_file_src} ]]; then
    local __check=$(docker stack ls | grep "'${__service_name}'")
    if [[ ${__check} != "" ]]; then
      echCommand "$(incInt ${1})" "docker stack rm ${__service_name}"
    fi

    if [[ -f ${__stack_env_file} ]]; then
      echCommand "$(incInt ${1})" ${__stack_env_file}
    fi
    echCommand "$(incInt ${1})" "cp -rf ${__compose_file_src} ${__compose_file_dst}"
    cd ${__destine_dir}
    __private_docker_envsubst ${__compose_file_dst}
    echCommand "$(incInt ${1})" "docker stack deploy -c ${__compose_file_dst} ${__service_name}"
    if [[ ${PUBLIC_RUNNER_MODE} != debug ]]; then
      echCommand "$(incInt ${1})" "rm -rf ${__compose_file_dst}"
    fi
  fi
  echFinished "${1}"
  return 1
}

function installStack()
{
  local __environment=${2}
  local __target=${3}
  local __image_check=${4}
  local __name=${5}
  local __domain=${6}

  echo ""
  echStep "${1}" "Iniciando instalação"

  if [[ ${__environment} == "" ]]; then
    echFail "${1}" "Invalid env \${__environment}"
    return 0
  elif [[ ${__target} == "" ]]; then
    echFail "${1}" "Invalid env \${__target}"
    return 0
  elif [[ ${__name} == "" ]]; then
    echFail "${1}" "Invalid env \${__name}"
    return 0
  elif [[ ${__domain} == "" ]]; then
    echFail "${1}" "Invalid env \${__domain}"
    return 0
  fi

  echProperty "${1}" Stack ${__name}
  if ! [[ -d ${STACK_INFRA_CONF_DIR} ]]; then
    echFail "${1}" "Infrastructure config not found: ${STACK_INFRA_CONF_DIR}"
    echFail "${1}" "Execute option: [Cluster-Infrastructure]"
    return 0
  fi

  utilPrepareInit "${__environment}" "${__target}" "${__name}"
  if ! [ "$?" -eq 1 ]; then
    echFail "${1}" "fail on calling utilPrepareInit, ${__func_return}"
    return 0;
  fi

  local __destine_builder_dir="${HOME}/build/pipelines/${__environment}-${__target}/tools/${__name}"
  rm -rf ${__destine_builder_dir}
  mkdir -p ${__destine_builder_dir}

  local __docker_file=${STACK_IMAGES_DIR}/${STACK_NAME}.dockerfile
  __private_docker_image_build_ignored "${STACK_NAME}" "${__docker_file}"
  if [ "$?" -eq 1 ]; then
    echProperty "${1}" "Image build ignored, ${__func_return}"
  else
    __private_dockerImageBuildSingle "$(incInt ${1})" "${STACK_SERVICE_IMAGE}" "${__docker_file}" "${__destine_builder_dir}"
    if ! [ "$?" -eq 1 ]; then
      echFail "${1}" "fail on calling __private_dockerImageBuildSingle"
      return 0;
    fi

    if [[ ${__image_check} != true ]]; then
      echAction "${1}" "Image check ingnored"
    else
      dockerRegistryImageCheck "${STACK_SERVICE_IMAGE}"
      if ! [ "$?" -eq 1 ]; then
        echProperty "${1}" "image: ${STACK_SERVICE_IMAGE_URL}"
        echWarning "${1}" "Image not found"
      fi
    fi
  fi

  local __docker_compose_file="${STACK_YML_DIR}/${STACK_NAME}.yml"
  __private_dockerComposeBuild "$(incInt ${1})" "${STACK_SERVICE_IMAGE}" "${__docker_compose_file}" "${__destine_builder_dir}"
  if ! [ "$?" -eq 1 ]; then
    echFail "${1}" "fail on calling __private_dockerComposeBuild"
    return 0;
  fi
  echFinished "${1}"
  return 1
 
}
