provider "aws" {}

locals {
  # Assign the lambda source code basename as the S3 key
  lambda_s3_key = basename(var.lambda_source_code)

  # Remove the .zip extension to get the lambda function name
  lambda_function_name = trimsuffix(local.lambda_s3_key, ".zip")
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy" "aws_lambda_vpc_access_execution_role" {
  name = "AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_security_group" "lambda" {
  name   = local.lambda_function_name
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4_outbound" {
  security_group_id = aws_security_group.lambda.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "${local.lambda_function_name}-artifacts-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_object" "zip" {
  bucket = aws_s3_bucket.example.bucket
  key    = local.lambda_s3_key
  source = "${path.module}/${var.lambda_source_code}"

  source_hash = filemd5("${path.module}/${var.lambda_source_code}")
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${local.lambda_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachments_exclusive" "aws_lambda_vpc_access_execution_role" {
  role_name   = aws_iam_role.iam_for_lambda.name
  policy_arns = [data.aws_iam_policy.aws_lambda_vpc_access_execution_role.arn]
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 7
}

resource "aws_lambda_function" "test_lambda" {
  function_name = local.lambda_function_name
  s3_bucket     = aws_s3_bucket.example.bucket
  s3_key        = local.lambda_s3_key
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambda_handler

  architectures = [var.lambda_architecture]
  runtime       = var.lambda_runtime

  layers = ["arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${replace(var.lambda_runtime, ".", "")}-${var.lambda_architecture}:2"]

  environment {
    variables = {
      POWERTOOLS_LOG_LEVEL = "INFO"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    subnet_ids         = var.subnet_ids
  }

  lifecycle {
    # Update the lambda function when the zip file changes (rather than using source_code_hash)
    replace_triggered_by = [aws_s3_object.zip]
  }
}
