# This file defines EC2 resources: launch templates.

# EC2 instances launch templates

resource "aws_launch_template" "tmp_web_server" {
    depends_on = [ aws_security_group.web_server_sg ]
    name_prefix     = "web_server"
    image_id        = var.os_linux_image
    instance_type   = var.EC2_type
    vpc_security_group_ids = [aws_security_group.web_server_sg.id]

    block_device_mappings {
    device_name     = "/dev/sdf"

    ebs {
      volume_size   = 1
    }
    }

    iam_instance_profile {
    name = aws_iam_instance_profile.dev_web_server_iam_profile.name
    }

    user_data = filebase64(var.user_data_web_server)
    tags = {
            Name = "Web server"
    }
}

resource "aws_launch_template" "tmp_training_instance" {
    name_prefix     = "training_instance"
    image_id        = var.os_linux_image
    instance_type   = var.EC2_type

    block_device_mappings {
    device_name     = "/dev/sdf"

    ebs {
      volume_size   = 1
    }
    }

    vpc_security_group_ids = [aws_security_group.cpi_to_server_sg.id]

    iam_instance_profile {
    name = aws_iam_instance_profile.dev_training_instance_iam_profile.name
    }

    user_data = filebase64(var.user_data_training_instance)
    tags = {
            Name = "Training instance"
    }
}


