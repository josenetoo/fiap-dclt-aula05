# ============================================
# OUTPUTS
# ============================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "security_group_id" {
  description = "Web security group ID"
  value       = module.web_sg.security_group_id
}

output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = module.artifacts.bucket_id
}
