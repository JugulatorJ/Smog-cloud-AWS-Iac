# This file defines resources within the VPC: VPC, subnets, internet gateway, endpoints, route tables. 
# It also includes: auto scaling groups, load balancers.

# VPC

resource "aws_vpc" "smog_vpc" {
    cidr_block = var.cidr_vpc
    enable_dns_hostnames = true
    tags = {
        Name = var.name_vpc
    }
}

# Subnets: Public subnet

resource "aws_subnet" "public_web1" {
    vpc_id      = aws_vpc.smog_vpc.id
    availability_zone = var.AZ_1a
    cidr_block  = var.cidr_public_subnet1
    map_public_ip_on_launch = true
    tags        = {
                    Name = "General public subnet 1"
                    }
    
}

resource "aws_subnet" "public_web2" {
    vpc_id      = aws_vpc.smog_vpc.id
    availability_zone = var.AZ_1b
    cidr_block  = var.cidr_public_subnet2
    map_public_ip_on_launch = true
    tags        = {
                    Name = "General public subnet 2"
                    }
    
}

#Subnets: Private subnet

resource "aws_subnet" "private_storage_compute1" {
    vpc_id      = aws_vpc.smog_vpc.id
    availability_zone_id = aws_subnet.public_web1.availability_zone_id
    cidr_block  = var.cidr_private_subnet1
    tags        = {
                    Name = "Storaging and computing private subnet 1"
                    }
}

resource "aws_subnet" "private_storage_compute2" {
    vpc_id      = aws_vpc.smog_vpc.id
    availability_zone_id = aws_subnet.public_web2.availability_zone_id
    cidr_block  = var.cidr_private_subnet2
    tags        = {
                    Name = "Storaging and computing private subnet 2"
                    }
}

# Internet gateway

resource "aws_internet_gateway" "smog_IGW" {
    vpc_id  = aws_vpc.smog_vpc.id
    tags    = {
                Name = "SmogIGW"
    }
}

# VPC Endpoints

resource "aws_vpc_endpoint" "private_ssm_ep" {
    vpc_id = aws_vpc.smog_vpc.id
    vpc_endpoint_type = var.type_of_endpoint
    service_name = local.service_name_ssm
    private_dns_enabled = true
    subnet_ids = [aws_subnet.private_storage_compute1.id, aws_subnet.private_storage_compute2.id]
    security_group_ids = [aws_security_group.priv_ep_sg.id]
    tags    = {
                Name = "SSM ${var.type_of_endpoint} endpoint"
    }    
}

resource "aws_vpc_endpoint" "private_ssmmsg_ep" {
    vpc_id = aws_vpc.smog_vpc.id
    vpc_endpoint_type = var.type_of_endpoint
    service_name = local.service_name_ssmmsg
    private_dns_enabled = true
    subnet_ids = [aws_subnet.private_storage_compute1.id, aws_subnet.private_storage_compute2.id]
    security_group_ids = [aws_security_group.priv_ep_sg.id]
    tags    = {
                Name = "SSM Messages ${var.type_of_endpoint} endpoint"
    } 
}

resource "aws_vpc_endpoint" "private_ec2msg_ep" {
    vpc_id = aws_vpc.smog_vpc.id
    vpc_endpoint_type = var.type_of_endpoint
    service_name = local.service_name_ec2msg
    private_dns_enabled = true
    subnet_ids = [aws_subnet.private_storage_compute1.id, aws_subnet.private_storage_compute2.id]
    security_group_ids = [aws_security_group.priv_ep_sg.id]
    tags    = {
                Name = "EC2 Messages ${var.type_of_endpoint} endpoint"
    } 
}

resource "aws_vpc_endpoint" "private_s3_ep" {
    vpc_id = aws_vpc.smog_vpc.id
    service_name = local.service_name_s3
    tags    = {
                Name = "S3 gateway endpoint"
    }     
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.private_s3_ep.id
  route_table_id  = aws_route_table.private_routes.id
}

# Routes

resource "aws_route_table" "public_routes" {
    vpc_id = aws_vpc.smog_vpc.id
    route {
        cidr_block = var.cidr_internet
        gateway_id = aws_internet_gateway.smog_IGW.id
    }
}

resource "aws_route_table_association" "rt_web_asso1" {
    subnet_id       = aws_subnet.public_web1.id
    route_table_id  = aws_route_table.public_routes.id
}

