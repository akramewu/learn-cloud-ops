# How to Use

## 1. Deploy Infrastructure (Once)
```bash
cd day-4-iam-roles
terraform apply
```

## 2. Deploy Validation (Once)
```bash
cd ../validation-extension
terraform apply
```

## 3. Daily Use

**SSH to EC2:**
```bash
BASTION_IP=$(cd day-4-iam-roles && terraform output -raw bastion_public_ip)
PRIVATE_IP=$(cd day-4-iam-roles && terraform output -raw private_instance_private_ip)

ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyCommand="ssh -i ~/.ssh/akramul-key.pem -W %h:%p ubuntu@${BASTION_IP}" \
  ubuntu@${PRIVATE_IP}
```

**Deploy any container:**
```bash
docker run -d --name myapp -p 3000:3000 nginx:alpine
```

**Validate it:**
```bash
# From your Mac
cd validation-extension/scripts
./validate.sh myapp 3000
```

## Examples
```bash
# Nginx
docker run -d --name web -p 8080:80 nginx:alpine
./validate.sh web 8080

# Node.js
docker run -d --name api -p 3000:3000 node:18-alpine
./validate.sh api 3000

# Your app
docker run -d --name custom -p 5000:5000 yourapp:latest
./validate.sh custom 5000
```

## View Results
```bash
aws s3 ls s3://day-4-validation-results-*/results/ --recursive
```