# ============================================
# OUTPUTS
# ============================================
# Define valores de saída após apply
# Podem ser usados por outros módulos ou exibidos ao usuário

# ID da VPC criada
output "vpc_id" {
  description = "ID of the VPC" # Descrição do output
  value       = aws_vpc.main.id # Valor: ID da VPC
}

# IDs das subnets públicas criadas
output "public_subnet_ids" {
  description = "IDs of the public subnets" # Descrição do output
  value       = aws_subnet.public[*].id     # Valor: lista de IDs das subnets
}

# Nome do bucket S3 de artefatos
output "s3_bucket_name" {
  description = "Name of the S3 bucket"        # Descrição do output
  value       = aws_s3_bucket.artifacts.bucket # Valor: nome do bucket
}
