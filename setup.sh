#!/bin/bash

set -e

echo "========================================="
echo "Beyond Mumbai - EKS Deployment Setup"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo -e "${RED}AWS CLI is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is required but not installed. Aborting.${NC}" >&2; exit 1; }

echo -e "${GREEN}All prerequisites met!${NC}"

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}

echo -e "${YELLOW}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${YELLOW}AWS Region: ${AWS_REGION}${NC}"

# Create S3 bucket for Terraform state
echo -e "${YELLOW}Creating S3 bucket for Terraform state...${NC}"
BUCKET_NAME="beyond-mumbai-terraform-state"

if aws s3 ls "s3://${BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb "s3://${BUCKET_NAME}" --region ${AWS_REGION}
    aws s3api put-bucket-versioning --bucket ${BUCKET_NAME} --versioning-configuration Status=Enabled
    echo -e "${GREEN}S3 bucket created successfully${NC}"
else
    echo -e "${GREEN}S3 bucket already exists${NC}"
fi

# Create DynamoDB table for state locking
# echo -e "${YELLOW}Creating DynamoDB table for state locking...${NC}"
# TABLE_NAME="terraform-state-lock"

# if ! aws dynamodb describe-table --table-name ${TABLE_NAME} --region ${AWS_REGION} >/dev/null 2>&1; then
#     aws dynamodb create-table \
#         --table-name ${TABLE_NAME} \
#         --attribute-definitions AttributeName=LockID,AttributeType=S \
#         --key-schema AttributeName=LockID,KeyType=HASH \
#         --billing-mode PAY_PER_REQUEST \
#         --region ${AWS_REGION}
#     echo -e "${GREEN}DynamoDB table created successfully${NC}"
# else
#     echo -e "${GREEN}DynamoDB table already exists${NC}"
# fi

# Initialize and apply Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
cd terraform
terraform init

echo -e "${YELLOW}Planning Terraform changes...${NC}"
terraform plan -out=tfplan

read -p "Do you want to apply the Terraform plan? (yes/no): " APPLY_TERRAFORM

if [ "$APPLY_TERRAFORM" == "yes" ]; then
    echo -e "${YELLOW}Applying Terraform...${NC}"
    terraform apply tfplan
    
    # Get outputs
    ECR_REPO=$(terraform output -raw ecr_repository_url)
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    
    echo -e "${GREEN}Terraform applied successfully!${NC}"
    echo -e "${GREEN}ECR Repository: ${ECR_REPO}${NC}"
    echo -e "${GREEN}EKS Cluster: ${CLUSTER_NAME}${NC}"
    
    # Configure kubectl
    echo -e "${YELLOW}Configuring kubectl...${NC}"
    aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
    
    echo -e "${GREEN}kubectl configured successfully!${NC}"
    
    # Save Jenkins credentials
    echo -e "${YELLOW}Saving Jenkins credentials...${NC}"
    mkdir -p ../jenkins-credentials
    terraform output -raw jenkins_access_key_id > ../jenkins-credentials/access_key_id
    terraform output -raw jenkins_secret_access_key > ../jenkins-credentials/secret_access_key
    echo ${AWS_ACCOUNT_ID} > ../jenkins-credentials/account_id
    
    echo -e "${GREEN}Jenkins credentials saved in jenkins-credentials/ directory${NC}"
    
    cd ..
    
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Configure Jenkins with the credentials in jenkins-credentials/"
    echo "2. Create a Jenkins pipeline job pointing to your repository"
    echo "3. Run the pipeline to deploy your application"
    echo ""
    echo -e "${YELLOW}Useful commands:${NC}"
    echo "  kubectl get nodes"
    echo "  kubectl get pods -n default"
    echo "  kubectl get svc -n default"
else
    echo -e "${YELLOW}Terraform apply skipped${NC}"
    cd ..
fi
