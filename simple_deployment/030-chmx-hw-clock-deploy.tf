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

resource "aws_internet_gateway" "chmx-hw-main-IGW" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "main-pub" {
  vpc                       = true
  network_interface         = aws_network_interface.chmx-interface.id
  associate_with_private_ip = "10.0.1.100"
}

resource "aws_route_table" "PubToExt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chmx-hw-main-IGW.id
  }
}

resource "aws_route_table_association" "PubRouteassociation" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.PubToExt.id
}

resource "aws_instance" "chmx-szmeier" {

  ami           = "ami-0e322da50e0e90e21"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.chmx-interface.id
    device_index         = 0
  }
  user_data = <<-EOF
    #!/bin/bash
    set -ex
    yum update -y
    amazon-linux-extras install docker -y
    usermod -a -G docker ec2-user
    systemctl enable docker 
    systemctl start docker 
    until sudo docker images 2&> /dev/null; do  
        echo "Waiting for docker to start..." > /var/log/userdata.log;
        sleep 5; 
    done
    docker pull public.ecr.aws/f4k7i4s0/chmx-szmeier:latest
    docker run -p 80:5000 -d public.ecr.aws/f4k7i4s0/chmx-szmeier:latest > /var/log/clockapp.log
  EOF

}
