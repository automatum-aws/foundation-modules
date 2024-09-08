data "archive_file" "delete_default_vpcs_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_code/delete_default_vpc.py"
  output_path = "${path.module}/lambda_code/delete_default_vpc.zip"
}

resource "aws_lambda_function" "delete_default_vpcs_function" {
  function_name = "Delete-Default-VPCs"
  description   = "Remove default VPCs"
  handler       = "delete_default_vpc.handler"
  runtime       = "python3.8"
  memory_size   = 256
  timeout       = 900
  role          = aws_iam_role.delete_default_vpcs_role.arn
  environment {
    variables = {
      ORG_ADMIN_ROLE_NAME = var.org_admin_role_name
      MAIN_ACCOUNT_ID     = data.aws_caller_identity.current.account_id
    }
  }

  filename = "${path.module}/lambda_code/delete_default_vpc.zip"

  tracing_config {
    mode = "Active"
  }

  depends_on = [
    data.archive_file.delete_default_vpcs_lambda_zip
  ]
}

resource "aws_cloudwatch_log_group" "delete_default_vpcs_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.delete_default_vpcs_function.function_name}"
  retention_in_days = 3
}
