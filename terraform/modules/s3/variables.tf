# ============================================
# S3 MODULE - VARIABLES
# ============================================

variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "use_random_suffix" {
  description = "Adicionar sufixo aleatório ao nome do bucket"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Habilitar versionamento do bucket"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Habilitar criptografia do bucket"
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "Algoritmo de criptografia"
  type        = string
  default     = "AES256"
  
  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "Encryption algorithm must be AES256 or aws:kms."
  }
}

variable "block_public_access" {
  description = "Bloquear acesso público ao bucket"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Regras de lifecycle do bucket"
  type = list(object({
    id     = string
    status = string
    expiration = optional(object({
      days = number
    }))
    noncurrent_version_expiration = optional(object({
      days = number
    }))
  }))
  default = []
}

variable "bucket_policy" {
  description = "Política do bucket S3 (JSON)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para aplicar ao bucket"
  type        = map(string)
  default     = {}
}
