# Glue Catalog Database to organize table metadata like schema, format, location, and partitioning. 
# It acts as a logical container for tables discovered by crawlers or created manually.
resource "aws_glue_catalog_database" "glue_db" {
  name = var.glue_db_name
}

# Crawler that scans source data to create and update Glue tables
resource "aws_glue_crawler" "crawler" {
  name          = var.crawler_name
  database_name = aws_glue_catalog_database.glue_db.name
  role          = var.glue_role_arn             #grants Glue permissions to access S3 and write metadata.

#By including both source and output paths, the crawler keeps the Glue Catalog synchronized with both raw and processed datasets
  targets {
    s3_targets {
      path = "s3://${var.bucket_name}/${var.source_prefix}"   # Scan source folder
    }
    s3_targets {
      path = "s3://${var.bucket_name}/${var.output_prefix}"   # Scan output folder
    }
  }
}
