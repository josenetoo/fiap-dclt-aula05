# ============================================
# VPC MODULE - VARIABLES
# ============================================
# Variáveis de entrada para o módulo VPC

variable "name" {
  description = "Nome base para os recursos"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_count" {
  description = "Número de subnets públicas"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Número de subnets privadas"
  type        = number
  default     = 2
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames na VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar DNS support na VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Criar NAT Gateway para subnets privadas (CUIDADO: Alto custo no Learner Lab)"
  type        = bool
  default     = false
}

variable "nat_gateway_count" {
  description = "Número de NAT Gateways (para alta disponibilidade)"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags para aplicar aos recursos"
  type        = map(string)
  default     = {}
}
