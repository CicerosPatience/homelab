#!/bin/bash

# =======================================
# Install Ansible on Ubuntu
# =======================================

set -e  # Exit on error

echo "🔄 Updating package list..."
sudo apt update -y

echo "🔄 Installing prerequisites..."
sudo apt install -y software-properties-common

echo "🔄 Adding Ansible PPA..."
sudo add-apt-repository --yes --update ppa:ansible/ansible

echo "🔄 Installing Ansible..."
sudo apt update -y
sudo apt install -y ansible

echo "✅ Ansible installation completed."
ansible --version

# =======================================
# SSH Key setup
# =======================================

SSH_KEY="$HOME/.ssh/id_rsa"

if [ -f "$SSH_KEY" ]; then
    echo "ℹ️ SSH key already exists at $SSH_KEY. Skipping key generation."
else
    echo "🔑 Generating new SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N ""
    echo "✅ SSH key generated!"
fi
echo "Private key: $SSH_KEY"
echo "Public key : ${SSH_KEY}.pub"