# Create VPC
resource "aws_vpc" "bootcamp-demo-test-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "name" = "Bootcamp Demo VPC"
  }
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Allow SSH and http access from a specific IPs"
  vpc_id = aws_vpc.bootcamp-demo-test-vpc.id
  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.sshIPs  
  }
  ingress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.sshIPs 
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "bootcamp-demo-test-igw" {
  vpc_id = aws_vpc.bootcamp-demo-test-vpc.id
}

# Create Route Table
resource "aws_route_table" "bootcamp-demo-test-route-table" {
  vpc_id = aws_vpc.bootcamp-demo-test-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bootcamp-demo-test-igw.id
  }
}
# Set Route Table as Main
resource "aws_main_route_table_association" "main_route_table" {
  vpc_id         = aws_vpc.bootcamp-demo-test-vpc.id
  route_table_id = aws_route_table.bootcamp-demo-test-route-table.id
  depends_on = [ aws_vpc.bootcamp-demo-test-vpc,aws_subnet.bootcamp-demo-test-subnet,aws_subnet.bootcamp-demo-test-subnet2,aws_internet_gateway.bootcamp-demo-test-igw ]
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.bootcamp-demo-test-subnet.id
  route_table_id = aws_route_table.bootcamp-demo-test-route-table.id
}

# Create Subnet1
resource "aws_subnet" "bootcamp-demo-test-subnet" {
  vpc_id                  = aws_vpc.bootcamp-demo-test-vpc.id
  cidr_block              = "10.0.0.0/22"
  availability_zone       = "eu-central-1a"
}
# Create Subnet2
resource "aws_subnet" "bootcamp-demo-test-subnet2" {
  vpc_id                  = aws_vpc.bootcamp-demo-test-vpc.id
  cidr_block              = "10.0.4.0/22"
  availability_zone       = "eu-central-1b"
}
# Define the IAM role
resource "aws_iam_role" "bootcamp-demo-test-iam-role" {
  name               = "bootcamp-demo-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
# Define the IAM instance profile
resource "aws_iam_instance_profile" "bootcamp-demo-test-iam-profile" {
  name  = "bootcamp-instance-profile"
  role = aws_iam_role.bootcamp-demo-test-iam-role.name
}

resource "aws_instance" "ec2_instance" {
  ami           = var.amiID  # Replace with your desired AMI ID
  instance_type = var.instance-type  # Replace with your desired instance type
  key_name               = "test"  # Replace with your existing key pair name
  vpc_security_group_ids =  [aws_security_group.ssh_access.id]
  subnet_id              = aws_subnet.bootcamp-demo-test-subnet.id
  associate_public_ip_address = true  # Set to true for public IP assignment
  iam_instance_profile = aws_iam_instance_profile.bootcamp-demo-test-iam-profile.name
  tags = {
    Environment = "bootcamp-demo"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg nginx -y

# Configure Nginx to serve a default page
echo "server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html index.htm;
    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }
}" | sudo tee /etc/nginx/sites-available/default > /dev/null
cd /var/www/html/ && sudo git clone https://github.com/olesiakissa/space-tourism-website.git && sudo mv space-tourism-website/* .
sudo systemctl restart nginx


EOF
}