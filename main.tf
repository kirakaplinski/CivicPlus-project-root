#main.tf
# Set up AWS provider and region
provider "aws" {
  region = var.aws_region  # AWS region to deploy resources (e.g., us-east-1) Defined in variables.tf
}

# Create a single S3 bucket to store scripts, source data, output results, and Athena logs
module "s3" {
  source      = "./modules/s3"         # Module path for provisioning S3
  bucket_name = var.bucket_name        # S3 bucket name from variables.tf
  environment = var.environment        # Tag to identify environment Dev / staging / prod etc.
  tag_name    = var.tag_name           # Logical tag name for the bucket
}

# Set up IAM role and policy attachment for Glue crawler and ETL jobs
module "iam" {
  source            = "./modules/iam"          # Path to IAM module
  glue_job_rolename = var.glue_role_name       # Role name that Glue will assume
}

# Deploy Glue resources database and crawler to scan source and output locations
module "glue" {
  source           = "./modules/glue"                  # Folder where Glue definitions are stored
  glue_db_name     = var.glue_db_name                  # Catalog database name
  crawler_name     = var.crawler_name                  # Name of the Glue crawler
  glue_role_arn    = module.iam.glue_role_arn          # IAM role ARN output from iam module
  bucket_name      = var.bucket_name                   # S3 bucket containing source/output data
  source_prefix    = var.source_prefix                 # Folder prefix for raw input data
  output_prefix    = var.output_prefix                 # Folder prefix for transformed output
}

# Deploy Glue ETL job that reads data from Athena and writes processed results to S3
module "glue_athena_job" {
  source              = "./modules/glue_athena_job"    # Module path for Glue Athena job
  glue_job_name       = var.glue_job_name              # Name of the Glue job
  glue_role_arn       = module.iam.glue_role_arn       # IAM role ARN output from iam module
  script_location     = var.script_location            # Path to Glue Python script in S3
  temp_dir_location   = var.temp_dir_location          # Scratch space required by Glue
  athena_db           = var.glue_db_name               # Glue/Athena catalog database
  athena_output       = var.athena_output              # S3 location to write Athena query results
  athena_query        = var.athena_query               # SQL query used to fetch records
  output_s3_path      = var.output_s3_path             # Final location to write transformed results
}
