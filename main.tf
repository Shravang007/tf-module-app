#1.Policy

resource "aws_iam_policy" "policy" {
  name        = "${var.component}-${var.env}-ssm-pm-policy"
  path        = "/"
  description = "${var.component}-${var.env}-ssm-pm-policy"

  policy = jsonencode({

  {
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
    "Resource" : "arn:aws:ssm:us-east-1:752442278108:parameter/roboshop.dev.frontend.*"
  }
  ]
  } )
  }
    }


#2.Iam Role

    resource "aws_iam_role" "role" {
      name = "${var.component}-${var.env}-ec2-role"

      assume_role_policy = jsonencode({
      {
        "Version" : "2012-10-17",
        "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
        "Service" : "ec2.amazonaws.com"
      },
        "Action" : "sts:AssumeRole"
      }
      ]
      } )
      }
        }

        resource "aws_iam_instance_profile" "instance_profile" {
          name = "${var.component}-${var.env}-ec2-role"
          role = aws_iam_role.role.name
        }

          resource "aws_iam_role_policy_attachment" "policy-attach" {
          role       = aws_iam_role.role.name
          policy_arn = aws_iam_policy.policy.arn
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

          tags = merge({
            Name = "${var.component}-${var.env}"
          },
            var.tags)

        }
#5. DNS Records (Route 53)
#
#
#6. Null Resource - Ansible
