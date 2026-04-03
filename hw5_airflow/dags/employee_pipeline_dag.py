from datetime import datetime, timedelta

from airflow.sdk import DAG, literal
from airflow.providers.standard.operators.bash import BashOperator

default_args = {
    "owner": "Vedant Gupta",
    "depends_on_past": False,
    "email_on_failure": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="employee_pipeline_dag",
    description="Employee data pipeline: ingestion, cleaning, and gold transformations",
    default_args=default_args,
    start_date=datetime(2026, 4, 3),
    schedule="@daily",
    catchup=False,
    tags=["airflow", "csds397", "hw5"],
) as dag:

    ingest_data = BashOperator(
        task_id="ingest_data",
        bash_command=literal("bash /Users/vedantgupta/Desktop/CSDS397_HW2/hw5_airflow/scripts/ingest_data.sh"),
    )

    clean_and_normalize = BashOperator(
        task_id="clean_and_normalize",
        bash_command=literal("bash /Users/vedantgupta/Desktop/CSDS397_HW2/hw5_airflow/scripts/clean_and_normalize.sh"),
    )

    salary_to_department_analysis = BashOperator(
        task_id="salary_to_department_analysis",
        bash_command=literal("bash /Users/vedantgupta/Desktop/CSDS397_HW2/hw5_airflow/scripts/run_salary_to_department.sh"),
    )

    salary_to_tenure_analysis = BashOperator(
        task_id="salary_to_tenure_analysis",
        bash_command=literal("bash /Users/vedantgupta/Desktop/CSDS397_HW2/hw5_airflow/scripts/run_salary_to_tenure.sh"),
    )

    performance_by_salary_analysis = BashOperator(
        task_id="performance_by_salary_analysis",
        bash_command=literal("bash /Users/vedantgupta/Desktop/CSDS397_HW2/hw5_airflow/scripts/run_performance_by_salary.sh"),
    )

    salary_to_country_analysis = BashOperator(
        task_id="salary_to_country_analysis",
        bash_command=literal("bash /Users/vedantgupta/Desktop/CSDS397_HW2/hw5_airflow/scripts/run_salary_to_country.sh"),
    )

    sales_to_salary_analysis = BashOperator(
        task_id="sales_to_salary_analysis",
        bash_command=literal("bash /Users/vedantgupta/Desktop/CSDS397_HW2/hw5_airflow/scripts/run_sales_to_salary.sh"),
    )

    support_rating_to_salary_analysis = BashOperator(
        task_id="support_rating_to_salary_analysis",
        bash_command=literal("bash /Users/vedantgupta/Desktop/CSDS397_HW2/hw5_airflow/scripts/run_support_rating_to_salary.sh"),
    )

    ingest_data >> clean_and_normalize >> [
        salary_to_department_analysis,
        salary_to_tenure_analysis,
        performance_by_salary_analysis,
        salary_to_country_analysis,
        sales_to_salary_analysis,
        support_rating_to_salary_analysis,
    ]
