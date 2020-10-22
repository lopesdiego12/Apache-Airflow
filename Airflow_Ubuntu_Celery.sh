#!/bin/bash

# initial system updates and installs
apt-get update && apt-get upgrade -y && apt-get autoremove && apt-get autoclean
apt-get -y install build-essential binutils gcc make git htop nethogs tmux

# installing PostgreSQL and preparing the database
apt-get -y install postgresql postgresql-contrib libpq-dev postgresql-client postgresql-client-common

echo "CREATE USER airflow PASSWORD 'airflow'; CREATE DATABASE airflow; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airflow;" | sudo -u postgres psql
sudo -u postgres sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|" /etc/postgresql/*/main/postgresql.conf
sudo -u postgres sed -i "s|127.0.0.1/32|0.0.0.0/0|" /etc/postgresql/*/main/pg_hba.conf
sudo -u postgres sed -i "s|::1/128|::/0|" /etc/postgresql/*/main/pg_hba.conf
service postgresql restart

# installing Redis and setting up the configurations
apt-get -y install redis-server
sed -i "s|bind |#bind |" /etc/redis/redis.conf
sed -i "s|protected-mode yes|protected-mode no|" /etc/redis/redis.conf
sed -i "s|supervised no|supervised systemd|" /etc/redis/redis.conf
service redis restart

# installing python 3.x and dependencies
apt-get -y install python3 python3-dev python3-pip python3-wheel

pip3 install --upgrade pip

pip3 install futures pandas SQLAlchemy psycopg2 celery redis flower flask-bcrypt boto3 ldap3 pymssql

# create airflow user with sudo capability
adduser airflow --gecos "airflow,,," --disabled-password
echo "airflow:airflow" | chpasswd
usermod -aG sudo airflow 
echo "airflow ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# install Airflow
pip3 install "apache-airflow[s3, postgres, rabbitmq, slack, redis, crypto, celery, async]"

# create a persistent variable for AIRFLOW_HOME across all users env
mkdir /opt/airflow
sudo chown airflow /opt/airflow
sudo chgrp airflow /opt/airflow
echo export AIRFLOW_HOME=/opt/airflow > /etc/profile.d/airflow.sh
echo "in airflow user"
#su - airflow 
cd $AIRFLOW_HOME
#ip4addr="$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f7)"
ip4addr="localhost"

AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@$localhost:5432/airflow
export AIRFLOW__CORE__SQL_ALCHEMY_CONN
	postgresql+psycopg2://airflow:airflow@postgres:5432/airflow
echo "set airflow home"
airflow initdb
echo "initdb"
sed -i "s|result_backend = .*|result_backend = db+postgresql://airflow:airflow@localhost/airflow |g" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s|sql_alchemy_conn = .*|sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@$localhost:5432/airflow|g" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s|broker_url = .*|broker_url = redis://localhost:6379/0|g" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s|celery_result_backend = .*|celery_result_backend = redis://redis:6379/0|g" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s|executor = .*|executor = CeleryExecutor|g" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s|load_examples = .*|load_examples = False|g" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s|navbar_color = .*|navbar_color = #296d98|g" "$AIRFLOW_HOME"/airflow.cfg

##Auth
#sed -i "s|authenticate = .*|authenticate = True|g" "$AIRFLOW_HOME"/airflow.cfg
#sed -i "s|auth_backend = .*|auth_backend = airflow.contrib.auth.backends.password_auth|g" "$AIRFLOW_HOME"/airflow.cfg
#sed -i "s|rbac = .*|rbac = True|g" "$AIRFLOW_HOME"/airflow.cfg

airflow initdb
#launch the three airflow processes
echo "Webserver Start"
airflow webserver -D

echo "Scheduler Start"
airflow scheduler -D

echo "Worker Start"
airflow worker -D

