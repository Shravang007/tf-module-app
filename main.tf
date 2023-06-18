#1. IAM Policy
resource "aws_iam_policy" "policy" {
  name        = "${var.component}-${var.env}-ssm-pm-policy"
  path        = "/"
  description = "${var.component}-${var.env}-ssm-pm-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" : "arn:aws:ssm:us-east-1:752442278108:parameter/roboshop.${var.env}.${var.component}.*"
      }
    ]
  })
}

##2. Iam Role

resource "aws_iam_role" "role" {
  name = "${var.component}-${var.env}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      ]
  })
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.component}-${var.env}-ec2-role"
  role = aws_iam_role.role.name
}

#3. Security Group

resource "aws_security_group" "sg" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}

#4. EC2 Instance

resource "aws_instance" "instance" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "${var.component}-${var.env}"
  }
}

#5. DNS Record (Route 53)

resource "aws_route53_record" "dns" {
  zone_id = "Z08411971YPWLUUTH65Y1"
  name    = "${var.component}-dev"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}

#6. Null Resource - Ansible

resource "null_resource" "ansible" {
  depends_on = [aws_instance.instance, aws_route53_record.dns]
  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = "centos"
      password = "DevOps321"
      host     = aws_instance.instance.public_ip
    }

    inline = [
      "sudo labauto ansible",
      "sudo set-hostname -skip-apply ${var.component}",
      "ansible-pull -i localhost, -U https://github.com/raghudevopsb73/roboshop-ansible main.yml -e env=${var.env} -e role_name=${var.component}"
    ]
  }
}

