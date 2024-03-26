# Pipelines para ferramentas necessárias para o desenvolvimento

Neste repositório encontrar o necessário para rodar o ambiente produção em seu setup atual.

## Requirements

- Para construir, testar e executar os serviços você precisará:
    - [Linux]
        - Debian|Ubuntu
    - [Windows-wsl2]
        - Debian|Ubuntu
    - [JDK - 17](https://openjdk.org/install/)
    - [Maven - 3](https://maven.apache.org)
    - [Spring Boot - [3.2.3]](https://spring.io/)
    - [Spring Cloud - [3.2.3]](https://spring.io/)
    - [Quarkus - [3.8.1]](https://quarkus.io/)
    - [Intellij](https://www.jetbrains.com/pt-br/idea/)
    - [Docker]
        - [Install Docker on Debian](https://docs.docker.com/engine/install/debian/)
        - [Install Docker on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
# PipeLines

## Utilize os videos para prévia orientação:
- [Configurando ambiente MP4](/docs/resources/00-ambiente-configurando.mp4)
- [Configurando Vault MP4](/docs/resources/01-deploy-vault.mp4)
- [Configurando RabbitMQ MP4](/docs/resources/02-configurando-rabbitmq.mp4)


## Passo 1 - Configurando o ambiente
- Clonando o repositório 
    ```bash
    mkdir sources
    cd sources
    git clone git@github.com:flaviomarcio/erp-containers-infrastructure.git
    #entre no repositório
    cd erp-containers-infrastructure
    ```

- Executando o console
    ```bash
    #execute ./run para iniciar o console
    ./run

    #Ao iniciar o docker swarm não estará configurado desta forma você verá o seguinte output
    #Output:
        Docker swarm não está instalado
        [ENTER] para configurar

    #Aperte [ENTER] para iniciar
    #Output:
        Action: [Swam-Init]
            - docker swarm init --advertise-addr 192.168.15.12
        Executing ...
            Swarm initialized: current node (jwowjvxn7zobowqwqftrw4is8) is now a manager. ...
            - Successfull
        Finished
    ```
    - A execução do script anterior é demostrada neste video
        - [Configurando ambiente MP4](/docs/resources/00-ambiente-configurando.mp4)


## Pass 2 - Configurando serviços
- Iniciando a ferramenta de **deploy**
    
    ```bash
    # execute ./run
    ./run
    ```
    Selecione a opção de build - **6) Single-services**
    ```bash
    OS informations
    - Linux debian.debian.org 5.10.0-28-amd64 #1 SMP Debian 5.10.209-2 (2024-01-31) x86_64 GNU/Linux
    - Docker version 25.0.3, build 4debf41, IPv4: 192.168.15.12
    - Target: company, Environment: testing

    Pipelines - Infrastructure

     1) Quit                     
     2) Docker-list             # Exibirá lista de serviços instalados
     3) Docker-Swarm            # Docker swarm Init ou leave
     4) Docker-reset            # Reset total do ambiente docker (container, services, stacks, volumes, networks)
     5) Single-services         # Instalação individual de um serviço
     6) Cluster-setting-first   # Instalação das configurações predefinidas no ambiente configurado (testing|development|stating|production)
     7) Cluster-services-first  # Instalação dos serviços minimos para o ambiente docker swarm
     8) Cluster-for-services    # Instalação dos serviços necessários para as micros serviços serem instalados
     9) Cluster-for-deploy      # Instalação dos serviços necessários para deploy(Não recomendando para ambiente testing) 
    10) Cluster-database        # Instalação dos serviços de bancos de dados disponiveis na lista de serviços
    11) Cluster-documentation   # Instalação dos serviços de documentação disponiveis na lista de serviços
    12) Cluster-observability   # Instalação dos serviços para o ambiente de observabilidade
    13) Public-Envs             # Configuração das variaveis de ambiente como STACK_TARGET, STACK_ENVIRONMENT e outros
    14) DNS-options             # Lista de DNS dos serviços existentes
    15) Command-utils           # Lista de comandos uteis para manutenção do ambiente Docker Swarm

    Choose option: 5
    ```  
    
    Choose a option: 
    ```
    Selecione a opção de build - **vault**, **rabbitmq** ou qualquer outro serviço
    >Obs: Devido a melhorias os numeros das opções podem mudar logo estes estão são 
    ```bash
    Stack menu

     1) back                             
     2) activemq                         
     3) airflow                          
     4) bookstack                        
     5) cadvisor                         
     6) cadvisorZFS                      
     7) camunda                          
     8) debian                           
     9) dnsserver                        
    10) gocd                             
    11) grafana-dashboard                
    12) grafana-k6-tracing               
    13) grafana-loki                     
    14) grafana-promtail                 
    15) grafana-tempo                    
    16) haproxy                          
    17) influxdb                         
    18) jenkins                          
    19) keycloak-h2                      
    20) keycloak                         
    21) kong-api                         
    22) konga                            
    23) ldap                             
    24) localstack                       
    25) mariadb                          
    26) minio                            
    27) mistborn                         
    28) mysql                            
    29) nexus                            
    30) opentelemetry                    
    31) oracle-11g                       
    32) oracle-free                      
    33) oracle                           
    34) portainer-cluster                
    35) portainer                        
    36) postgres-9                       
    37) postgres-admin                   
    38) postgres                         
    39) prometheus-alert-manager-calert  
    40) prometheus-alert-manager         
    41) prometheus-blackbox-exporter     
    42) prometheus-node-exporter
    43) prometheus-pushgateway
    44) prometheus
    45) rabbitmq
    46) redis
    47) redoc
    48) registry
    49) sonarqube-bi
    50) sonarqube
    51) traefik
    52) vault
    53) wikijs
    54) wireguard
    55) wordpress

    Choose a option: 
    ```
    - A execução do script anterior é demostrada nos videos
        - [Configurando Vault MP4](/docs/resources/01-deploy-vault.mp4)
        - [Configurando RabbitMQ MP4](/docs/resources/02-configurando-rabbitmq.mp4)