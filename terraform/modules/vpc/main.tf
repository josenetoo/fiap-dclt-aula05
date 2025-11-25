# ============================================
# VPC MODULE - MAIN CONFIGURATION
# ============================================
# Módulo reutilizável para criação de VPC com subnets públicas e privadas

# ============================================
# VPC
# ============================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

# ============================================
# INTERNET GATEWAY
# ============================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# ============================================
# DATA SOURCES
# ============================================
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================
# PUBLIC SUBNETS
# ============================================
resource "aws_subnet" "public" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name}-public-${count.index + 1}"
    Type = "Public"
  })
}

# ============================================
# PRIVATE SUBNETS
# ============================================
resource "aws_subnet" "private" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, var.public_subnet_count + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "${var.name}-private-${count.index + 1}"
    Type = "Private"
  })
}

# ============================================
# PUBLIC ROUTE TABLE
# ============================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}

# ============================================
# PUBLIC ROUTE TABLE ASSOCIATIONS
# ============================================
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================
# NAT GATEWAY (CONDITIONAL)
# ============================================
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? var.nat_gateway_count : 0

  domain = "vpc"
  
  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? var.nat_gateway_count : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${var.name}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# ============================================
# PRIVATE ROUTE TABLES
# ============================================
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? var.nat_gateway_count : 1

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-private-rt-${count.index + 1}"
  })
}

# ============================================
# PRIVATE ROUTE TABLE ASSOCIATIONS
# ============================================
resource "aws_route_table_association" "private" {
  count = var.private_subnet_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.enable_nat_gateway ? count.index % var.nat_gateway_count : 0].id
}
