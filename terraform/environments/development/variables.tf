# ============================================
# VARIABLES
# ============================================
# Define variáveis de configuração do Terraform

# Região AWS onde os recursos serão criados
variable "aws_region" {
  description = "AWS region" # Região AWS
  type        = string       # Tipo: string
  default     = "us-east-1"  # Valor padrão: N. Virginia
}

# Nome do projeto (usado em tags e nomes de recursos)
variable "project_name" {
  description = "Project name" # Nome do projeto
  type        = string         # Tipo: string
  default     = "fiap-cicd"    # Valor padrão
}

# Nome do ambiente (development, staging, production)
variable "environment" {
  description = "Environment name" # Nome do ambiente
  type        = string             # Tipo: string
  default     = "development"      # Valor padrão: development
}
