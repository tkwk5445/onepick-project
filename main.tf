// Resource : VPC
resource "ncloud_vpc" "main" {
  name            = var.vpc_name
  ipv4_cidr_block = var.vpc_ipv4_cidr_block
}

// Resource : subnet(public)
resource "ncloud_subnet" "public" {
  name           = var.public_subnet_name
  vpc_no         = ncloud_vpc.main.id
  subnet         = var.public_subnet_cidr_blocks[0]
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
}

// Resource : NAT subnet(public)
resource "ncloud_subnet" "public-nat" {
  name           = var.nat_subnet_name
  vpc_no         = ncloud_vpc.main.id
  subnet         = var.public_subnet_cidr_blocks[1]
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "NATGW"
}

// Resource : LB subnet(public, WEB)
resource "ncloud_subnet" "public-web-lb" {
  name           = var.public_lb_subnet_name[0]
  vpc_no         = ncloud_vpc.main.id
  subnet         = var.public_subnet_cidr_blocks[2]
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "LOADB"
}

// Resource : LB subnet(public, WAS)
resource "ncloud_subnet" "public-was-lb" {
  name           = var.public_lb_subnet_name[1]
  vpc_no         = ncloud_vpc.main.id
  subnet         = var.public_subnet_cidr_blocks[3]
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "LOADB"
}

// Resource : Subnet (Private1,2)
resource "ncloud_subnet" "private" {
  count          = length(var.private_subnet_names)
  name           = var.private_subnet_names[count.index]
  vpc_no         = ncloud_vpc.main.id
  subnet         = element(var.private_subnet_cidr_blocks, count.index)
  zone           = "KR-${count.index + 1}"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PRIVATE"
}

// Resource : NAT Gateway
resource "ncloud_nat_gateway" "natgw" {
  vpc_no    = ncloud_vpc.main.id
  subnet_no = ncloud_subnet.public-nat.id
  zone      = "KR-1"
  // below fields is optional
  name = var.nat_gateway_name
  // description = "NAT Gateway with Terraform"
}

// Resource : Public Route Table & Association
resource "ncloud_route_table" "public-rt" {
  vpc_no = ncloud_vpc.main.id
  name   = var.public_route_table_name
  // description = ""
  supported_subnet_type = "PUBLIC"
}

// Resource : Private Route Table & Association
resource "ncloud_route_table" "private-rt" {
  vpc_no = ncloud_vpc.main.id
  name   = var.private_route_table_name
  // description = ""
  supported_subnet_type = "PRIVATE"
}

// Resource : Public Route Table Association
resource "ncloud_route_table_association" "public-rt-association" {
  route_table_no = ncloud_route_table.public-rt.id
  subnet_no      = ncloud_subnet.public.id
}

// Resource : Private Route Table Association
resource "ncloud_route_table_association" "private-rt-association" {
  count          = 2
  route_table_no = ncloud_route_table.private-rt.id
  subnet_no      = ncloud_subnet.private[count.index].id
}

// Resource : Route Rule Configuration
resource "ncloud_route" "private-nat" {
  route_table_no         = ncloud_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW" // NATGW (NAT Gateway) , VPCPEERING (VPC Peering) , VGW (Virtual Private Gateway)
  target_name            = ncloud_nat_gateway.natgw.name
  target_no              = ncloud_nat_gateway.natgw.id
}

# Resource : ACG
resource "ncloud_access_control_group" "public-acg" {
  name   = "onepick-prod-public-acg"
  vpc_no = ncloud_vpc.main.id
}

resource "ncloud_access_control_group" "web-acg" {
  name   = "onepick-prod-web-acg"
  vpc_no = ncloud_vpc.main.id
}

resource "ncloud_access_control_group" "was-acg" {
  name   = "onepick-prod-was-acg"
  vpc_no = ncloud_vpc.main.id
}

// Resource : ACG Rule
resource "ncloud_access_control_group_rule" "public-acg-rule" {
  access_control_group_no = ncloud_access_control_group.public-acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "22"
    description = "accept 22 port"
  }

  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "accept 1-65535 port"
  }
}

resource "ncloud_access_control_group_rule" "web-acg-rule" {
  access_control_group_no = ncloud_access_control_group.web-acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "10.10.0.0/16"
    port_range  = "22"
    description = "accept 22 port"
  }
  inbound {
    protocol    = "TCP"
    ip_block    = "10.10.0.0/16"
    port_range  = "80"
    description = "accept 80 port"
  }
  inbound {
    protocol    = "TCP"
    ip_block    = "10.10.0.0/16"
    port_range  = "443"
    description = "accept 443 port"
  }
  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "accept 1-65535 port"
  }
}

resource "ncloud_access_control_group_rule" "was-acg-rule" {
  access_control_group_no = ncloud_access_control_group.was-acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "10.10.0.0/16"
    port_range  = "22"
    description = "accept 22 port"
  }
  inbound {
    protocol    = "TCP"
    ip_block    = "10.10.0.0/16"
    port_range  = "3000"
    description = "accept 3000 port"
  }
  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "accept 1-65535 port"
  }
}

// Resource : Server Login Key
resource "ncloud_login_key" "loginkey" {
  key_name = var.login_key_name
}

