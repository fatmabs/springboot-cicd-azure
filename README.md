# Spring Boot CI/CD on Azure

![Azure](https://img.shields.io/badge/Azure-Cloud-blue)
 [!IMPORTANT]
 [!WARNING]

<p align="center">
  <strong>Spring Boot • Docker • Terraform • Azure • GitHub Actions • OIDC</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Azure-Cloud-blue" alt="Azure">
  <img src="https://img.shields.io/badge/Terraform-IaC-purple" alt="Terraform">
  <img src="https://img.shields.io/badge/Docker-Container-blue" alt="Docker">
  <img src="https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-black" alt="GitHub Actions">
  <img src="https://img.shields.io/badge/Spring%20Boot-Application-green" alt="Spring Boot">
</p>

## 1. Project Overview

This project demonstrates the implementation of a complete CI/CD pipeline for a containerized Spring Boot application deployed on Microsoft Azure.

The infrastructure is provisioned using Terraform and the application is containerized using Docker.

When a developer pushes code to a feature branch, GitHub Actions automatically builds and tests the Spring Boot application. 
Pull Requests targeting main trigger another validation. After the changes are merged into main, the CD workflow builds the Docker image, pushes it to Azure Container Registry and deploys the application to Azure.

GitHub Actions is used to automate:

- Application build and testing
- Docker image creation
- Docker image publishing to Azure Container Registry
- Deployment to Azure App Service

Authentication between GitHub Actions and Azure uses OpenID Connect (OIDC)
with Microsoft Entra ID and a Federated Identity Credential.

No Azure client secret is stored in GitHub.

## 2. Architecture

The project follows the architecture below:

```text
                         GitHub Repository
                               │
                               │
                ┌──────────────┴──────────────┐
                │                             │
                ▼                             ▼
          CI — ci.yml                  CD — cd.yml
                │                             │
                ▼                             ▼
        Maven Build & Tests           Azure OIDC Login
                                              │
                                              ▼
                                       Docker Build
                                              │
                                              ▼
                                  Azure Container Registry
                                              │
                                              ▼
                                     Azure App Service
                                              │
                                              ▼
                                     Spring Boot API


## 3. Azure Authentication

GitHub Actions does not use an Azure client secret.

The authentication flow is:
---------------------------------------
GitHub Actions
      │
      │ OIDC token
      ▼
Microsoft Entra ID
      │
      │ Federated Identity Credential
      ▼
Service Principal
      │
      │ Azure RBAC
      ▼
Azure Resources
----------------------------------------
The GitHub Actions workflow requests an OIDC token.
Microsoft Entra ID verifies the token against the Federated Identity
Credential configured for the repository and branch.

## 4. Technologies
| Technology               | Purpose                       |
|--------------------------|-------------------------------|
| Java 17                  | Application runtime and build |
|--------------------------|-------------------------------|
| Spring Boot              | REST API                      |
|--------------------------|-------------------------------|
| Maven                    | Application build and tests   |
|--------------------------|-------------------------------|
| Docker                   | Application containerization  |
|--------------------------|-------------------------------|
| Terraform                | Infrastructure as Code        |
|--------------------------|-------------------------------|
| Azure Resource Group     | Resource organization         |
|--------------------------|-------------------------------|
| Azure Container Registry | Docker image registry         |
|--------------------------|-------------------------------|
| Azure App Service        | Application hosting           |
|--------------------------|-------------------------------|
| Microsoft Entra ID       | Identity and authentication   |
|--------------------------|-------------------------------|
| OIDC                     | GitHub-to-Azure federation    |
|--------------------------|-------------------------------|
| Azure RBAC               | Authorization                 |
|--------------------------|-------------------------------|
| GitHub Actions           | CI/CD automation              |
|--------------------------|-------------------------------|
| Git                      | Version control               |
|--------------------------|-------------------------------|
```
## 5. Repository Structure

springboot-cicd-azure/
│
├── app/
│   ├── src/
│   ├── pom.xml
│   ├── mvnw
│   ├── mvnw.cmd
│   └── Dockerfile
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── ...
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── cd.yml
│
├── .gitignore
└── README.md

```
```
## 6. Azure infrastructure

Terraform provisions the following resources:

- Azure Resource Group
- Azure Container Registry
- Azure App Service Plan
- Linux App Service
- System-assigned managed identity
- AcrPull role assignment

Resource Group
│
├── Azure Container Registry
│       │
│       └── hello-api:latest
│
└── App Service Plan
        │
        └── Linux Web App
                │
                └── System Assigned Identity
                        │
                        └── AcrPull

## 7. Deploy Infrastructure with Terraform

```bash
cd terraform
Initialize Terraform:
terraform init
Validate the configuration:
terraform validate
Review the execution plan:
terraform plan
Apply the infrastructure:
terraform apply
```
## 8. Entra application and service principal
GitHub Actions authenticates to Azure using:

- Microsoft Entra application
- Service principal
- Federated identity credential
- GitHub OIDC

-app creation 
az ad app create \
  --display-name "github-actions-springboot"
  
-service principal creation
az ad sp create \
  --id <CLIENT_ID>
  
CLIENT_ID = Application (client) ID

## 9. Configure GitHub OIDC Federation
he Federated Identity Credential establishes trust between GitHub Actions
and the Microsoft Entra application.

The credential contains three critical values:

- Issuer
- Subject
- Audience
  example:
  {
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<OWNER>/<REPOSITORY>:ref:refs/heads/main",
  "description": "GitHub Actions OIDC federation for main branch",
  "audiences": [ "api://AzureADTokenExchange"   ]
  }

  az ad app federated-credential create \
  --id "<CLIENT_ID>" \
  --parameters @federated-credential.json

  az ad app federated-credential list \
  --id "<CLIENT_ID>" \
  -o json

note:  The `federated-credential.json` file is ignored by Git and should not
contain passwords or secrets.

The important configuration is stored in Microsoft Entra ID.

## 10. Azure RBAC
the app service identity needs "ArcPull" on ACR 
The `AcrPull` role allows the App Service to pull the Docker image from Azure Container Registry without storing registry credentials.

## 11. GitHub variables
 GitHub-repository -> settings -> secrets and variables -> Actions -> Variables -> Repository variables -> New repository variable
 AZURE_CLIENT_ID
 AZURE_TENANT_ID
 AZURE_SUBSCRIPTION_ID


## 12. Continuous Integration CI
The CI workflow is responsible for validating the application.
File:
`.github/workflows/ci.yml`

Flow :
    Push / Pull Request
            ↓
    Checkout
            ↓
    Java 17
            ↓
    Maven
            ↓
    Build
            ↓
    Tests

The Maven project is located in `app/`, therefore the workflow uses:
`working-directory: ./app`

## 13. Continuous Deployment CD
The CD workflow is responsible for deploying the application to Azure.
File:
`.github/workflows/cd.yml`

Flow:
    main
     │
     ▼
    Azure OIDC Login
     │
     ▼
    Maven Package
     │
     ▼
    Docker Build
     │
     ▼
    ACR Login
     │
     ▼
    Docker Push
     │
     ▼
    Azure Container Registry
     │
     ▼
    Azure App Service

The CD workflow builds the JAR before building the Docker image because the Dockerfile copies the generated JAR from:

`app/target/*.jar`

The CI and CD workflows run independently, so files created during CI are not automatically present in CD.


## 14. Docker

The application is packaged into a Docker image.

The Dockerfile:

1. Uses Eclipse Temurin Java 17
2. Creates the `/app` working directory
3. Copies the generated Spring Boot JAR
4. Exposes port 8080
5. Starts the application

then :
  docker build -t hello-api:latest ./app
run locally:
  docker run -p 8080:8080 hello-api:latest
test:
  http://localhost:8080

## 15. ACR
myprojectacr123.azurecr.io/hello-api:latest
   myprojectacr123.azurecr.io
            │
            └── ACR registry
            
    hello-api
            │
            └── repository
    
    latest
            │
            └── image tag

Login to Azure Container Registry:            
    az acr login --name myprojectacr123
    
Build Docker image:
    docker build \
      -t myprojectacr123.azurecr.io/hello-api:latest \
      ./app

Push Docker image to ACR
    docker push \
      myprojectacr123.azurecr.io/hello-api:latest

## 16. Azure App Service
The application runs as a Linux container in Azure App Service.

The Spring Boot application listens on port `8080`.

Therefore App Service is configured with:
```hcl:
app_settings = {
  WEBSITES_PORT = "8080"
}
```

## 17. Git Workflow
feature/hello-api
       │
       ▼
      CI
       │
       ▼
Pull Request
       │
       ▼
      main
       │
       ▼
      CD
       │
       ▼
     Azure
     
-the commands used:
git checkout -b feature/hello-api

git add .

git commit -m "feat: ..."

git push origin feature/hello-api

then: PR (Pull Request) -> main

-If remote changes exist:

git fetch

git rebase origin/feature/hello-api

git push origin feature/hello-api

## 18. Lessons learned
This project provided practical experience with:

- Terraform infrastructure provisioning
- Azure resource management
- Azure RBAC
- Managed identities
- Microsoft Entra ID
- GitHub OIDC federation
- Docker containerization
- Azure Container Registry
- Azure App Service
- GitHub Actions
- CI/CD workflow separation
- Git branching and rebasing
- Debugging cloud deployment failures
- Troubleshooting container startup and networking issues

## 19. Future Improvements
Possible improvements include:

- Replace `latest` Docker tags with immutable version tags
- Add SonarQube code analysis
- Add Docker image vulnerability scanning
- Add Application Insights
- Add deployment slots
- Implement staging and production environments
- Store Terraform state remotely
- Add automated rollback
- Add infrastructure tests
- Add approval gates before production deployment







