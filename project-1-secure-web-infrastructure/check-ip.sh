#!/bin/bash

CURRENT_IP=$(curl -4 -s ifconfig.me)
TFVARS_IP=$(grep my_ip day-4-iam-roles/terraform.tfvars | cut -d'"' -f2)

echo "Current IP:     $CURRENT_IP"
echo "terraform.tfvars: $TFVARS_IP"

if [ "$CURRENT_IP" != "$TFVARS_IP" ]; then
  echo ""
  echo "⚠️  WARNING: IPs don't match!"
  echo "Update terraform.tfvars before deploying!"
  exit 1
else
  echo ""
  echo "✅ IP matches! Ready to deploy."
fi
