# Multi-Stack Voting Application — Multi-AZ DevOps Deployment on AWS
---
## Overview

This project demonstrates how to deploy a production-grade, multi-AZ microservices application on AWS using Terraform, Docker, and Ansible.

##  Architecture Diagram
<img width="2751" height="1395" alt="Multi-Stack DevOps Infrastructure Automation drawio" src="https://github.com/user-attachments/assets/60ad1819-f4f3-4634-b866-36d1309c8a2c" />

---

## Architecture Highlights : Multi-Stack Voting Application

- Multi-AZ deployment (eu-west-1a & eu-west-1b)

- Public & private subnet isolation

- Application Load Balancer with path-based routing

- Bastion Host for secure SSH access

- NAT Gateways (1 per AZ) for outbound access

- No direct internet access to backend or database

## Application Overview
The goal was to transform a polyglot microservices application into a secure, highly available, and fully automated cloud deployment, following real-world DevOps best practices.
### The voting application includes:

- **Vote (Python)**: A Python Flask-based web application where users can vote between two options.
- **Redis (in-memory queue)**: Collects incoming votes and temporarily stores them.
- **Worker (.NET)**: A .NET 7.0-based service that consumes votes from Redis and persists them into a database.
- **Postgres (Database)**: Stores votes for long-term persistence.
- **Result (Node.js)**: A Node.js/Express web application that displays the vote counts in real time.

## Tools & Technologies

- **AWS**: VPC, EC2, ALB, IGW, NAT

- **Terraform**: Infrastructure as Code

- **Docker**: Containerization

- **Ansible**: Configuration management

## How the System Works
- User → ALB → Frontend (Vote / Result)
- Frontend → Redis
- Worker → Redis
- Worker → PostgreSQL
- Result → PostgreSQL
-- Backend services never initiate internet traffic and remain fully private.
---
## Security Design

- Public subnets: ALB, Bastion, Frontend
#### All Deployed EC2 Instances 
<img width="1905" height="542" alt="EC2-multi-az" src="https://github.com/user-attachments/assets/08ea49fe-f6a3-4bc6-a39c-f0edba54f08a" />

- Private app subnets: Redis + Worker

- Private DB subnets: PostgreSQL

- Bastion is the only SSH entry point

- Security Groups enforce least privilege
#### Security Groups
<img width="1913" height="472" alt="SG" src="https://github.com/user-attachments/assets/8ba2b297-e18e-4230-8f6f-dc06320a58f8" />


## Networking

- Custom VPC (10.20.0.0/16)
#### VPC Dashboard 
<img width="1897" height="882" alt="VPC-pointing-Private" src="https://github.com/user-attachments/assets/f722febd-b9e0-42ab-a9e2-ba322337fab8" />

- Public subnets (ALB, Bastion, NAT)

- Private subnets (Backend & Database)
#### Subnets
<img width="1912" height="441" alt="Screenshot 2025-11-11 223515" src="https://github.com/user-attachments/assets/89b4a42b-e624-484a-9a2a-7bf5d4f76824" />


- Internet Gateway for inbound traffic
#### Internet Gateway (IGW)
<img width="1907" height="552" alt="IGW" src="https://github.com/user-attachments/assets/3fab559e-4cbd-43e4-82fa-5e9af5afa0b5" />


- NAT Gateway per AZ for outbound access from private subnets

## Availability

Resources distributed across two Availability Zones

No single point of failure for frontend traffic or outbound connectivity

---
# Infrastructure Provisioning (Terraform)
- Terraform provisions:
- VPC (10.20.0.0/16)
- 6 subnets across 2 AZs
- Internet Gateway
- NAT Gateways (1 per AZ)
- EC2 instances (Frontend, Backend, DB, Bastion) across 2 AZs
- Security Groups
- Application Load Balancer
- Elastic IPs

## The following screenshots confirm successful infrastructure provisioning using Terraform.
#### Terraform Apply Output 
<img width="682" height="520" alt="Screenshot 2025-11-11 224225" src="https://github.com/user-attachments/assets/ff565bdc-8d6d-4b51-aa8d-59aa62f75957" />

#### Terraform State List
<img width="629" height="935" alt="Screenshot 2025-11-11 224054" src="https://github.com/user-attachments/assets/81328d00-89bd-43d9-b2b5-0746b6c642e3" />


