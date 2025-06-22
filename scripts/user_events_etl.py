import boto3                       #AWS Software Development Kit (SDK) for Python to interact with S3.
import time                        #Enables time-based logic, like polling Athena query status
import sys                         #Needed to access command-line arguments.
import logging                     #Enables status messages to CloudWatch Logs.
from awsglue.utils import getResolvedOptions          #AWS Glue function to parse job arguments.

# Configure logging to record progress and errors to CloudWatch.
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Parse arguments passed into the job
args = getResolvedOptions(sys.argv, [
    'ATHENA_DATABASE',
    'ATHENA_OUTPUT',
    'CLEAN_QUERY',
    'QUARANTINE_QUERY'
])

# Create AWS clients for Athena and S3
athena = boto3.client('athena')                      #initializes a boto3 client for Amazon Athena, enabling the Python script to interact with the Athena service

#Function runs a SQL query in Athena and waits for completion using a polling loop. 
#If the query fails or gets cancelled, it raises an exception. If it succeeds, it logs that success and returns quietly.
def run_query(sql, output_location, label):
    logger.info(f"Running {label} query...")
    response = athena.start_query_execution(
        QueryString=sql,
        QueryExecutionContext={'Database': args['ATHENA_DATABASE']},
        ResultConfiguration={'OutputLocation': output_location}
    )

    exec_id = response['QueryExecutionId']
    while True:
        status = athena.get_query_execution(QueryExecutionId=exec_id)['QueryExecution']['Status']['State']
        if status in ['SUCCEEDED', 'FAILED', 'CANCELLED']:
            break
        time.sleep(2)            #This loop checks the status every 2 seconds until the query finishes.

    if status != 'SUCCEEDED':
        raise Exception(f"{label} query failed with status: {status}")
    logger.info(f"{label} query completed successfully: {exec_id}")

# Execute both queries
run_query(args['CLEAN_QUERY'], args['ATHENA_OUTPUT'] + "clean/", "Clean dataset")
run_query(args['QUARANTINE_QUERY'], args['ATHENA_OUTPUT'] + "quarantine/", "Quarantine dataset")
