# expertalk-2018-ecs-workshop
Repository for ecs workshop for expert talk india conference 2018.

# Workshop concerns


## Setup Jenkins

## Setup dockerised services

## Local development considerations
### Component and integration tests 

## Application Configuration Management

## Infrastructure as Code

## CICD practices and Pipeline design considerations 
### Deployment scenarios
### CICD Branching support

## ECS Deploymnets
### Basic understanding
### Practicle cluster setup.

## Supporting mulitple Environments
### Environment on demand

## Deployment strategies
### Rolling update
### Blue green deployments (immutable)

## Team structure (Recommendation).

# Workshop outline (described as stories)

## Story 1 (iteration 0)

Walking skeleton one service
Choose Language / Framework etc
Directory structure
Unit test

## Story 2

Setup basic Jenkins
Commit pipeline

## Story 3

Docker image for the service
component test with docker file

Enhance commit pipeline to build and publish docker file to ECR. 
Version the docker images (versioning system external to jenkins so do not use build number)

## Story 4

Service deployment 
	Define ECS Service (should I move it to plateform concern?)
	Define ECS Task definition (should I move it to plateform concern?)
	Mark docker image to be used for the deployment. 
	
- New docker image available
- Promote a perticual docker image to a perticular environment.
	- Promote to dev (possibly automatic)
	- Promote to Prod (automatic? or manual) - To be added later. 

## Story 5

Carry out the service deployments to cluster/clusters as defined. 
(use terraform to allow to reach to the given state)
This should be idempotent.

## Story 6

Feature addition and re-deployment. 

## Story 7

Convert the jobs to job DSLs and Seed Jobs (make the seed job - schedule or whenever there is a change)

## Story 8

Add 2 more services to this setup and complete the deployment.

## Story 9

Introduce another environment Prod. 
- Introduce environement in the cluster definition. 
- Introduce docker promotion for production environment. 

## Story 10

Exploring ECS scaling. 
	- Container + ASGs.
- Introduce scaling policies for container. 
- Introduce scaling policies for ASGs.
- Explore ahead of time scaling.

## Story 11

Cluster updates - Rolling the ASG instances through terraform.

## Story 12

Instance termination challenges - Introduce Draining lambda. 

## Story 13

Config management - Cover just some introduction.

## Story 14

Various deployments scenarios
- Cluster deployment
- Service deployment
- Config deployment
- In place changes. 

## Story 15

Environment on demand

## Story 16

Blue green deployment in production

# Vagrant Setup

