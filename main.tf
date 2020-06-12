/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

locals {
  tags = {
    Terraform = "true"
  }

  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.availability_zone_names) : length(var.private_subnets)
}

// VPC
resource "aws_vpc" "this" {
  cidr_block                       = var.cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
    local.tags,
    var.vpc_tags,
  )
}

// Internet Gateway
resource "aws_internet_gateway" "this" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
    local.tags,
    var.igw_tags,
  )
}

// Public Routes
resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
    var.tags,
    local.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

// Private Routes
resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_subnet_suffix}-%s",
        var.name,
        element(var.availability_zone_names, count.index),
      )
    },
    var.tags,
    local.tags,
    var.private_route_table_tags,
  )
}

// Protected Routes
resource "aws_route_table" "protected" {
  count = length(var.protected_subnets) > 0 ? length(var.availability_zone_names) : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format(
        "%s-${var.protected_subnet_suffix}-%s",
        var.name,
        element(var.availability_zone_names, count.index),
      )
    },
    var.tags,
    local.tags,
    var.protected_route_table_tags,
  )
}

// Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 && (false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.availability_zone_names)) ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.availability_zone_names, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      "Name" = format(
        "%s-${var.public_subnet_suffix}-%s",
        var.name,
        element(var.availability_zone_names, count.index),
      )
    },
    var.tags,
    local.tags,
    var.public_subnet_tags,
  )
}

// Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.availability_zone_names, count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_subnet_suffix}-%s",
        var.name,
        element(var.availability_zone_names, count.index),
      )
    },
    var.tags,
    local.tags,
    var.private_subnet_tags,
  )
}

// Protected Subnets
resource "aws_subnet" "protected" {
  count = length(var.protected_subnets) > 0 ? length(var.protected_subnets) : 0

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.protected_subnets[count.index]
  availability_zone = element(var.availability_zone_names, count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-${var.protected_subnet_suffix}-%s",
        var.name,
        element(var.availability_zone_names, count.index),
      )
    },
    var.tags,
    local.tags,
    var.protected_subnet_tags,
  )
}

// NAT Gateways - Elastic IPs
locals {
  nat_gateway_ips = split(
    ",",
    var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id),
  )
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway && false == var.reuse_nat_ips ? local.nat_gateway_count : 0

  vpc = true

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.availability_zone_names, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    local.tags,
    var.nat_eip_tags,
  )
}

// NAT Gateways (placed in public subnets)
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(local.nat_gateway_ips, var.single_nat_gateway ? 0 : count.index)
  subnet_id     = element(aws_subnet.public[*].id, var.single_nat_gateway ? 0 : count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.availability_zone_names, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    local.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

// NAT Gateway Routes for private subnets
resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

// Route Table Association - public
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(tolist(aws_route_table.public[*].id), count.index)
}

// Route Table Association - private
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, var.single_nat_gateway ? 0 : count.index)
}

// Route Table Association - protected
resource "aws_route_table_association" "protected" {
  count = length(var.protected_subnets) > 0 ? length(var.protected_subnets) : 0

  subnet_id      = element(aws_subnet.protected[*].id, count.index)
  route_table_id = element(aws_route_table.protected[*].id, count.index)
}

// S3 VPC Endpoints for private and public
data "aws_vpc_endpoint_service" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id       = aws_vpc.this.id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public[count.index].id
}


resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private[*].id, count.index)
}

// DynamoDB VPC Endpoints for private and public
data "aws_vpc_endpoint_service" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id       = aws_vpc.this.id
  service_name = data.aws_vpc_endpoint_service.dynamodb[0].service_name
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = var.enable_dynamodb_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = aws_route_table.public[count.index].id
}


resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = var.enable_dynamodb_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = element(aws_route_table.private[*].id, count.index)
}
