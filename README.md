# TechCorp AWS Infrastructure

## Prerequisites
- Terraform installed
- AWS CLI installed and configured
- AWS account with appropriate permissions
- An existing AWS Key Pair created in eu-west-1

# Setup
1. Clone the repository
2. Copy terraform.tfvars.example to terraform.tfvars
3. Fill in your actual values in terraform.tfvars

# Deployment Steps

1. Initialize Terraform:
   terraform init

2. Preview the infrastructure:
   terraform plan

3. Deploy the infrastructure:
   terraform apply
   Type yes when prompted.

# Cleanup
To destroy all created resources:
   terraform destroy