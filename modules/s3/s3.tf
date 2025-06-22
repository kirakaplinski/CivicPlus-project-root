#s3.tf
# Create an S3 bucket to store source data, results, scripts, and Athena outputs
resource "aws_s3_bucket" "data_lake" {
  bucket = var.bucket_name

  tags = {
    Name        = var.tag_name        # Logical name to identify this data lake
    Environment = var.environment     # Tag for environment separation (e.g., dev, prod)
  }
}
