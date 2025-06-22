#glue_athena_job.tf
# Define a Glue ETL job that reads data using an Athena query to read from S3, transform data, and write the results back to S3.
resource "aws_glue_job" "athena_etl" {
  name              = var.glue_job_name
  role_arn          = var.glue_role_arn           #gives the Glue job permission to access S3, Athena, Glue Catalog, and logging services.
  glue_version      = "4.0"                       #runtime version for AWS Glue. Version 4.0 supports Python 3, updated libraries, and performance improvements.
  max_capacity      = 2.0                         #Allocates 2 DPUs (Data Processing Units), which roughly equates to two workers
  number_of_workers = null
  worker_type       = "Standard"

#how the ETL job should run
  command {
    name            = "glueetl"                  #sets the job type to Glue ETL
    python_version  = "3"                        #Specifies that the script is written in Python 3.
    script_location = var.script_location        #This script is loaded and executed when the job runs.
  }

  default_arguments = {
    "--TempDir"                              = var.temp_dir_location              #temporary directory in S3 that Glue uses for intermediate data during job execution.
    "--enable-metrics"                       = "true"                             #Enables job-level metrics for better observability in AWS CloudWatch.
    "--enable-continuous-cloudwatch-log"     = "true"                             #Streams logs continuously to CloudWatch for real-time monitoring (instead of waiting for the job to complete).
    "--job-bookmark-option"                  = "job-bookmark-disable"             #each run processes all available data (no incremental loading)
    "--ATHENA_DATABASE"                      = var.glue_db_name
    "--ATHENA_OUTPUT"                        = var.athena_output
    "--CLEAN_QUERY"                         = file("${path.module}/queries/clean.sql")
    "--QUARANTINE_QUERY"                       = file("${path.module}/queries/quarantine.sql")
  }

  tags = {
    Purpose     = "ETL using Athena"
    Environment = var.environment
  }
}
