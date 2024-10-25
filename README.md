# Lambda Deployment (Python)

This repository demonstrates how to deploy a Python Lambda function with dependencies. It adds a Lambda layer for AWS Lambda Powertools, and includes a dependency on [pendulum](https://pendulum.eustace.io/).

## Usage

Run the following to deploy the function to AWS.

```sh
make # create local virtual environment
make coverage # test locally
make build # bundle the code into a zip file
cp infra/terraform.tfvars.example infra/terraform.tfvars
# (fill out terraform.tfvars as appropriate)
# (configure AWS authentication)
terraform -chdir=infra init
terraform -chdir=infra apply
```
