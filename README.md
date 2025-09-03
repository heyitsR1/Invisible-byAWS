
# 🌐 Personal VPN on AWS with WireGuard & Terraform

## Overview

This project deploys a **personal VPN server** using **AWS EC2**, **WireGuard**, and **Terraform**. It allows you to securely route your internet traffic through a private EC2 instance, providing encrypted internet access wherever you are.

The project demonstrates Infrastructure-as-Code (IaC) practices, secure networking, and practical knowledge of AWS services covered under the **AWS Solutions Architect Associate (SAA-C03)** certification.

---

## Architecture

```
[ Your Device ] <-- Encrypted Tunnel --> [ AWS EC2: WireGuard VPN ] --> Internet
```

---

## Technologies Used

- 🛠 **AWS EC2** — Virtual machine for hosting the VPN
- ⚙️ **Terraform** — Infrastructure provisioning (IaC)
- 🔒 **WireGuard** — Lightweight VPN software
- 🧱 **iptables** — NAT & traffic forwarding
- 📜 **Bash Script** — Automates server configuration

---

## Features

✅ Fully automated infrastructure deployment with Terraform  
✅ Secure, encrypted VPN connection using WireGuard  
✅ NAT and IP forwarding configured for internet access  
✅ Client configuration file generated automatically  
✅ Minimal open ports for enhanced security  

---

## Deployment Guide

### Prerequisites

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured
- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- SSH key pair for EC2 access
- Basic knowledge of terminal commands

---

### Step 1: Deploy Infrastructure with Terraform

Initialize and apply Terraform:

```bash
terraform init
terraform apply
```

Take note of the **EC2 public IP** once provisioning completes.

---

### Step 2: Connect to the EC2 Instance

SSH into the EC2 instance:

```bash
ssh -i path/to/your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

---

### Step 3: Install and Configure WireGuard

Run the setup script provided:

```bash
sudo bash wireguard-setup.sh
```

The script will:

- Install WireGuard and necessary dependencies
- Generate server & client key pairs
- Configure the VPN server
- Enable IP forwarding and NAT
- Generate a ready-to-use `client.conf` file

---

### Step 4: Configure Your VPN Client

Retrieve the generated client configuration:

```bash
cat /etc/wireguard/client.conf
```

Copy this file to your local device and import it into the WireGuard app (available for macOS, Windows, iOS, Android, Linux).

---

### Step 5: Connect and Verify

- Activate the VPN connection on your device.
- Visit [https://ifconfig.me](https://ifconfig.me) to verify your public IP — it should match your EC2 instance's IP.

---

## Security Considerations

- Only **UDP port 51820** is exposed for VPN traffic.
- SSH access is restricted via security groups.
- Private keys have strict permissions on the server.
- Consider assigning an Elastic IP for a persistent endpoint.

---

## How It Works

WireGuard establishes an encrypted tunnel between your device and the EC2 server. Traffic from your device is routed through the EC2, where NAT rules allow it to access the internet. Return traffic follows the same secure path back to you.

---

## Future Improvements

- Automate WireGuard setup with Terraform `user_data`
- Add support for multiple VPN clients
- Enable monitoring with AWS CloudWatch
- Implement Elastic IP for static VPN endpoint

---

## Learning Outcomes

✔ Practical AWS networking setup  
✔ Hands-on Terraform experience  
✔ VPN deployment with WireGuard  
✔ Understanding of IP forwarding & NAT  

---

## License

This project is for personal learning and demonstration purposes. Use responsibly.

---
##Credit & Inspiration

This project draws inspiration from [ravikiranvm/CloudVPN](https://github.com/ravikiranvm/CloudVPN)
, which offers a cost-effective, Terraform-driven, WireGuard-based personal VPN on AWS designed to run within free-tier limits 
GitHub
. Their streamlined and zero-cost approach provided the foundation and motivation for this project’s architecture.

### 🚀 Built to showcase AWS, Terraform, and VPN skills
