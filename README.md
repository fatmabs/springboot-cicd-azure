# 🚀 Spring Boot CI/CD Pipeline & Cloud Deployment on Azure

<p align="center">
  <img src="https://img.shields.io/badge/Azure-Cloud-0089D6?style=for-the-badge&logo=microsoft-azure&logoColor=white" alt="Azure">
  <img src="https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Actions">
  <img src="https://img.shields.io/badge/Spring_Boot-Application-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white" alt="Spring Boot">
</p>

## 📌 Project Overview
This project implements an automated Continuous Integration and Continuous Deployment (CI/CD) pipeline for a Spring Boot application deployed on Microsoft Azure. The infrastructure is fully provisioned using **Terraform (IaC)** and the application is containerized using **Docker**.

### 🔄 CI/CD Workflow Scenario
* **On Feature Branches**: Pushing code or opening a Pull Request triggers the **CI pipeline**, which runs automated Maven builds, unit tests, and Terraform syntax checks.
* **On Main Branch**: Merging code into `main` triggers the **CD pipeline**. It builds the Docker image, pushes it to Azure Container Registry (ACR), and deploys it to Azure App Service using **passwordless OIDC authentication**.

---

## 🏗️ Technical Architecture

```text
[ Developer ] ---> ( Git Push / PR ) ---> [ GitHub Repository ]
                                                   |
                                           ( GitHub Actions )
                                                   |
                   +-------------------------------+-------------------------------+
                   |                                                               |
        [ Terraform Provisioning ]                                       [ Build & Dockerize ]
                   |                                                               |
     ( Resource Group, VNet, ACR,                                         ( Push Image to ACR )
        App Service Plan )                                                         |
                   |                                                               |
                   +---------------------> [ Deploy to ] <-------------------------+
                                        Azure App Service
```

## 🧩 Azure Resource Topology
```text
Azure Resource Group
│
├── Azure Container Registry (ACR)
│   └── hello-api:latest
│
└── App Service Plan (Linux)
    └── Web App (Container)
        └── System-Assigned Managed Identity
            └── Role Assignment: AcrPull on ACR
```

## 🛠️ Tech Stack


| Category               | Technology                       |  Purpose                             |
|--------------------------|-------------------------------|-------------------------------|
| Backend                |Java 17, Spring Boot, Maven|REST API application build & tests|
| Containerization            | Docker, Azure Container Registry                    |Image packaging and registry storage
| Infrastructure as Code                    | Terraform   |Modular Azure infrastructure provisioning
| Cloud Provider                   | Microsoft Azure  |Hosting (App Service, ACR, Entra ID, RBAC)
| CI/CD & Security                | GitHub Actions, OpenID Connect (OIDC)        |Automated pipelines & passwordless auth


## 🔑 Key Security & Design Features
Zero-Secret Authentication (OIDC): GitHub Actions authenticates to Azure via Short-Lived Tokens using OpenID Connect (OIDC) and Microsoft Entra ID Federated Credentials — eliminating hardcoded service principal secrets.

Least Privilege Access (RBAC): Azure App Service pulls images from ACR using its System-Assigned Managed Identity with the AcrPull role.

Modular Infrastructure: Terraform code structured into reusable modules.


## 📁 Repository Structure
```text
springboot-cicd-azure/
├── .github/
│   └── workflows/
│       ├── ci.yml             # Integration workflow (Build, Test, Validation)
│       └── cd.yml             # Deployment workflow (Docker, ACR, App Service)
├── app/                       # Spring Boot Application
│   ├── src/
│   ├── Dockerfile
│   └── pom.xml
├── terraform/                 # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── README.md

```

## ⚙️ Setup & Deployment Steps
1. Azure OIDC & Service Principal Setup
Run the following Azure CLI commands to configure passwordless auth for GitHub Actions:
```bash

# 1. Create Microsoft Entra Application
az ad app create --display-name "github-actions-springboot"

# 2. Create Service Principal
az ad sp create --id <CLIENT_ID>

# 3. Create Federated Identity Credential
az ad app federated-credential create \
  --id "<CLIENT_ID>" \
  --parameters @federated-credential.json
```
Example federated-credential.json:
```json
{
  "name": "github-main",
  "issuer": "[https://token.actions.githubusercontent.com](https://token.actions.githubusercontent.com)",
  "subject": "repo:<OWNER>/<REPOSITORY>:ref:refs/heads/main",
  "description": "GitHub Actions OIDC federation for main branch",
  "audiences": ["api://AzureADTokenExchange"]
}
```
2. Configure GitHub Repository Variables
Add the following under Settings > Secrets and variables > Actions > Variables:

AZURE_CLIENT_ID

AZURE_TENANT_ID

AZURE_SUBSCRIPTION_ID

3. Local Infrastructure Provisioning
```bash

cd terraform/
terraform init
terraform plan
terraform apply -auto-approve
```

## 📈 Future Improvements
Implement immutable Docker image tagging using Git commit SHAs (github.sha) instead of latest.

Add SonarQube code quality analysis to the CI pipeline.

Integrate Trivy / Container Scanning for Docker security compliance.

Implement Azure App Service Deployment Slots for zero-downtime staging validation.

Migrate Terraform state to a remote backend (Azure Blob Storage with state locking).

## 👩‍💻 Author
Fatma Ben Slim

Junior Cloud & DevOps Engineer

Certified Azure Administrator (AZ-104) & HashiCorp Terraform Associate (004)
