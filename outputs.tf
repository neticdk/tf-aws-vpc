/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "Amazon Resource Name (ARN) of VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnets" {
  description = "The public subnets created in the VPC"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "The private subnets created in the VPC"
  value       = aws_subnet.private[*].id
}

output "protected_subnets" {
  description = "The protected subnets"
  value       = aws_subnet.protected[*].id
}
