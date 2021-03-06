# Ansible playbook to run project

Some explanation of the playbook and step by step to run it.

Follow the figure in ../doc/Arch.pdf file.

The playbook must be run in some steps to record some ARNs and IDs that was difficult to gather in one turn.

There is just one role used: AWS - follow the subdir roles/AWS

   - No credential is supplied in this git repositry.
   - It is expected to have ansible installed along with _boto_ and _boto3_ prerequisites.

## Ansible playbook

Use the AWS-ECS.yml config file to start. The variables are all inside vars\_files/AWS-ECS.yml.

The inventory file was named _AWS-ECS.inv_ in the same directory.

### Step to step on AWS

  - List tasks
    ``` 
    ansible-playbook -i AWS-ECS.inv --list-tasks AWS-ECS.yml
    ``` 

  - Create back end tier - database
    ``` 
    ansible-playbook -i AWS-ECS.inv --tags gather_default_vpc,create_rds_instances AWS-ECS.yml
    ``` 
     
  - Take note of the DB endpoint from facts.d/ directory

  - Create a basic environment before the ECS cluster
    ``` 
    ansible-playbook -i AWS-ECS.inv --tags gather_default_vpc,create_LB,create_TG,gather_elb AWS-ECS.yml
    ``` 
    
  - Note the ARNs of TG, domain name of LB for api and web tiers from facts.d/ directory.
  - ELB Target Group Ansible module has an issue: fix targetGroup health check path

  - Create ECS cluster and services
    ``` 
    ansible-playbook -i AWS-ECS.inv --tags gather_default_vpc,ecs AWS-ECS.yml
    ``` 

  - Create CloudFront distribution
    ``` 
    ansible-playbook -i AWS-ECS.inv --tags gather_default_vpc,create_cfn_instances AWS-ECS.yml
    ``` 

  - Note the Distribution ID to keep its idempotency (couldn't make it without the ID).

  - Run the complete playbook to check
    ``` 
    ansible-playbook -i AWS-ECS.inv AWS-ECS.yml
    ``` 

Access the web application load balancer by its domain name and refresh many times. 
The S3 bucket contains logs from the Load Balancer access from internet.

Cloudwatch contains logs from the ECS cluster tasks (i.e. containers) in two separate folders for **api** and **web** tiers.

### Start and stop or scale the cluster

Deploy the application:

  - To deploy a new version just do a new service deploy in AWS ECS Service.

The script in ansible/scripts/service.sh works by changing the number of active instances:

  - It will stop the cluster if variable _INSTANCES_ is set to zero.
  - To start change from 0 to any number greater than 1.
  - To scale just increase the _INSTANCES_ variable.

### AWS state untill now

  - automate role creation using ansible:
    - ECS cluster, ECS task, ECS service, LoadBalancer, TargetGroup, some Logs, CFN
  - CloudWatch logs:
    - api Service Tier 
    - web Service Tier 
    - RDS
  - Other logs:
    - internet-facing LB => S3 bucket
    - RDS performance insights on
  - separate tiers 
    - DB, (private subnet)
    - API (+LB), (private subnet, internal LB)
    - WEB (+LB +CFN), (public subnet, internet-facing LB)
  - Docker startup script automates the clone of app from git - just specify tier in startup argument
  - scripts to start / stop / load expand is all-in-one and is in "scripts" directory: service.sh
    - Change the INSTANCES shell variable to 0 to stop, > 1 to start and scale

##  TODO

### On premises (frozen)

  - save / centralize log files
  - backup database
  - metrics to troubleshoot
  - CDN (CloudFront)

### AWS

  - automate the full role creation in one step only. Some are still done by hand:
    - by hand 1 = Roles/Policies, Network, some CloudWatch
    - by hand 2 = assign CloudFront distribution ID to fix idempotency issue
    - These are partially automated - they are retrieved by the playbook and stored in facts.d/:
      - assign api Target Group Arn, 
      - assign web Target Group Arn, 
      - assign LB domain name to access from web cluster.
  - need some auto trigger to deploy (the container already deploy app on each start)
  - retrieve the DB backup from AWS RDS or issue a command from an auxiliar environment
  - issues: fix targetGroup health check path
