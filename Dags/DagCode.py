# ****************************************
# DAG Dinamica - Configuracao arquivo.yml
# Dag para executar processos
# Dummy, Bash, Python, Streamsets
# Necessário editar o YML file
# ****************************************
# Importando as bibliotecas

from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta
import yaml
import requests
import sys


def streamsets(vCod):
    headers = {
        'X-Requested-By': 'sdc',
    }
    response = requests.post('http://localhost:18630/rest/v1/pipeline/'+vCod+'/start',
    headers=headers, auth=('admin', 'admin'))
    return headers


dagConfig = yaml.safe_load(open('/usr/local/airflow/dags/config/exemplo.yml').read())

def represent_none(self, _):
    return self.represent_scalar('tag:yaml.org,2002:null', '')

yaml.add_representer(type(None), represent_none)

default_args = {
    'owner': 'diego',
    'depends_on_past': True,
    'retries': 0
}

dag = DAG(dagConfig['dagname'],
          description=dagConfig['description'],
          schedule_interval=dagConfig['schedule_interval'],
          start_date=datetime(2020, 5, 13),
          default_args=default_args,
          catchup=False)

retry_delay=timedelta(minutes=1)

tasks = {}

start = DummyOperator(task_id='start', dag=dag)
tasks['start'] = start

for job, jobtasks in dagConfig["etlflow"].items():
    for task, task_properties in jobtasks.items():

        if task_properties['tasktype'] == 'DummyOperator':
            operator_task = DummyOperator(
                task_id = task_properties['task_id']
            )        
        elif task_properties['tasktype'] == 'BashOperator':
            operator_task = BashOperator(
                task_id = task_properties['task_id'],
                bash_command = task_properties['command'],
                retries=task_properties['retries'],
                retry_delay=retry_delay
            )
        elif task_properties['tasktype'] == 'PythonOperator':        
            operator_task = PythonOperator(
                task_id = task_properties['task_id'],
                python_callable = task_properties['command'],
                op_args = task_properties['op_args'],
                retries=task_properties['retries'],
                retry_delay=retry_delay
            )
        elif task_properties['tasktype'] == 'StreamSets':
            operator_task = PythonOperator(
                task_id = task_properties['task_id'],
                python_callable = streamsets,
                op_args = task_properties['op_args'],
                retries=task_properties['retries'],
                retry_delay=retry_delay
            )
        else:
            print('Operador Invalido!')
            
        tasks[task_properties['task_id']] = operator_task

        if task_properties['depends_on_task'] != None:
            tasksDepends = task_properties['depends_on_task']
            for taskDepends in tasksDepends:
                operator_task.set_upstream(tasks[taskDepends])
        else:
            operator_task.set_upstream(start)