#!/bin/bash

# =======================================
# Install Ansible on Ubuntu
# =======================================

set -e  # Exit on error

echo "🔄 Updating package list..."
apt update -y

echo "🔄 Installing prerequisites..."
apt install -y software-properties-common

echo "🔄 Adding Ansible PPA..."
add-apt-repository --yes --update ppa:ansible/ansible

echo "🔄 Installing Ansible..."
apt update -y
apt install -y ansible

echo "✅ Ansible installation completed."
ansible --version

# =======================================
# SSH Key setup TBD
# =======================================

