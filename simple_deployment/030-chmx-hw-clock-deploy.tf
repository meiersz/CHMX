resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "chmx-hw-szmeier-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "chmx-hw-szmeier-snet"
  }
}

resource "aws_network_interface" "chmx-interface" {
  subnet_id   = aws_subnet.main.id
  private_ips = ["10.0.1.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "chmx-szmeier" {

  ami           = "ami-0c293f3f676ec4f90"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.chmx-interface.id
    device_index         = 0
  }
  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
  EOF

}