resource "aws_route_table_association" "rt_web_asso2" {
    subnet_id       = aws_subnet.public_web2.id
    route_table_id  = aws_route_table.public_routes.id
}

resource "aws_route_table" "private_routes" {
    vpc_id = aws_vpc.smog_vpc.id
}

resource "aws_route_table_association" "rt_priv_asso1" {
    subnet_id       = aws_subnet.private_storage_compute1.id
    route_table_id  = aws_route_table.private_routes.id
}

resource "aws_route_table_association" "rt_priv_asso2" {
    subnet_id       = aws_subnet.private_storage_compute2.id
    route_table_id  = aws_route_table.private_routes.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_ep_rta" {
    route_table_id = aws_route_table.private_routes.id
    vpc_endpoint_id = aws_vpc_endpoint.private_s3_ep.id
}

# Load Balancers: Web Application Load Balancer

resource "aws_lb" "web_alb" {
  depends_on = [ aws_security_group.alb_sg ]
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
    
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = [aws_subnet.public_web1.id, aws_subnet.public_web2.id]
  tags = {
    Name = "Web Application Load Balancer"
  }
}

resource "aws_lb_target_group" "tg_web" {
  name     = "target-group-web"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.smog_vpc.id
  load_balancing_cross_zone_enabled = true
  health_check {
    path = "/"
    port = "traffic-port"
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
  }
}

resource "aws_lb_listener" "listener80" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg_web.arn
    type             = "forward"
  }
}

# Load Balancers: Computing-private subnet Application Load Balancer

resource "aws_lb" "priv_subnet_alb" {
  depends_on            = [aws_security_group.cpi_to_server_sg]
  name                  = "priv-subnet-alb"
  internal              = true
  load_balancer_type    = "application"
    
  security_groups       = [aws_security_group.cpi_to_server_sg.id]
  subnets               = [aws_subnet.private_storage_compute1.id, aws_subnet.private_storage_compute2.id]
  tags = {
    Name = "Computing-private subnet Application Load Balancer"
  }
}

resource "aws_lb_target_group" "tg_private_compute" {
  name     = "target-group-private-compute"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.smog_vpc.id
  load_balancing_cross_zone_enabled = true
  health_check {
    path = "/"
    port = "traffic-port"
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
  }
}

resource "aws_lb_listener" "listener_priv_80" {
  load_balancer_arn = aws_lb.priv_subnet_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg_private_compute.arn
    type             = "forward"
  }
}

# Auto Scalling Groups: Web Tier

resource "aws_autoscaling_group" "asg_web" {
    name                      = "Auto-Scalling-Group-Web-Tier"
    vpc_zone_identifier = [aws_subnet.public_web1.id, aws_subnet.public_web2.id]
    target_group_arns    = [aws_lb_target_group.tg_web.arn]
    max_size                  = 4
    min_size                  = 1
    desired_capacity          = 2
    health_check_grace_period = 120
    health_check_type         = "EC2"
    force_delete              = true
    launch_template {
    name = aws_launch_template.tmp_web_server.name
  }

  tag {
        key                   = "Name"
        value                 = "${aws_launch_template.tmp_web_server.name_prefix}"
        propagate_at_launch   = true
  }
}

resource "aws_autoscaling_attachment" "asg_web_atta" {
    autoscaling_group_name  = aws_autoscaling_group.asg_web.id
    lb_target_group_arn     = aws_lb_target_group.tg_web.arn 
}

# Auto Scalling Groups: Private-compute Tier

resource "aws_autoscaling_group" "asg_private_compute" {
    name                      = "Auto-Scalling-Group-Private-Compute-Tier"
    vpc_zone_identifier = [aws_subnet.private_storage_compute1.id, aws_subnet.private_storage_compute2.id]
    target_group_arns    = [aws_lb_target_group.tg_private_compute.arn]
    max_size                  = 4
    min_size                  = 1
    desired_capacity          = 2
    health_check_grace_period = 120
    health_check_type         = "EC2"
    force_delete              = true
    launch_template {
        name                  = aws_launch_template.tmp_training_instance.name
  }
    tag {
        key                   = "Name"
        value                 = "${aws_launch_template.tmp_training_instance.name_prefix}"
        propagate_at_launch   = true
  }
    
}

resource "aws_autoscaling_attachment" "asg_priv_compute_atta" {
    autoscaling_group_name  = aws_autoscaling_group.asg_private_compute.name
    lb_target_group_arn     = aws_lb_target_group.tg_private_compute.arn
}