#variables.tf
# AWS region to deploy resources into
variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region for provisioning infrastructure"
}

# S3 bucket name that stores raw data, results, scripts, and Athena outputs
variable "bucket_name" {
  default     = "user-events-data-lake"
  description = "Primary S3 bucket for all data and script storage"
}

# Environment label for tagging resources (e.g., dev, stage, prod)
variable "environment" {
  default     = "dev"
  description = "Environment identifier for tagging and resource isolation"
}

# Tag to identify the data lake in resource management
variable "tag_name" {
  default     = "user-event-data-lake"
  description = "Logical name tag assigned to the S3 bucket"
}

# IAM role name for Glue services
variable "glue_role_name" {
  default     = "glue_exec_role"
  description = "Name of the IAM role assumed by Glue job and crawler"
}

# Name of the Glue Data Catalog database
variable "glue_db_name" {
  default     = "user_event_db"
  description = "Glue catalog database name to store table schemas"
}

# Name assigned to the Glue crawler
variable "crawler_name" {
  default     = "user_event_crawler"
  description = "Name of the Glue crawler that processes input data"
}

# Folder path inside S3 bucket for raw files
variable "source_prefix" {
  default     = "source/"
  description = "Prefix in the S3 bucket for raw CSV input"
}

# Folder path inside S3 bucket for output results
variable "output_prefix" {
  default     = "output/"
  description = "Prefix in the S3 bucket for cleaned or transformed data"
}

# Location of the Python ETL script in S3
variable "script_location" {
  default     = "s3://user-events-data-lake/scripts/user_events_etl.py"
  description = "S3 path to the Python Glue job script"
}

# Temporary working directory for Glue jobs
variable "temp_dir_location" {
  default     = "s3://user-events-data-lake/temp/"
  description = "Temporary directory path for Glue job intermediate data"
}

# Athena results folder to store query execution results
variable "athena_output" {
  default     = "s3://user-events-data-lake/athena-results/"
  description = "S3 output location for Athena query results"
}


# Name for the Glue job that runs the Python ETL script
variable "glue_job_name" {
  default     = "user_event_athena_etl"
  description = "Name of the Glue job that processes data via Athena"
}
