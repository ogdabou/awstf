module "athena" {
  source = "./modules/athena"
  bucket_arn = aws_s3_bucket.data_s3_bucket.arn
  kms_key_arn = aws_kms_key.s3_objects_kms_encryption_key.arn
}

#module "eks" {
#  source = "./modules/learn-terraform-provision-eks-cluster"
#  admin_arn = "arn:aws:iam::654654272742:role/infra"
#  region = var.aws_region
#}

#module "nomad" {
#  source = "./modules/learn-terraform-provision-eks-cluster"
#  admin_arn = "arn:aws:iam::654654272742:role/infra"
#  region = var.aws_region
#}

#module "superset" {
#  source = "./modules/superset"
#}

output "athena_access_key" {
  value = module.athena.iam_access_key_id
}

output "athena_access_key_secret" {
  value = module.athena.iam_secret_access_key
  sensitive = true
}