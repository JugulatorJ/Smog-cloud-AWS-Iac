# Security Groups

resource "aws_security_group" "alb_sg" {
    name        = "web-open-ALB-SG"
    vpc_id = aws_vpc.smog_vpc.id
    description = "Allow inbound HTTP and HTTPS traffic from internet to App Load Balancer"

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
            Name = "web open ALB SG"
            }

    lifecycle {
                create_before_destroy = true
                }
}

resource "aws_security_group" "web_server_sg" {
    name        = "web-server-sg"
    vpc_id = aws_vpc.smog_vpc.id
    description = "SG between web opened ALB and web servers"

    ingress { 
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        security_groups = ["${aws_security_group.alb_sg.id}"]
        }

    ingress {
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        security_groups = ["${aws_security_group.alb_sg.id}"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
            Name = "web server sg"
            }

}


resource "aws_security_group" "priv_ep_sg" {
    name        = "ssm endpoint sg"
    vpc_id = aws_vpc.smog_vpc.id
    description = "SG for SSM VPC endpoint"

    ingress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
            Name = "ssm endpoint sg"
            }

    lifecycle {
                create_before_destroy = true
                }
}

resource "aws_security_group" "cpi_to_server_sg" {
    
    name        = "cpi-server-open-sg"
    vpc_id      = aws_vpc.smog_vpc.id
    description = "Allow both way traffic between computing instance and web server"
    
    ingress {
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        security_groups     = ["${aws_security_group.web_server_sg.id}"]
    }

    ingress {
        from_port           = 443
        to_port             = 443
        protocol            = "tcp"
        security_groups     = ["${aws_security_group.web_server_sg.id}"]
    }

    egress {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
    }

    tags = {
            Name = "cpi server open sg"
            }

    lifecycle {
                create_before_destroy = true
                }
}