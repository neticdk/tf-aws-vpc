/*
 * Copyright (c) 2019 Netic A/S. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "availability_zone_names" {
  description = "A list of availability zone names in which resources will be created"
  default     = []
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = null
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = null
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC"
  default     = false
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

variable "protected_subnets" {
  description = "A list of protected subnets inside the VPC"
  default     = []
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  default     = {}
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  default     = {}
}

variable "protected_subnet_tags" {
  description = "Additional tags for the protected subnets"
  default     = {}
}

variable "protected_subnet_group_tags" {
  description = "Additional tags for the protected subnet group"
  default     = {}
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  default     = {}
}

variable "protected_route_table_tags" {
  description = "Additional tags for the protected route tables"
  default     = {}
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all private subnets. Will be placed on the subnet in public_subnets."
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) in public subnets"
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Use one NAT gateway in each availability zone specified in availability_zone_names"
  type        = bool
  default     = true
}

variable "nat_gateway_tags" {
  description = "Additional tags for the NAT gateways"
  default     = {}
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = bool
  default     = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}

variable "nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  default     = {}
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  default     = "public"
}

variable "private_subnet_suffix" {
  description = "Suffix to privateend to private subnets name"
  default     = "private"
}

variable "protected_subnet_suffix" {
  description = "Suffix to append to protected subnets name"
  default     = "protected"
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = false
}

