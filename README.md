<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->
- [CoalFire Proof-of-concept Azure environment using Terraform](#coalfire-proof-of-concept-azure-environment-using-terraform)
  - [Challenge Overview](#challenge-overview)
  - [Deliverables](#deliverables)
  - [Evaluation Criteria](#evaluation-criteria)
  - [Guidelines](#guidelines)
- [Solution Overview](#solution-overview)
  - [Introduction](#introduction)
  - [Architecture](#architecture)
  - [Architecture Diagram](#architecture-diagram)
  - [Deployment Steps](#deployment-steps)
  - [Design Decisions](#design-decisions)
  - [Assumptions](#assumptions)
  - [References](#references)
- [Terraform Deployment Instructions](#terraform-deployment-instructions)
  - [1. Prerequisites](#1-prerequisites)
  - [3. Initialize Terraform](#3-initialize-terraform)
    - [Troubleshooting:](#troubleshooting)
  - [4. Validate Configuration](#4-validate-configuration)
  - [5. Generate a Plan](#5-generate-a-plan)
  - [6. Apply Changes](#6-apply-changes)
  - [7. Verify Deployment](#7-verify-deployment)
  - [8. Manage Terraform State](#8-manage-terraform-state)
  - [9. Destroy Resources](#9-destroy-resources)
  - [Technical Requirements](#technical-requirements)
    - [Network](#network)
    - [Compute](#compute)
    - [Supporting Infrastructure](#supporting-infrastructure)

<!-- TOC end -->

<!-- TOC --><a name="coalfire-proof-of-concept-azure-environment-using-terraform"></a>
# CoalFire Proof-of-concept Azure environment using Terraform


<!-- TOC --><a name="challenge-overview"></a>
## Challenge Overview

Create a proof-of-concept Azure environment using Terraform. The environment will host a basic web server with proper network segmentation and security controls. Use Coalfire’s open source terraform modules as much as possible in your solution ([Coalfire-CF repositories](https://github.com/orgs/Coalfire-CF/repositories?q=visibility:public+terraform-azure)). The use of Terraform modules is required, but it is not required to use ours.

Your challenge when submitted should be all within a public GitHub repository, with your code, a diagram that depicts your solution, and any notes you have from going through the challenge. The main repo README should document your solution, provide deployment steps, and your notes and commentary from going through the challenge. Any detail not provided in the scenario or requirements is up to your discretion.

<!-- TOC --><a name="deliverables"></a>
## Deliverables

1. Public GitHub repository containing:
     - All Terraform configurations
     - Architecture diagram
     - README including:
         - Solution overview
         - Deployment instructions
         - Design decisions and assumptions
         - References to resources used
     - Screenshot of successful SSH connection to management VM
     - Screenshots of Apache running on both AS VMs

<!-- TOC --><a name="evaluation-criteria"></a>
## Evaluation Criteria

We evaluate tech challenges based on:

- Code Quality
    - Terraform best practices
    - Module usage
    - Correct resources deployed
- Security Implementation
    - Network segmentation
    - Access Controls
    - Azure best practices
- Architecture Design
    - Diagram clarity
    - Resource organization
- Documentation
    - Clear instructions
    - Well-documented assumptions
    - Proper reference citations
- Problem-Solving Approach
    - Solutions to challenges encountered
    - Design decisions

<!-- TOC --><a name="guidelines"></a>
## Guidelines

- Work independently – no collaboration
- We do encourage the use of web resources (Stack Overflow, Reddit, technical blogs, etc.). If used, provide links as part of your documentation.
- Document any assumptions and design decisions you make.
- Partial solutions with documented challenges are acceptable.
- Questions welcome – reach out if you need clarification.

<!-- TOC --><a name="solution-overview"></a>
# Solution Overview

## Introduction
This solution aims to create a proof-of-concept Azure environment using Terraform. The environment will host a basic web server with proper network segmentation and security controls. The solution leverages Coalfire’s open-source Terraform modules to ensure best practices and efficient resource management.

## Architecture
The architecture consists of the following components:
- **Virtual Network (VNet)**: A single VNet with multiple subnets to segregate different types of resources.
  - **Web Subnet**: Hosts the web servers.
  - **Application Subnet**: Hosts application servers.
  - **Database Subnet**: Hosts database servers.
  - **Management Subnet**: Hosts management and monitoring tools.
- **Network Security Groups (NSGs)**: Applied to each subnet to control inbound and outbound traffic.
- **Virtual Machines (VMs)**: Deployed in the web and management subnets.
  - **Web VMs**: Running Apache to serve web content.
  - **Management VM**: Used for administrative tasks and SSH access.
- **Load Balancer**: Distributes incoming web traffic across the web VMs.
- **Storage Account**: Used for storing Terraform state files and web logs.

## Architecture Diagram
![Architecture Diagram](/img/architecture-diagram.png)

## Screenshots
### Connection to management vm 
![management vm](img\Management-vm-connection.png)  

### Apache running on web vm 1  
![Apache on web vm 1](img\web-vm1-apache.png)  

### Apache running on web vm 2  
![Apache on web vm 1](img\web-vm1-apache.png)  

## Deployment Steps
1. **Initialize Terraform**: Set up the working directory and download required provider plugins.
2. **Validate Configuration**: Ensure the Terraform configuration files are syntactically correct.
3. **Generate a Plan**: Create an execution plan to preview the changes Terraform will make to the infrastructure.
4. **Apply Changes**: Execute the plan to create the resources in Azure.
5. **Verify Deployment**: Confirm that all resources are created as expected and the web server is accessible.

## Design Decisions
- **Network Segmentation**
  - Subnets are used to isolate different types of resources, enhancing security and manageability.
- **Use of Modules**
  - Coalfire’s Terraform modules are used to standardize resource creation and ensure best practices.
- **Security Controls**
  - Network Security Groups (NSG)s are configured to restrict East-West traffic. These are applied on the subnets.
  - Firwall should be placed on the virtual network to control North-South traffic.
- **Notes**  
   - Virtual Machines were created without the use of modules. This was due to CoalFire not having a Linux module published. This also demonstrates the creation of resources without the use of a module. 
   - Virtual machine passwords were generated in the terraform randomly.
   - variables are stored in local variables rather than tfvars file, this is personal preference. When building pipelines using local variables is easier to link to runtime parameters. 


## Assumptions
- The user has access to an Azure subscription with sufficient permissions to create the required resources.
- Terraform and Azure CLI are installed and configured on the user's machine.
- The necessary SSH keys are available for secure access to the VMs.

## References
- [Coalfire-CF Terraform Modules](https://github.com/orgs/Coalfire-CF/repositories?q=visibility:public+terraform-azure)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Documentation](https://docs.microsoft.com/en-us/azure/)
- [Table of Contents Generator](https://github.com/derlin/bitdowntoc)
- [Quickstart: Use Terraform to create a Linux VM](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform?tabs=azure-cli)

<!-- TOC --><a name="terraform-deployment-instructions"></a>
# Terraform Deployment Instructions

These instructions provide a step-by-step guide for deploying infrastructure using Terraform.

---

<!-- TOC --><a name="1-prerequisites"></a>
## 1. Prerequisites

Before starting, ensure you have the following installed on your system:

- Terraform: Download and install from [terraform.io](https://developer.hashicorp.com/terraform/downloads)
- Cloud CLI Tools (e.g., Azure CLI, AWS CLI, GCP CLI) depending on your cloud provider.
- Code Editor (e.g., VS Code, IntelliJ, etc.)
- Access Credentials:
   - Azure Service Principal / AWS IAM User / GCP Service Account
   - Sufficient permissions for resource creation

---

<!-- TOC --><a name="3-initialize-terraform"></a>
## 3. Initialize Terraform
In the project directory, run:  

`
terraform init  
`

What Happens:
- Required provider plugins are downloaded.  
- Backend storage (if configured) is initialized.  
- Working directory is set up.  

<!-- TOC --><a name="troubleshooting"></a>
### Troubleshooting:  
Ensure backend storage (e.g., Azure Storage, AWS S3) is accessible.  
Verify authentication credentials.  

<!-- TOC --><a name="4-validate-configuration"></a>
## 4. Validate Configuration

To verify the configuration syntax and logic, run:  

`
terraform validate  
`

Expected Output:  

`
Success! The configuration is valid.  
`

If errors occur, address them before proceeding.

<!-- TOC --><a name="5-generate-a-plan"></a>
## 5. Generate a Plan
Preview changes Terraform will make:  

`  
terraform plan  
`  

What to Check:
- Ensure planned resource changes match your expectations.
- Look out for warnings or errors.  
  
<!-- TOC --><a name="6-apply-changes"></a>
## 6. Apply Changes
Deploy infrastructure using:
`  
terraform apply
`

Automated Approval (Not Recommended for Production):  
`  
terraform apply -auto-approve  
`  

Monitor Deployment:  
Watch for any error messages.  
Ensure resources are created successfully.  
<!-- TOC --><a name="7-verify-deployment"></a>
## 7. Verify Deployment  
Log in to your cloud provider portal.  
Confirm that resources match the Terraform configuration.  

Retrieve outputs using:  
`  terraform output `  

<!-- TOC --><a name="8-manage-terraform-state"></a>
## 8. Manage Terraform State
Terraform maintains a state file (terraform.tfstate) to track resources.  


<!-- TOC --><a name="9-destroy-resources"></a>
## 9. Destroy Resources
To clean up resources managed by Terraform:  
` terraform destroy `  

Automated Approval:
` terraform destroy -auto-approve `  

Best Practice: Always review the destruction plan before applying.


<!-- TOC --><a name="technical-requirements"></a>
## Technical Requirements

<!-- TOC --><a name="network"></a>
### Network

- 1 VNet – 10.0.0.0/16
- 4 Subnets:
    - Application, Management, Backend, Web. All /24

<!-- TOC --><a name="compute"></a>
### Compute

- 2 Virtual Machines in an availability set running Linux (your choice of distro) in the web subnet
    - NSG allows SSH from management VM, allows web traffic from the Load Balancer. No external traffic
    - Script the installation of Apache
- 1 Virtual Machine running Linux (your choice of distro) in the Management subnet
    - NSG allows SSH from a single specific IP or network space only

<!-- TOC --><a name="supporting-infrastructure"></a>
### Supporting Infrastructure

- One storage account:
    - GRS Redundant
    - Only accessible to the VM in the Management subnet
    - One container “terraformstate”
    - One container “weblogs”
- One Load balancer that sends web traffic to the VMs in the availability set.
