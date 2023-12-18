The following project is an AWS infrastructure composed of a VPC with an internet gateway. Within this VPC, there are two subnets: 
one public and one private, located in two availability zones. Both subnets are covered by separate auto-scaling groups and have load balancers. 
All instances have port 22 closed, and access to them is guaranteed through AWS Session Manager. 
This means that the code also creates all the required endpoints and permissions for AWS SSM.
The code also creates security groups, IAM profiles, IAM roles, and policies for S3 buckets. 
These policies ensure the appropriate level of access to resources stored in individual S3 buckets, depending on whether the EC2 instance is public or private.
Public EC2 instances launch nginx servers. 


To run the code, you need to have HashiCorp Terraform installed. 
Follow the instructions provided by HashiCorp for the Terraform installation process and any required additional resources, such as Docker Desktop. 
You must also have configured access to your AWS account from your operating system using the aws configure command. 
The region used in the code is eu-central-1 (Frankfurt), as declared in the variables.tf file.

!!! IMPORTANT: Remember to delete all resources created by this code at the end, as they may generate costs on your AWS account. !!!

In the next steps, I plan to create and attach an SSL certificate, create Lambda functions, and automate their execution using cloudwatch events cron. 
I will also create Docker containers, which will serve as environments on private instances.

