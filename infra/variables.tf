variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "lambda_source_code" {
  type    = string
  default = "../dist/my-lambda.zip"
}

variable "lambda_handler" {
  type    = string
  default = "example.lambda_function.lambda_handler"
}

variable "lambda_architecture" {
  type    = string
  default = "x86_64"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.12"
}
