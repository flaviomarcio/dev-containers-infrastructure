#!/bin/bash

local __files=(server.key server.crt)

local __pg_dir=/cert-pg

mkdir -p ${__pg_dir}
for __file in ${__files[*]};
do
  local __src=/cert/${__file}
  if [[ -f ${__src]}  ]]; then 

    echo "local __dst=${__pg_dir}/${__file}"
    echo "rm -rf ${__dst}"
    echo "cp -rf  ${__src}  ${__dst}"
    echo "chown root:root ${__dst}"
    echo "chmod 600 ${__dst}"

    local __dst="${__pg_dir}/${__file}"
    rm -rf ${__dst}
    cp ${__src}  ${__dst}
    chmod 600 ${__dst}
  fi
done

chown -R root:root /var/lib/postgresql