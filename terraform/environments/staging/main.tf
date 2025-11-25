# ============================================
# TERRAFORM CONFIGURATION
# ============================================
# Configura versão do Terraform e providers
terraform {
  required_version = ">= 1.0"  # Versão mínima do Terraform
  
  # Provider AWS com versão 5.x
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # Provider oficial da AWS
      version = "~> 5.0"         # Versão 5.x (permite updates menores)
    }
  }
  
  # Backend S3 para armazenar o state remotamente
  # IMPORTANTE: Criar bucket antes de usar
  backend "s3" {
    bucket         = "fiap-terraform-state-staging"  # Bucket S3 para state
    key            = "staging/terraform.tfstate"     # Caminho do arquivo state
    region         = "us-east-1"                     # Região AWS
    encrypt        = true                            # Criptografar state
  }
}

# ============================================
# AWS PROVIDER CONFIGURATION
# ============================================
# Configura provider AWS com tags padrão
provider "aws" {
  region = var.aws_region  # Região definida em variables.tf
  
  # Tags aplicadas automaticamente a todos os recursos
  default_tags {
    tags = {
      Environment = "staging"          # Ambiente (dev/staging/prod)
      Project     = "fiap-cicd"        # Nome do projeto
      ManagedBy   = "terraform"        # Gerenciado por Terraform
      Owner       = "fiap-devops-team" # Time responsável
    }
  }
}

# ============================================
# VPC CONFIGURATION
# ============================================
# Cria VPC isolada para o ambiente de desenvolvimento
resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"  # Range de IPs: 10.1.0.0 - 10.1.255.255 (65.536 IPs)
  enable_dns_hostnames = true           # Habilita DNS hostnames para instâncias
  enable_dns_support   = true           # Habilita resolução DNS

  tags = {
    Name = "fiap-cicd-staging-vpc"  # Nome da VPC
  }
}

# ============================================
# INTERNET GATEWAY
# ============================================
# Permite comunicação entre VPC e Internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # Associa IGW à VPC criada acima

  tags = {
    Name = "fiap-cicd-staging-igw"  # Nome do Internet Gateway
  }
}

# ============================================
# PUBLIC SUBNETS
# ============================================
# Cria 2 subnets públicas em AZs diferentes (alta disponibilidade)
resource "aws_subnet" "public" {
  count = 2  # Cria 2 subnets

  vpc_id                  = aws_vpc.main.id                                      # VPC pai
  cidr_block              = cidrsubnet("10.1.0.0/16", 8, count.index)           # 10.1.0.0/24 e 10.1.1.0/24
  availability_zone       = data.aws_availability_zones.available.names[count.index]  # AZs diferentes
  map_public_ip_on_launch = true                                                # Instâncias recebem IP público automaticamente

  tags = {
    Name = "fiap-cicd-staging-public-${count.index + 1}"  # public-1, public-2
  }
}

# ============================================
# ROUTE TABLE - PUBLIC
# ============================================
# Tabela de rotas para subnets públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id  # VPC pai

  # Rota padrão: todo tráfego externo vai para o Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"                 # Todo tráfego (qualquer destino)
    gateway_id = aws_internet_gateway.main.id # Envia para IGW
  }

  tags = {
    Name = "fiap-cicd-staging-public-rt"  # Nome da route table
  }
}

# ============================================
# ROUTE TABLE ASSOCIATIONS
# ============================================
# Associa route table às subnets públicas
resource "aws_route_table_association" "public" {
  count = 2  # Uma associação por subnet

  subnet_id      = aws_subnet.public[count.index].id  # Subnet pública
  route_table_id = aws_route_table.public.id          # Route table pública
}

# ============================================
# DATA SOURCES
# ============================================
# Busca AZs disponíveis na região
data "aws_availability_zones" "available" {
  state = "available"  # Apenas AZs ativas
}

# ============================================
# S3 BUCKET FOR ARTIFACTS
# ============================================
# Bucket para armazenar artefatos de build/deploy
resource "aws_s3_bucket" "artifacts" {
  bucket = "fiap-cicd-staging-artifacts-${random_string.suffix.result}"  # Nome único com sufixo aleatório

  tags = {
    Name = "fiap-cicd-staging-artifacts"  # Nome do bucket
  }
}

# Gera sufixo aleatório para garantir nome único do bucket
resource "random_string" "suffix" {
  length  = 8          # 8 caracteres
  special = false      # Sem caracteres especiais
  upper   = false      # Apenas minúsculas
}

# Habilita versionamento no bucket (mantém histórico de arquivos)
resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id  # Bucket criado acima
  
  versioning_configuration {
    status = "Enabled"  # Versionamento ativo
  }
}

# Configura criptografia server-side (segurança)
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id  # Bucket criado acima

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Algoritmo de criptografia AES-256
    }
  }
}
