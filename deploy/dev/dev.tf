module "infra" {
  source = "../../src"
  consul_cluster_name = "dev"
}

output "access_key" {
  value = module.infra.athena_access_key
}

output "access_key_secret" {
  value = module.infra.athena_access_key_secret
  sensitive = true
}