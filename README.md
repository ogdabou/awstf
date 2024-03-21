# My Infra

Simple IaC demo using AWS and Terraform.

## My goals

- [x] [Define an S3 bucket using KMS encryption.](./src/s3.tf)
- [x] [Load any public CSV dataset into the created S3 bucket.](./src/s3_resources.tf)
- [x] [Create an IAM role with the following permissions:](./src/modules/athena)
    - [x] Ability to use Athena within a specific workgroup.
    - [x] Authorization to query the S3 bucket using Athena.
- [x] [Create an AWS access key that can assume the IAM role](./src/modules/athena/iam.tf)
  
    - Since I don't know athena, I didn't test to query the data  
    - The user credentials can be retrieved with `terraform output -json`.
    - Assume role with `aws sts assume-role --role-arn arn:aws:iam::{account}:role/athena_reader --role-session-name athena`

- [ ] Deploy Superset on your preferred orchestration platform, ensuring internet accessibility.
    - [ ] We recommend using ECS/Fargate/EKS/Hashi-Nomad, Consul and leveraging public Terraform modules.
- [ ] Upon deployment, please provide the HTTPS URL for accessing the Superset instance.
- [ ] Configure Superset to be able to query the aforementioned S3 bucket.
- [ ] Create a simple dashboard with 2-3 visualizations in Superset connecting to the data in the above S3 bucket.
- [ ] [Highlight a few simple statistics about the time series](#sql)
  - [x] Top 5 common Winning Numbers SQL
  - [x] Calculate average number multiplier
  - [x] Identify top 5 Meta Ball Numbers
  - [ ] How many of the lotteries were drawn on a weekday vs weekend
- [x] [Terraform plan](./deploy/dev/plan.txt) or [Terraform plan ASCII](./deploy/dev/plan-ascii.txt) 
### Requirements

- Terraform 1.7.5

```bash
cd deploy/dev
terraform init
terraform plan
terraform apply
```

## Achievements

### Terraform state

The terraform state is store in a manually created s3 bucket.

Are enabled:
- Versioning
- Encryption (Server-side encryption with Amazon S3 managed keys (SSE-S3))

### First 3 tasks

They weren't that much of a problem but still took **me some good time**, for simple stuff like setting up the terraform state first or asking myself
"Do I need to create the terraform user manually ?".


### [Current Struggle] The orchestrator

1. Naively started with consul & nomad  
   1. Intended to create a [module](./src/modules/nomad) which requires Packer  
   2. I think I read [this doc](https://registry.terraform.io/modules/hashicorp/nomad/aws/latest/submodules/nomad-cluster) and looked at how to build this  
   3. I also tried [this example](https://github.com/hashicorp/terraform-aws-nomad/tree/master) which I removed from the source  
   4. I already experienced packer before, twice probably  
   5. Gave up on it after 30 minutes  
2. Started to look at EKS with [this module](./src/modules/learn-terraform-provision-eks-cluster)  
   1. Following hashicorp's documentation, but it failed  
3. Sarted to look at Superset in ECS, "why not use simple docker images" ?  
   1. The idea was to first [install ECS](https://spacelift.io/blog/terraform-ecs)  
   2. Then deploy a simple docker image  
   3. Intended to create a [module](./src/modules/superset)  
   4. Pushed manually the public **superset:1.4.0** docker image to ECR repository defined within terraform  

### The big time wasters

- Try to apply the narrowed permissions by "dying and retrying". Meaning adding permissions to the infra `role` / `user`
as errors come but I lost so much time doing that.
In the end I did chose to go the `*` allow everything way but looking at it now,
for an exercise I probably shouldn't have done it considering time to spend / my skill on it.
- I probably lack the way to navigate documentation to get the list of policies to apply (or at least a starter)
- Generally finding the terraform module to use from the get go was hard. I did find some Github examples that were dated but nothing suitable for what I needed to achieve. Considering how I imagined things, I think that's a lack of knowledge / experience on using terraform but that's just another starter for discussion :).
- Not at ease when I got an error "provider configuration not present" several times
  - I learned `terraform state rm`. But clearly too late 😅

### What if... the orchestrator was there

Let's say the orchestrator was there, and for my pleasure after these hours of refreshing struggle, let's say it's an EKS cluster.


I don't have experience deploying applications with Terraform. Usually using kubernetes via helm / helmfile. With own heml chart if required.
While I'm a terraform noob I'm well experience with helm charts & templating.

#### Superset

- There is an [official helm chart](https://github.com/apache/superset/blob/master/helm/superset/Chart.yaml)
- Not sure how I would have linked the reference between helm and terraform resource definition.
- There seem to be an `initContainers`, so if not a lot of initialization features are mapped in the helm chart, I know everything is possible this way
- Create dashboards, export them as JSON. SQL queries embedded.
- Add them in the `initContainers` so that new infrastructure benefit from them

#### HTTPS

I've no setting that up with terraform / AWS alb.

But I've tried a bit to look at was necessary, I think I would have struggle on the certificate.

My experience is the following:
- I deploy [cert-manager](https://cert-manager.io/)
- I setup my DNS name / Kubernetes Ingress
- I annotate a deployment, and I've HTTPS with certificate renewal

It seems I would have had to create certificates manually, so I looked into [cerbot](https://certbot.eff.org/). But I did not understand:
- To create a cert with certbot, I need a DNS that targets the AWS ALB
- That means the ALB needs to be deployed (to my understanding)
- But to deploy the ALB, I need the certificate
- I would have used a personnal DNS to redirect to the ALBs ips

## SQL

### Find the top 5 common Winning Numbers

```sql
select
    count("Winning Numbers") as occurences,
    unnest(string_to_array("Winning Numbers", ' ')) AS parts
from
    lottery
group by parts
ORDER BY occurences DESC;
```

### Calculate the Average Multiplier Value

```sql
select avg(multiplier) as mean_multiplier from table;
```

### Identify the top 5 Mega Ball Numbers

```
select count("Mega Ball") as occurences,
"Mega Ball"
from lottery 
group by "Mega Ball" ORDER by occurences desc
```


