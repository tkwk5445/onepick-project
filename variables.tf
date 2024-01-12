variable "vpc_name" {
  description = "The name of the VPC"
  default     = "onepick-prod-vpc"
}

variable "vpc_ipv4_cidr_block" {
  description = "The IPv4 CIDR block for the VPC"
  default     = "10.10.0.0/16"
}

variable "public_subnet_name" {
  description = "The name of the public subnet"
  default     = "onepick-prod-public-kr1"
}

variable "nat_subnet_name" {
  description = "The name of the public nat subnet"
  default     = "onepick-prod-natgw-kr1"
}

variable "public_lb_subnet_name" {
  description = "The name of the public lb subnet name"
  type        = list(string)
  default     = ["onepick-prod-web-lb-kr1", "onepick-prod-was-lb-kr1"]
}

variable "private_subnet_names" {
  description = "The names of the private subnets"
  type        = list(string)
  default     = ["onepick-prod-private-kr1", "onepick-prod-private-kr2"]
}

variable "public_subnet_cidr_blocks" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.10.16.0/24", "10.10.32.0/24", "10.10.80.0/24", "10.10.96.0/24"]
}


variable "private_subnet_cidr_blocks" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.10.48.0/24", "10.10.64.0/24"]
}

variable "nat_gateway_name" {
  description = "The name of the NAT gateway"
  default     = "onepick-prod-natgw"
}

variable "public_route_table_name" {
  description = "The name of the public route table"
  default     = "onepick-prod-public-rt"
}

variable "private_route_table_name" {
  description = "The name of the private route table"
  default     = "onepick-prod-private-rt"
}


variable "login_key_name" {
  default = "onepick-prod-key"
}