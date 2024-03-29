name: Pull Request to Staging & Main branches
#on:
 # pull_request:
  #  branches:
   #   - staging
    #  - main

env:
  TERRAFORM_VERSION: 1.1.5
  TERRAGRUNT_VERSION: 0.36.2
  TERRAFORM_WORKING_DIR_TEST: './applied/accounts/testing/environment/'
  TERRAFORM_WORKING_DIR_PROD: './applied/accounts/production/environment/'

concurrency: test-environment    # This will ensure only a single workflow of merge to master is run at a time

jobs:
  apply:
    name: "Terragrunt Apply"
    #if: ${{ github.ref == 'staging'}}
    if: github.base_ref == 'staging'
    runs-on: ubuntu-20.04
    #environment: apply-testing
    defaults:
      run:
        working-directory: ${{ env.TERRAFORM_WORKING_DIR_TEST }}
    steps:
      - name: 'checkout'
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1.3.2
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}
          terraform_wrapper: true

      - name: Setup Terragrunt
        uses: autero1/action-terragrunt@v1.1.0
        with:
          terragrunt_version: ${{ env.TERRAGRUNT_VERSION }}

      - name: configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1.6.1
        with:
          aws-region: us-east-1
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terragrunt Init
        id: init
        run : terragrunt run-all init -no-color --terragrunt-non-interactive

      - name: Terragrunt Apply
        id: apply
        run: terragrunt run-all apply -no-color --terragrunt-non-interactive
        continue-on-error: true

  plan:
    name: "Run Terragrunt plan in production environment"
    #if: ${{ github.head_ref == 'main'}}
    if: github.base_ref == 'main'
    runs-on: ubuntu-20.04
    defaults:
       run:
        working-directory: ${{ env.TERRAFORM_WORKING_DIR_PROD }}
    steps:
      - name: 'checkout'   
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1.3.2
        with:
          terragrunt_version: ${{ env.TERRAGRUNT_VERSION }} 

      - name: Setup Terragrunt
        uses: autero1/action-terragrunt@v1.1.0
        with:
          terragrunt_version: ${{ env.TERRAGRUNT_VERSION }}

      - name: configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1.6.1
        with: 
          aws-region: us-east-1
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terragrunt Init
        id: init
        run: terragrunt run-all init -no-color --terragrunt-non-interactive

      - name: Terragrunt Plan
        id: plan
        run: terragrunt run-all plan -no-color --terragrunt-non-interactive