// Server Image Type & Product Type
data "ncloud_server_image" "server_image" {
  filter {
    name   = "product_name"
    values = ["ubuntu-20.04"]
  }
  /* image list
   + "SW.VSVR.OS.LNX64.CNTOS.0703.B050"          = "centos-7.3-64"
   + "SW.VSVR.OS.LNX64.CNTOS.0708.B050"          = "CentOS 7.8 (64-bit)"
   + "SW.VSVR.OS.LNX64.UBNTU.SVR1604.B050"         = "ubuntu-16.04-64-server"
   + "SW.VSVR.OS.LNX64.UBNTU.SVR1804.B050"         = "ubuntu-18.04"
   + "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"         = "ubuntu-20.04"
   + "SW.VSVR.OS.WND64.WND.SVR2016EN.B100"         = "Windows Server 2016 (64-bit) English Edition"
   + "SW.VSVR.OS.WND64.WND.SVR2019EN.B100"         = "Windows Server 2019 (64-bit) English Edition"
  */
  /* Attributes Reference
    data.ncloud_server_image.server_image.id
  */
}
data "ncloud_server_product" "product" {
  server_image_product_code = data.ncloud_server_image.server_image.id

  filter {
    name   = "product_code"
    values = ["SSD"]
    regex  = true
  }
  filter {
    name   = "cpu_count"
    values = ["2"]
  }
  filter {
    name   = "memory_size"
    values = ["4GB"]
  }
  filter {
    name   = "product_type"
    values = ["HICPU"]
    /* Server Spec Type
    STAND
    HICPU
    HIMEM
    */
  }
  /* Attributes Reference
    data.ncloud_server_product.product.id
  */
}

# Resource : Bastion Server = Login key + VPC + Subnet Server Image + Product
resource "ncloud_server" "bastion" {
  subnet_no                 = ncloud_subnet.public.id
  name                      = "onepick-prod-bastion-kr1"
  server_image_product_code = data.ncloud_server_image.server_image.id
  server_product_code       = data.ncloud_server_product.product.id
  login_key_name            = ncloud_login_key.loginkey.key_name
}

# Resource : Public IP (Bastion)
resource "ncloud_public_ip" "public-ip" {
  server_instance_no = ncloud_server.bastion.id
}

# Resource : Web Server = Login key + VPC + Subnet Server Image + Product
resource "ncloud_server" "web" {
  subnet_no                 = ncloud_subnet.private[0].id
  name                      = "onepick-prod-web-kr1"
  server_image_product_code = data.ncloud_server_image.server_image.id
  server_product_code       = data.ncloud_server_product.product.id
  login_key_name            = ncloud_login_key.loginkey.key_name
}

# Resource : WAS = Login key + VPC + Subnet Server Image + Product
locals {
  was_servers = [
    {
      name         = "onepick-prod-was1-kr1"
      subnet_index = 0
    },
    {
      name         = "onepick-prod-was2-kr2"
      subnet_index = 1
    }
  ]
}

resource "ncloud_server" "was" {
  count                     = length(local.was_servers)
  subnet_no                 = ncloud_subnet.private[local.was_servers[count.index].subnet_index].id
  name                      = local.was_servers[count.index].name
  server_image_product_code = data.ncloud_server_image.server_image.id
  server_product_code       = data.ncloud_server_product.product.id
  login_key_name            = ncloud_login_key.loginkey.key_name
}

// Resource : Web Target Group
resource "ncloud_lb_target_group" "web-tg" {
  vpc_no      = ncloud_vpc.main.vpc_no
  name        = "onepick-prod-web-tg"
  protocol    = "HTTP"
  target_type = "VSVR"
  port        = 80
  description = "for Web Server"
  health_check {
    protocol       = "HTTP"
    http_method    = "HEAD"
    port           = 80
    url_path       = "/"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

// Resource : Web Target Group Attachment
resource "ncloud_lb_target_group_attachment" "web-tg-attach" {
  target_group_no = ncloud_lb_target_group.web-tg.target_group_no
  target_no_list  = [ncloud_server.web.instance_no]
}

resource "ncloud_lb_target_group" "was-tg" {
  vpc_no      = ncloud_vpc.main.vpc_no
  name        = "onepick-prod-was-tg"
  protocol    = "HTTP"
  target_type = "VSVR"
  port        = 3000
  description = "for WAS"
  health_check {
    protocol       = "HTTP"
    http_method    = "HEAD"
    port           = 3000
    url_path       = "/api/health"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

// Resource : Web Target Group Attachment
resource "ncloud_lb_target_group_attachment" "was-tg-attach" {
  target_group_no = ncloud_lb_target_group.was-tg.target_group_no
  target_no_list  = flatten([for server in ncloud_server.was : server.instance_no])
}

// Resource : Application LoadBalancer (WEB)
resource "ncloud_lb" "web-lb" {
  name           = "onepick-prod-web-alb"
  network_type   = "PUBLIC"
  type           = "APPLICATION"
  subnet_no_list = [ncloud_subnet.public-web-lb.subnet_no]
}

// Resource LB listener (WEB)
resource "ncloud_lb_listener" "web-lb-listener" {
  load_balancer_no = ncloud_lb.web-lb.load_balancer_no
  protocol         = "HTTP"
  port             = 80
  target_group_no  = ncloud_lb_target_group.web-tg.target_group_no
} // HTTPS 및 인증서 추후에  콘솔 내에서 적용

// Resource : Application LoadBalancer (WAS)
resource "ncloud_lb" "was-lb" {
  name           = "onepick-prod-was-alb"
  network_type   = "PUBLIC"
  type           = "APPLICATION"
  subnet_no_list = [ncloud_subnet.public-was-lb.subnet_no]
}

// Resource LB listener (WEB)
resource "ncloud_lb_listener" "was-lb-listener" {
  load_balancer_no = ncloud_lb.was-lb.load_balancer_no
  protocol         = "HTTP"
  port             = 80
  target_group_no  = ncloud_lb_target_group.was-tg.target_group_no
} // HTTPS 및 인증서 추후에  콘솔 내에서 적용
