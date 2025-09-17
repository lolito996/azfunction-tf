#!/bin/bash

# Terraform Deployment Script
# Usage: ./scripts/deploy.sh [environment] [action]
# Example: ./scripts/deploy.sh dev plan

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment is provided
if [ $# -lt 1 ]; then
    print_error "Usage: $0 <environment> [action]"
    print_error "Environments: dev, staging, prod"
    print_error "Actions: plan, apply, destroy (default: plan)"
    exit 1
fi

ENVIRONMENT=$1
ACTION=${2:-plan}
TFVARS_FILE="${ENVIRONMENT}.tfvars"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    print_error "Valid environments: dev, staging, prod"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    print_error "Invalid action: $ACTION"
    print_error "Valid actions: plan, apply, destroy"
    exit 1
fi

# Check if tfvars file exists
if [ ! -f "$TFVARS_FILE" ]; then
    print_error "Configuration file not found: $TFVARS_FILE"
    exit 1
fi

print_status "Starting Terraform $ACTION for environment: $ENVIRONMENT"

# Check if Azure CLI is installed and user is logged in
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Validate configuration
print_status "Validating Terraform configuration..."
terraform validate

# Format check
print_status "Checking Terraform formatting..."
if ! terraform fmt -check; then
    print_warning "Terraform files are not properly formatted."
    print_warning "Run 'terraform fmt' to fix formatting issues."
fi

# Run the specified action
case $ACTION in
    plan)
        print_status "Running Terraform plan..."
        terraform plan -var-file="$TFVARS_FILE" -out=tfplan
        print_status "Plan completed successfully!"
        ;;
    apply)
        print_warning "This will apply changes to the $ENVIRONMENT environment."
        read -p "Are you sure you want to continue? (yes/no): " confirm
        if [[ $confirm == "yes" ]]; then
            print_status "Running Terraform apply..."
            terraform apply -var-file="$TFVARS_FILE" -auto-approve
            print_status "Apply completed successfully!"
        else
            print_status "Apply cancelled by user."
        fi
        ;;
    destroy)
        print_error "This will DESTROY all resources in the $ENVIRONMENT environment!"
        read -p "Are you absolutely sure? Type 'yes' to confirm: " confirm
        if [[ $confirm == "yes" ]]; then
            print_status "Running Terraform destroy..."
            terraform destroy -var-file="$TFVARS_FILE" -auto-approve
            print_status "Destroy completed successfully!"
        else
            print_status "Destroy cancelled by user."
        fi
        ;;
esac

print_status "Script completed successfully!"
