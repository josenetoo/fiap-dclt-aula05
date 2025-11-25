# VPC Module

Módulo Terraform para criação de VPC com subnets públicas e privadas.

## Uso

### Para AWS Learner Lab (Recomendado)
```hcl
module "vpc" {
  source = "./modules/vpc"

  name                = "my-project"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_count = 2
  private_subnet_count = 0  # Sem subnets privadas
  enable_nat_gateway  = false  # ❌ NAT Gateway custa ~$32/mês

  tags = {
    Environment = "development"
    Project     = "my-project"
  }
}
```

### Para Conta AWS Normal
```hcl
module "vpc" {
  source = "./modules/vpc"

  name                = "my-project"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_count = 2
  private_subnet_count = 2
  enable_nat_gateway  = true  # ✅ OK em conta normal

  tags = {
    Environment = "development"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Nome base para os recursos | `string` | n/a | yes |
| vpc_cidr | CIDR block para a VPC | `string` | `"10.0.0.0/16"` | no |
| public_subnet_count | Número de subnets públicas | `number` | `2` | no |
| private_subnet_count | Número de subnets privadas | `number` | `2` | no |
| enable_nat_gateway | Criar NAT Gateway | `bool` | `false` | no |
| tags | Tags para os recursos | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID da VPC criada |
| public_subnet_ids | IDs das subnets públicas |
| private_subnet_ids | IDs das subnets privadas |
| internet_gateway_id | ID do Internet Gateway |
| nat_gateway_ids | IDs dos NAT Gateways |
