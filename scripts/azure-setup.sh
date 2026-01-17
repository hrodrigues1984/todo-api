#!/bin/bash
# Azure Infrastructure Setup for DevSecOps Pipeline
# This script creates the necessary Azure resources and configures OIDC federation

set -e

# ==============================================================================
# CONFIGURATION - Update these values for your environment
# ==============================================================================
export APP_NAME="todo-api-pipeline"
export RG_NAME="rg-todo-prod-001"
export ACR_NAME="acrtodo001"
export LOCATION="northeurope"
export GITHUB_ORG="hrodrigues1984"
export GITHUB_REPO="todo-api"

# ==============================================================================
# RESOURCE CREATION
# ==============================================================================

echo "Creating Resource Group..."
az group create --name $RG_NAME --location $LOCATION

echo "Creating Azure Container Registry (Basic SKU)..."
az acr create \
  --resource-group $RG_NAME \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled false

echo "Getting or Creating App Registration..."
APP_ID=$(az ad app list --display-name $APP_NAME --query "[0].appId" -o tsv)
if [ -z "$APP_ID" ]; then
  APP_ID=$(az ad app create --display-name $APP_NAME --query appId -o tsv)
  echo "Created new App Registration: $APP_ID"
else
  echo "Using existing App Registration: $APP_ID"
fi

echo "Getting or Creating Service Principal..."
SP_EXISTS=$(az ad sp list --filter "appId eq '$APP_ID'" --query "[0].id" -o tsv)
if [ -z "$SP_EXISTS" ]; then
  SP_ID=$(az ad sp create --id $APP_ID --query id -o tsv)
  echo "Created new Service Principal: $SP_ID"
else
  echo "Using existing Service Principal: $SP_EXISTS"
fi

# ==============================================================================
# ROLE ASSIGNMENT
# ==============================================================================

echo "Assigning AcrPush role..."
ACR_ID=$(az acr show --name $ACR_NAME --resource-group $RG_NAME --query "id" -o tsv)

az role assignment create \
  --assignee $APP_ID \
  --role AcrPush \
  --scope $ACR_ID

# ==============================================================================
# FEDERATED IDENTITY CREDENTIALS
# ==============================================================================

echo "Creating Federated Credential for main branch..."
az ad app federated-credential create \
  --id $APP_ID \
  --parameters "{
    \"name\":\"github-actions-main-branch\",
    \"issuer\":\"https://token.actions.githubusercontent.com\",
    \"subject\":\"repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/main\",
    \"description\":\"Authorize GitHub Actions to deploy from main branch\",
    \"audiences\":[\"api://AzureADTokenExchange\"]
  }" 2>/dev/null || echo "Federated credential for main branch already exists, skipping."

echo "Creating Federated Credential for pull requests..."
az ad app federated-credential create \
  --id $APP_ID \
  --parameters "{
    \"name\":\"github-actions-pull-request\",
    \"issuer\":\"https://token.actions.githubusercontent.com\",
    \"subject\":\"repo:$GITHUB_ORG/$GITHUB_REPO:pull_request\",
    \"description\":\"Authorize GitHub Actions for PR checks\",
    \"audiences\":[\"api://AzureADTokenExchange\"]
  }" 2>/dev/null || echo "Federated credential for pull requests already exists, skipping."

# ==============================================================================
# OUTPUT
# ==============================================================================

TENANT_ID=$(az account show --query tenantId -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo ""
echo "=============================================="
echo "SETUP COMPLETE - Add these to GitHub Secrets:"
echo "=============================================="
echo "AZURE_CLIENT_ID: $APP_ID"
echo "AZURE_TENANT_ID: $TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo ""
echo "Add this to GitHub Variables:"
echo "ACR_NAME: $ACR_NAME"
echo "=============================================="
