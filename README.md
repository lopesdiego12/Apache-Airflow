# Agenda

* [Surgimento](##História)
* [O que é](#o-que-%C3%A9)
* [Conceitos](#Conceitos)
* [Arquitetura](#Arquitetura)
* [Docker*](#Docker)
* [Hands-on](#Hands-on)

## Surgimento
  

> Criado pelo time de desenvolvedores do AirBnB, com o intuito de definir fluxos de trabalho(workflow) que envolve consulta de dados de inúmeras fontes, tratamento e mineração de dados, de forma que possa ser feito de forma periódica ou não, ou seja, uma pipeline de dados. Ela se tornou open source em meados de 2015, sendo divulgado por um post no blog aonde os engenheiros e cientistas de dados da empresa compartilham suas experiências. Depois de algum tempo, ela foi cedida para o Apache em que se tornou um dos inúmeros projetos que ela mantém, hoje chamado de apache airflow.  

>[Anúncio AirBnB](https://medium.com/airbnb-engineering/airflow-a-workflow-management-platform-46318b977fd8)

>[Documentação](https://airflow.apache.org/docs/stable/)

>[Github Airflow](https://github.com/apache/airflow)

>[Instalação](https://github.com/apache/airflow/blob/master/docs/installation.rst)

------

## O que é
* O Apache Airflow é uma plataforma de gerenciamento de fluxo de trabalho open source
* Forma simples e visual de controlar tarefas agendas
* Tarefas agendadas para executar a qualquer momento ou com condições específicas(Celery)
* Monitoramento centralizado de todas as tarefas, tedo total autonamia e gerenciamento de quando e como executou/falhou.


------

## Conceitos

##### Operators

Executam uma ação ou manda informação para outro sistema executar uma ação dentro do seu workflow

##### Dags
DAG = Directed Acyclic Graph

É um grafo acíclico, em que todas as tarefas que são executadas e organizadas de uma forma que reflete os seus relacionamentos e dependências. Você pode definir que um determinado nó deve ser executado se a anterior for um sucesso ou não, ou que o nó A terá um timeout de 5 minutos, e o nó B pode ser reiniciado até 5 vezes caso não tenha sucesso.
Dessa forma cada arquivo python armazena uma DAG, e ela é reconhecida pelo Airflow para sua execução na pasta dags que criamos anteriormente. Você pode mudar o caminho dessa pasta, alterando as configurações da ferramenta.

##### Tasks
Tarefas dentro de uma dag.

##### Outros conceitos: XComs, Variables, Recap, Connections, Hooks


##### Arquitetura

> Webserver

Inteface gráfica (GUI)

>Scheduler

The Airflow scheduler monitora todas as tasks e todas as Dags para assegurar que todas as execuções estão conforme agendadas.

>Worker

Airflow workers espera, processa e enfileira

>Flower
Flower é uma ferramenta baseada em web para monitorar e administrar os operadores Celery


>Airflow database

Guarda os metadados do airflow, histórico de execuções, dos jobs/tasks

> Redis

Message queue do airflow



## Docker 
Fornece uma camada de abstração e automação para virtualização de sistema operacional

## Docker compose
Roda múltiplos containers e sobe múltiplos serviços/aplicações através de comandos no arquivo YAML(YML)


## Hands-on

Para baixar a imagem que iremos utilizar favor executar o comando abaixo

[Docker hub](https://hub.docker.com/r/puckel/docker-airflow/)


    docker pull puckel/docker-airflow 


Faça o download do arquivo yml antes de executar o comando abaixo

[YML file](https://raw.githubusercontent.com/lopesdiego12/Apache-Airflow/master/docker-compose-CeleryExecutor.yml)

    docker-compose -f docker-compose-CeleryExecutor.yml up -d
