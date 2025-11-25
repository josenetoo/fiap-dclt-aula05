# 🏗️ AULA 5 - Infrastructure as Code

> **Objetivo**: Dominar Infrastructure as Code com Terraform, incluindo pipelines CI/CD, gerenciamento de múltiplos ambientes e criação de módulos reutilizáveis.

---

## 🎯 Objetivos de Aprendizado

Ao final desta aula, você será capaz de:

- ✅ Entender os conceitos de Infrastructure as Code (IaC)
- ✅ Configurar e usar Terraform com AWS Provider
- ✅ Implementar backend remoto com S3 e DynamoDB
- ✅ Criar pipelines CI/CD para Terraform
- ✅ Gerenciar múltiplos ambientes (dev, staging, prod)
- ✅ Usar Terraform Workspaces
- ✅ Criar módulos Terraform reutilizáveis
- ✅ Publicar módulos no Terraform Registry
- ✅ Implementar boas práticas de IaC

---


## ✅ Checklist de Aprendizado

### Vídeo 5.1 - Terraform Básico
- [ ] Instalar Terraform
- [ ] Configurar AWS Provider
- [ ] Criar backend S3 + DynamoDB
- [ ] Executar `terraform init`
- [ ] Executar `terraform plan`
- [ ] Executar `terraform apply`
- [ ] Ver outputs com `terraform output`
- [ ] Criar pipeline CI/CD para Terraform
- [ ] Testar workflow no GitHub Actions

### Vídeo 5.2 - Multi-Ambientes
- [ ] Criar workspaces (dev, staging, prod)
- [ ] Configurar locals dinâmicos por ambiente
- [ ] Implementar tags por ambiente
- [ ] Criar pipeline multi-ambiente
- [ ] Testar promoção entre ambientes
- [ ] Verificar isolamento de state
- [ ] Implementar conditional resources

### Vídeo 5.3 - Módulos
- [ ] Criar módulo VPC
- [ ] Estruturar módulo (main, variables, outputs)
- [ ] Usar módulo localmente
- [ ] Testar módulo
- [ ] Preparar módulo para publicação
- [ ] Versionar módulo com Git tags
- [ ] Publicar no Terraform Registry (opcional)
- [ ] Implementar composição de módulos

---

## 🚨 Troubleshooting

### Erro 1: Backend S3 não encontrado
```bash
Error: Failed to get existing workspaces: S3 bucket does not exist
```
**Solução**: Criar bucket S3 antes de executar `terraform init`
```bash
aws s3 mb s3://fiap-terraform-state-dev --region us-east-1 --profile fiapaws
```

### Erro 2: Credenciais AWS inválidas
```bash
Error: error configuring Terraform AWS Provider: no valid credential sources
```
**Solução**: Configurar credenciais AWS com profile fiapaws
```bash
aws configure --profile fiapaws
# ou
export AWS_PROFILE=fiapaws
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

### Erro 3: Profile AWS não encontrado
```bash
Error: The config profile (fiapaws) could not be found
```
**Solução**: Verificar se o profile fiapaws está configurado
```bash
aws configure list --profile fiapaws
# Se não existir, configure:
aws configure --profile fiapaws
```

### Erro 4: Workspace já existe
```bash
Error: Workspace "development" already exists
```
**Solução**: Selecionar workspace existente
```bash
terraform workspace select development
```

### Erro 5: Bucket S3 nome duplicado
```bash
Error: Error creating S3 bucket: BucketAlreadyExists
```
**Solução**: Usar sufixo aleatório no nome (já implementado com `random_string`)

---

#=
---

## 🧹 Comandos de Limpeza

### Destruir recursos Terraform
```bash
cd terraform/environments/development

# Destruir recursos
terraform destroy

# Confirmar: yes
```


### Limpar workspaces
```bash
# Voltar para default
terraform workspace select default

# Deletar workspaces
terraform workspace delete development
terraform workspace delete staging
terraform workspace delete production
```

### Limpar backend S3
```bash
# Deletar objetos do bucket
aws s3 rm s3://fiap-terraform-state-dev --recursive --profile fiapaws

# Deletar bucket
aws s3 rb s3://fiap-terraform-state-dev --profile fiapaws
```

---

**Instrutor**: FIAP DevOps Team  
**Disciplina**: DevOps & Cloud Computing
