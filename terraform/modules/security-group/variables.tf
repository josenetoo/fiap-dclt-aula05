# ============================================
# SECURITY GROUP MODULE - VARIABLES
# ============================================

variable "name" {
  description = "Nome do Security Group"
  type        = string
}

variable "description" {
  description = "Descrição do Security Group"
  type        = string
  default     = "Security Group managed by Terraform"
}

variable "vpc_id" {
  description = "ID da VPC onde criar o Security Group"
  type        = string
}

variable "ingress_rules" {
  description = "Lista de regras de ingress"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks             = optional(list(string))
    source_security_group_id = optional(string)
    description             = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "Lista de regras de egress"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks             = optional(list(string))
    source_security_group_id = optional(string)
    description             = optional(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
}

variable "tags" {
  description = "Tags para aplicar ao Security Group"
  type        = map(string)
  default     = {}
}
