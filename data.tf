data "aws_ami" "ami" {
  owners      = ["752442278108"]
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
}