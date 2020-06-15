# Netic AWS VPC Terraform Module

## Supported Terraform Versions

Terraform 0.12

## Usage

```hcl
module "vpc" {
  source = "github.com/neticdk/tf-aws-vpc"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  availability_zone_names = [ "eu-west-1a",    "eu-west-1b",    "eu-west-1c"    ]
  private_subnets         = [ "10.0.0.0/19",   "10.0.32.0/19",  "10.0.64.0/19"  ]
  protected_subnets       = [ "10.0.128.0/21", "10.0.136.0/21", "10.0.244.0/21" ]
  public_subnets          = [ "10.0.160.0/21", "10.0.168.0/21", "10.0.176.0/21" ]

  enable_dns_support      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = false
  enable_s3_endpoint      = true
}
```


## Subnets
Three types of subnets can be created:

* **public** - used for resources that need routed public ip adresses
* **private** - used for resources that need access through a NAT gateway
* **protected** - used for resources without internet access

### Public Subnets
If specifying any public subnets, the following resources will be created:

* an internet gateway
* a route table
* a route on the public route tabel routing traffic to 0.0.0.0/0 through the
  internet gateway
* a subnet for each cidr specified in `public_subnets`. Each subnet will be
  created in the availability corresponding to the position of the cidr in the
  `availability_zone_names` list
* a route table association between each subnet and the public route table
* a NAT gateway placed in each public subnet/availability zone with
  a corresponding elastic ip address

### Private Subnets
If specifying any private subnets, the following resources will be created:

* a route table for each availability zone specified in
  `availability_zone_names`
* a subnet for each cidr specified in `private_subnets`. Each subnet will be
  created in the availability corresponding to the position of the cidr in the
  `availability_zone_names` list
* a route table association between each subnet and the corresponding private
  route table
* a route for each private subnet to 0.0.0.0/0 through the corresponding NAT
  gateway in the public subnet of the same availability zone

### Protected Subnets
If specifying any protected subnets, the following resources will be created:

* a route table for each availability zone specified in
  `availability_zone_names`
* a subnet for each cidr specified in `protected_subnets`. Each subnet will be
  created in the availability corresponding to the position of the cidr in the
  `availability_zone_names` list
* a route table association between each subnet and the corresponding
  protected route table

## S3 Endpoints
If `enabled_s3_endpoint` is `true`, the following resources are created:

* an S3 endpoint
* a route table association between each public subnet and the s3 endpoint
* a route table association between each private subnet and the s3 endpoint

<!---BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK--->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| assign\_generated\_ipv6\_cidr\_block | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC | string | `"false"` | no |
| availability\_zone\_names | A list of availability zone names in which resources will be created | list | `<list>` | no |
| cidr\_block | The CIDR block for the VPC | string | `"null"` | no |
| enable\_dns\_hostnames | Should be true to enable DNS hostnames in the VPC | string | `"false"` | no |
| enable\_dns\_support | Should be true to enable DNS support in the VPC | string | `"true"` | no |
| enable\_nat\_gateway | Create NAT gateway(s) in public subnets | bool | `"true"` | no |
| enable\_s3\_endpoint | Should be true if you want to provision an S3 endpoint to the VPC | string | `"false"` | no |
| enable\_dynamodb\_endpoint | Should be true if you want to provision a DynamoDB endpoint to the VPC | string | `"false"` | no |
| external\_nat\_ip\_ids | List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips) | list(string) | `<list>` | no |
| igw\_tags | Additional tags for the internet gateway | map | `<map>` | no |
| instance\_tenancy | A tenancy option for instances launched into the VPC | string | `"null"` | no |
| map\_public\_ip\_on\_launch | Should be false if you do not want to auto-assign public IP on launch | string | `"true"` | no |
| name | Name to be used on all the resources as identifier | string | `""` | no |
| nat\_eip\_tags | Additional tags for the NAT EIP | map | `<map>` | no |
| nat\_gateway\_tags | Additional tags for the NAT gateways | map | `<map>` | no |
| one\_nat\_gateway\_per\_az | Use one NAT gateway in each availability zone specified in availability_zone_names | bool | `"true"` | no |
| private\_route\_table\_tags | Additional tags for the private route tables | map | `<map>` | no |
| private\_subnet\_suffix | Suffix to privateend to private subnets name | string | `"private"` | no |
| private\_subnet\_tags | Additional tags for the private subnets | map | `<map>` | no |
| private\_subnets | A list of private subnets inside the VPC | list | `<list>` | no |
| protected\_route\_table\_tags | Additional tags for the protected route tables | map | `<map>` | no |
| protected\_subnet\_group\_tags | Additional tags for the protected subnet group | map | `<map>` | no |
| protected\_subnet\_suffix | Suffix to append to protected subnets name | string | `"protected"` | no |
| protected\_subnet\_tags | Additional tags for the protected subnets | map | `<map>` | no |
| protected\_subnets | A list of protected subnets inside the VPC | list | `<list>` | no |
| public\_route\_table\_tags | Additional tags for the public route tables | map | `<map>` | no |
| public\_subnet\_suffix | Suffix to append to public subnets name | string | `"public"` | no |
| public\_subnet\_tags | Additional tags for the public subnets | map | `<map>` | no |
| public\_subnets | A list of public subnets inside the VPC | list | `<list>` | no |
| reuse\_nat\_ips | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable | bool | `"false"` | no |
| single\_nat\_gateway | Use a single NAT gateway for all private subnets. Will be placed on the subnet in public_subnets. | bool | `"false"` | no |
| tags | A map of tags to add to all resources | map | `<map>` | no |
| vpc\_tags | Additional tags for the VPC | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| private\_subnets | The private subnets created in the VPC |
| protected\_subnets | The protected subnets |
| public\_subnets | The public subnets created in the VPC |
| vpc\_arn | Amazon Resource Name (ARN) of VPC |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_id | The ID of the VPC |
| private\_route\_table\_ids | Route table ids for private subnets |
| public\_route\_table\_ids | Route table ids for public subnets |
| protected\_route\_table\_ids | Route table ids for protected subnets |

<!---END OF PRE-COMMIT-TERRAFORM DOCS HOOK--->

# Copyright
Copyright (c) 2019 Netic A/S. All rights reserved.

# License
MIT Licened. See LICENSE for full details.