## Application Load Balancer Configuration
<img width="1902" height="856" alt="ALB" src="https://github.com/user-attachments/assets/1b1327e8-1dd8-42e3-abae-dedfe19e10aa" />

### Custom Domains

vote.app.chin.diogohack.shop

result.app.chin.diogohack.shop

### Target Groups

- **Vote** → Port 8080

- **Result** → Port 8081

<img width="1910" height="450" alt="TG" src="https://github.com/user-attachments/assets/c21154ff-a330-4fc1-a9be-ccfbfa0dcac2" />


### Routing Rules

- **/vote** → Vote service

- **/result** → Result service

---
## Configuration Management (Ansible)

### Ansible performs:

- Docker installation

- Image pulls from Docker Hub

- Container deployment

- Environment variable configuration
### Ansible Deployment 
<img width="1911" height="633" alt="Screenshot 2025-11-11 221007" src="https://github.com/user-attachments/assets/6d45fdaf-9710-454d-801c-c99fdbb04f5a" />

## Connectivity flow:
Developer → Bastion → Private EC2s

---
## Container Deployment Verification
### Frontend (Public)
<img width="1275" height="677" alt="Screenshot 2025-11-11 222413" src="https://github.com/user-attachments/assets/3dda6337-c731-4e62-8840-1affdc688c79" />

### Backend (Private)
<img width="1216" height="715" alt="Screenshot 2025-11-11 222259" src="https://github.com/user-attachments/assets/47b3f37a-fc8d-41f5-acc3-89ab319bcb16" />

### Database (Private)
<img width="1137" height="642" alt="Screenshot 2025-11-11 222105" src="https://github.com/user-attachments/assets/aad8cf19-0904-4d7b-a208-24cd5ed81c22" />
- All containers verified running across both AZs.
---

## Application Validation
### Voting UI
<img width="1736" height="932" alt="with-domain-voting" src="https://github.com/user-attachments/assets/1101c473-d9e2-4292-9ea3-8ccb6d245576" />


### Real-Time Results Dashboard
<img width="1718" height="1004" alt="result-domain" src="https://github.com/user-attachments/assets/fda5ef82-68b9-4afe-b7c9-8ede7c3714ec" />


### Votes flow correctly:
- Redis → Worker → PostgreSQL → Result UI

---

## Challenges & Solutions
| Challenge                    | Solution                                           |
| ---------------------------- | -------------------------------------------------- |
| AMI drift                    | Used Terraform data source for latest Amazon Linux |
| Containers not communicating | Fixed Docker network configuration                 |
| Bastion access issues        | Implemented SSH ProxyJump                          |
| Secure outbound access       | NAT Gateway per AZ                                 |

---
## Key Learnings

- Terraform enables rapid environment rebuilds

- Networking mistakes are the #1 DevOps failure point

- Bastion hosts are critical for secure operations

- Multi-AZ design requires thoughtful routing

- Ansible simplifies multi-host orchestration
---
## 🎯 Conclusion

This project demonstrates **real-world DevOps engineering** through a complete infrastructure lifecycle:

### ✅ **What Was Accomplished:**
- **Cloud Architecture**: Designed & deployed multi-AZ, production-grade AWS infrastructure
- **Security Design**: Implemented VPC isolation, bastion hosts, and least-privilege security groups
- **Infrastructure Automation**: Full IaC with Terraform for repeatable deployments
- **Distributed System Debugging**: Resolved microservices communication across private subnets
- **Production-Ready Patterns**: ALB routing, NAT gateways, multi-AZ redundancy

### 📈 **Business Value Delivered:**
- **High Availability**: No single point of failure across two availability zones
- **Security Compliance**: Private backends, controlled access via bastion
- **Operational Excellence**: Complete automation from infrastructure to application deployment
- **Cost Optimization**: Efficient resource utilization with auto-scaling readiness

*This implementation serves as a blueprint for deploying secure, scalable microservices on AWS.*
---
## Author

### Chinmayee Pradhan
DevOps Engineer | AWS | Cloud Infrastructure
📍 Netherlands
-
**GitHub:** [chinmayee19feb](https://github.com/chinmayee19feb)  
### 🛠️ **Technologies Demonstrated:**
- **AWS Architecture**: VPC, Multi-AZ, ALB, NAT Gateway
- **Infrastructure as Code**: Terraform
- **Configuration Management**: Ansible
- **Containerization**: Docker
- **Microservices**: Python Flask, .NET, Node.js, Redis, PostgreSQL

