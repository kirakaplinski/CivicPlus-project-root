# ETL with AWS Glue, Athena, and Terraform

This project provisions a fully ETL pipeline on AWS using Terraform and Athena-based Glue Job. 
 It reads CSV data from S3, calculates lag time between user events, validates records, and stores both clean and  quarantined datasets back into S3.

Provisions:
  - A single S3 data lake bucket with `source/`, `output/`, `scripts/`, and `athena-results/` folders
  - A Glue Catalog database and crawler to classify input data
  - An IAM role with permission for Glue, S3, and Athena
  - A Glue ETL job that:
    - Executes two SQL queries via Athena (clean + quarantine)
    - Calculates lag time using SQL window functions
    - Writes partitioned results directly into S3

Deployment Steps
1. Create the S3 bucket manually or let Terraform do it.
   This bucket will hold the source data, job scripts, and transformed output.
2. Upload  Glue job script (user_events_etl.py) to scripts/
3. Upload  user_events.csv into source/ to enable the Glue crawler to discover and catalog the schema.
4. Run terraform init && terraform apply
   (initializes Terraform configuration and Provisions all defined AWS resources (e.g. Glue database, IAM roles, job, crawler, etc.).
5. Trigger the Glue crawler to generate the Glue table
6. Trigger the Glue job to run the SQL ETL (manual through the console or via schedule):
7. 
   Manually via the AWS Console (for testing)
         - Go to the AWS Glue Console.
         - Navigate to Jobs.
         - Select the job user_event_athena_etl and click Run.
         - Monitor logs in CloudWatch Logs for eal-time progress.
   
   Scheduled via AWS Glue Triggers (for production)
          - Create a Glue trigger (time-based or event-based).
          - Link it to  ETL job.
          - Set up a schedule like “every day at midnight” or “whenever new data lands in S3.”

Output
Transformed data with lag time → s3://<bucket>/output/clean/transformed_events.csv

Bad/invalid records → s3://<bucket>/output/quarantine/bad_records.csv

Queries
Defined in glue_athena_job/queries/:

clean.sql: Filters nulls, validates event types, calculates lag time
quarantine.sql: Selects rows with missing values or invalid types

Assumptions
 - Glue crawler has run at least once before the Glue job
 - user_events table exists in Athena via the Glue catalog

