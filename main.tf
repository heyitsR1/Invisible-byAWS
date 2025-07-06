# === PROVIDER CONFIGURATION ===
provider "aws" {
  region = "eu-west-2"
}

# === DATA SOURCE FOR LATEST UBUNTU AMI ===
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# === VARIABLES ===
variable "public_key_path" {
  description = "Path to your SSH public key"
  default     = "~/.ssh/vpn-debug.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (your IP)"
  default     = "27.34.73.135/32"
}

# === KEY PAIR ===
resource "aws_key_pair" "vpn_key" {
  key_name   = "vpn-debug"
  public_key = file(var.public_key_path)
}

# === SECURITY GROUP ===
resource "aws_security_group" "vpn_sg" {
  name        = "vpn-sg"
  description = "Allow WireGuard and SSH access"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Allow WireGuard"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-security-group"
  }
}

# === EC2 INSTANCE ===
resource "aws_instance" "vpn_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.vpn_key.key_name
  vpc_security_group_ids      = [aws_security_group.vpn_sg.id]
  associate_public_ip_address = true

  user_data = base64encode(file("${path.module}/wireguard-setup.sh"))

  tags = {
    Name = "Personal-VPN-Server"
  }
}

# === OUTPUTS ===
output "vpn_server_ip" {
  description = "Public IP of the VPN server"
  value       = aws_instance.vpn_server.public_ip
}

output "connection_instructions" {
  description = "How to connect to your VPN"
  value = <<-EOT
    Your VPN server is ready at: ${aws_instance.vpn_server.public_ip}
    
    SSH into the server to get your client config:
    ssh -i ~/.ssh/vpn-debug ubuntu@${aws_instance.vpn_server.public_ip}
    
    Then run: sudo cat /etc/wireguard/client.conf
    
    Copy the output to your WireGuard client app.
  EOT
}