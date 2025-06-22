#iam.tf
# IAM role for AWS Glue to assume during job or crawler execution
resource "aws_iam_role" "glue_exec_role" {
  name = var.glue_role_name

  assume_role_policy = jsonencode({                          #defines an IAM trust policy in Terraform and encodes it as a JSON string using jsonencode
    Version = "2012-10-17",                                  #Specifies the policy language version. "2012-10-17" is the current standard.
    Statement = [{
      Effect = "Allow",                                      #Permits the action
      Principal = {
        Service = "glue.amazonaws.com"   # Allow Glue service to assume this role
      },
      Action = "sts:AssumeRole"          #Grants permission for Glue to assume this IAM role using AWS Security Token Service (STS).
    }]
  })
}

# Attach AWS-managed Glue policy for default permissions 
# that ensure Glue jobs can assume the role and perform standard operations:to run jobs, access S3, interact with the Glue Catalog, and log to CloudWatch.
resource "aws_iam_role_policy_attachment" "glue_policy" {
  role       = aws_iam_role.glue_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Output the Amazon Resource Name (ARN) of the Glue execution role so other modules can use it
output "glue_role_arn" {
  value = aws_iam_role.glue_exec_role.arn
}
