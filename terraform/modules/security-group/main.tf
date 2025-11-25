# ============================================
# SECURITY GROUP MODULE - MAIN CONFIGURATION
# ============================================
# Módulo reutilizável para criação de Security Groups

resource "aws_security_group" "main" {
  name_prefix = "${var.name}-"
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = var.name
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================
# INGRESS RULES
# ============================================
resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type              = "ingress"
  security_group_id = aws_security_group.main.id

  from_port   = var.ingress_rules[count.index].from_port
  to_port     = var.ingress_rules[count.index].to_port
  protocol    = var.ingress_rules[count.index].protocol
  cidr_blocks = lookup(var.ingress_rules[count.index], "cidr_blocks", null)
  
  source_security_group_id = lookup(var.ingress_rules[count.index], "source_security_group_id", null)
  
  description = lookup(var.ingress_rules[count.index], "description", "Managed by Terraform")
}

# ============================================
# EGRESS RULES
# ============================================
resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)

  type              = "egress"
  security_group_id = aws_security_group.main.id

  from_port   = var.egress_rules[count.index].from_port
  to_port     = var.egress_rules[count.index].to_port
  protocol    = var.egress_rules[count.index].protocol
  cidr_blocks = lookup(var.egress_rules[count.index], "cidr_blocks", null)
  
  source_security_group_id = lookup(var.egress_rules[count.index], "source_security_group_id", null)
  
  description = lookup(var.egress_rules[count.index], "description", "Managed by Terraform")
}
