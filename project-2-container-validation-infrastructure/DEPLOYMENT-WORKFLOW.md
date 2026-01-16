# Complete Container Deployment Workflow - Universal Guide

## For All Application Types (Python, Node.js, Static Sites, Databases, etc.)

---

## TABLE OF CONTENTS

1. [Phase 1: Receive Developer Requirements](#phase-1-receive-developer-requirements)
2. [Phase 2: Write Dockerfile (DevOps Work)](#phase-2-write-dockerfile-devops-work)
3. [Phase 3: Local Build & Test](#phase-3-local-build--test)
4. [Phase 4: AWS Infrastructure Setup (One-Time)](#phase-4-aws-infrastructure-setup-one-time)
5. [Phase 5: Deploy to AWS EC2](#phase-5-deploy-to-aws-ec2)
6. [Phase 6: Validation](#phase-6-validation)
7. [Troubleshooting Guide](#troubleshooting-guide)
8. [Quick Reference Commands](#quick-reference-commands)

---

## PHASE 1: RECEIVE DEVELOPER REQUIREMENTS

### What Developer Team Provides

**Typical Files You'll Receive:**

**For Python Applications:**
- `app.py` or `main.py` (application code)
- `requirements.txt` (Python dependencies)

**For Node.js Applications:**
- `server.js` or `app.js` (application code)
- `package.json` (Node.js dependencies)

**For Static Websites:**
- `index.html`, CSS, JS files
- `dist/` or `build/` folder

**Developer Notes Usually Include:**
- Port number application runs on
- Environment variables needed
- Special configurations

### Step 1: Create Project Folder
```bash
# General pattern
mkdir -p ~/learn-cloud-ops/weekly-tasks/week-X/task-Y-<app-name>
cd ~/learn-cloud-ops/weekly-tasks/week-X/task-Y-<app-name>

# Example for Flask API (Week 1, Task 1)
mkdir -p ~/learn-cloud-ops/weekly-tasks/week-1/task-1-flask-api
cd ~/learn-cloud-ops/weekly-tasks/week-1/task-1-flask-api
```

### Step 2: Save All Developer Files
```bash
# Create files one by one
nano app.py              # Paste developer code
nano requirements.txt    # Paste dependencies
# etc.
```

**Verify all files saved:**
```bash
ls -la
```

---

## PHASE 2: WRITE DOCKERFILE (DEVOPS WORK)

### Analysis Framework

**Ask yourself these questions:**

1. **What programming language?**
   - Python → `python:3.11-slim`
   - Node.js → `node:18-alpine`
   - Static → `nginx:alpine`
   - Go → `golang:1.21-alpine`

2. **What dependencies are listed?**
   - Python: Check `requirements.txt`
   - Node.js: Check `package.json`
   - Other: Check documentation

3. **What port does it use?**
   - Look in application code for `port=`, `listen()`, etc.
   - Common ports: 3000, 5000, 8080

4. **How to run the application?**
   - Python: `python app.py`
   - Node.js: `node server.js` or `npm start`
   - Static: Nginx handles automatically

### Dockerfile Templates

#### Template 1: Python Application
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE <PORT>

CMD ["python", "<app-file>.py"]
```

**Example:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

#### Template 2: Node.js Application
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

EXPOSE <PORT>

CMD ["npm", "start"]
```

**Or with specific file:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]
```

#### Template 3: Static Website (Nginx)
```dockerfile
FROM nginx:alpine

COPY dist/ /usr/share/nginx/html/

EXPOSE 80
```

**Or if files in root:**
```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
COPY *.css /usr/share/nginx/html/
COPY *.js /usr/share/nginx/html/
EXPOSE 80
```

### Step-by-Step Dockerfile Writing

**Example: Flask Application Analysis**

**Developer gave:**
```python
# app.py
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def root():
    return jsonify({"message": "running"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```
```
# requirements.txt
Flask==3.0.0
```

**Your Analysis:**

1. **Language?** Python (`.py` file) → Base: `python:3.11-slim`
2. **Dependencies?** Flask (in requirements.txt) → Install via pip
3. **Port?** 5000 (in `app.run(port=5000)`) → Expose 5000
4. **Run command?** `python app.py` → CMD ["python", "app.py"]

**Write Dockerfile:**
```bash
nano Dockerfile
```

Paste:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

---

## PHASE 3: LOCAL BUILD & TEST

### Step 1: Build Docker Image
```bash
# Pattern
docker build -t <app-name>:v1 .

# Example
docker build -t flask-api:v1 .
```

**Expected Output:**
```
Successfully built <image-id>
Successfully tagged flask-api:v1
```

**Common Build Errors:**

**Error 1: Dockerfile not found**
```
unable to prepare context: unable to evaluate symlinks in Dockerfile path
```
**Solution:**
```bash
# Check you're in right directory
pwd
ls -la | grep Dockerfile

# Must be in same folder as Dockerfile
cd ~/learn-cloud-ops/weekly-tasks/week-X/task-Y-app/
docker build -t app:v1 .
```

**Error 2: Syntax error in Dockerfile**
```
unknown instruction: <line>
```
**Solution:**
- Check Dockerfile for typos
- Verify proper capitalization (FROM, COPY, RUN)
- Check line breaks and indentation

**Error 3: File not found during COPY**
```
COPY failed: file not found
```
**Solution:**
```bash
# List files in current directory
ls -la

# Make sure all files exist before building
# COPY looks in current directory, not inside container
```

### Step 2: Run Container Locally
```bash
# Pattern: docker run -d --name <container-name> -p <local-port>:<container-port> <image-name>

# Examples:
docker run -d --name test-app -p 8080:5000 flask-api:v1     # Flask on port 5000
docker run -d --name test-app -p 8080:3000 node-api:v1      # Node on port 3000
docker run -d --name test-app -p 8080:80 static-site:v1     # Nginx on port 80
```

**Port Mapping Explained:**
- `-p 8080:5000` means: Local port 8080 → Container port 5000
- Use different local port if 5000 occupied (common on macOS)

**Common Run Errors:**

**Error 1: Port already in use**
```
bind: address already in use
```
**Solution:**
```bash
# Option A: Use different local port
docker run -d --name test-app -p 8081:5000 app:v1

# Option B: Stop process using that port
lsof -i :<port>         # Find what's using the port
kill -9 <PID>           # Kill the process (careful!)

# Option C: Use high port number
docker run -d --name test-app -p 9000:5000 app:v1
```

**Error 2: Container name conflict**
```
Conflict. The container name "/test-app" is already in use
```
**Solution:**
```bash
# Remove old container
docker rm test-app

# Or remove with force
docker rm -f test-app

# Then run again
docker run -d --name test-app -p 8080:5000 app:v1
```

**Error 3: Container starts but immediately exits**
```
# docker ps shows nothing
```
**Solution:**
```bash
# Check all containers (including stopped)
docker ps -a

# Check logs for errors
docker logs test-app

# Common causes:
# - Application crashes on startup
# - Missing environment variables
# - Wrong CMD in Dockerfile
```

### Step 3: Test Application
```bash
# Pattern: curl http://localhost:<local-port><endpoint>

# Examples:
curl http://localhost:8080/                    # Root endpoint
curl http://localhost:8080/health              # Health check
curl http://localhost:8080/api/status          # API endpoint
```

**Test Checklist:**
- [ ] Application responds (not 404, 500, connection refused)
- [ ] JSON properly formatted (if API)
- [ ] HTML renders (if website)
- [ ] All documented endpoints work

### Step 4: Verify Container Running
```bash
# Check running containers
docker ps

# Check logs for errors
docker logs test-app

# Check last 20 lines
docker logs --tail 20 test-app

# Follow logs in real-time
docker logs -f test-app
```

### Step 5: Clean Up Local Test
```bash
# Stop container
docker stop test-app

# Remove container
docker rm test-app

# Verify removed
docker ps -a
```

---

## PHASE 4: AWS INFRASTRUCTURE SETUP (ONE-TIME)

**NOTE: This phase is done once. After initial setup, skip to Phase 5 for deployments.**

### Prerequisites Check
```bash
# 1. Check AWS credentials
aws sts get-caller-identity

# 2. Check Terraform installed
terraform version

# 3. Check SSH key exists
ls -la ~/.ssh/akramul-key.pem

# 4. Check correct directory
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure
```

### Step 1: Check if Infrastructure Already Deployed
```bash
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/day-4-iam-roles

# Check state
terraform state list

# If output shows resources, infrastructure is deployed
# SKIP TO STEP 4 (Get IPs)
```

### Step 2: Deploy Core Infrastructure (If Needed)
```bash
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/day-4-iam-roles

# Create terraform.tfvars (if doesn't exist)
cat > terraform.tfvars << EOF
project              = "day-4"
aws_region           = "eu-west-2"
availability_zone_a  = "eu-west-2a"
availability_zone_b  = "eu-west-2b"
environment          = "dev"
my_ip                = "REPLACE_WITH_YOUR_IP"
ami_id               = "ami-0c76bd4bd302b30ec"
instance_type        = "t2.micro"
ssh_key_name         = "akramul-key"
EOF

# Get your public IP
curl ifconfig.me

# Edit terraform.tfvars with your IP
nano terraform.tfvars
```

**Terraform Workflow:**
```bash
# Initialize (downloads providers)
terraform init

# Format code
terraform fmt

# Validate syntax
terraform validate

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply
```

**Type:** `yes` when prompted

**Wait:** 5-7 minutes

### Step 3: Deploy Validation System (If Needed)
```bash
cd ../validation-extension

# Create terraform.tfvars
cat > terraform.tfvars << EOF
project    = "day-4"
aws_region = "eu-west-2"
EOF

terraform init
terraform apply
```

**Type:** `yes` when prompted

**Wait:** 2-3 minutes

### Step 4: Extract Infrastructure IPs
```bash
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/day-4-iam-roles

# Method 1: Direct output
terraform output bastion_public_ip
terraform output private_instance_private_ip

# Method 2: Save to variables
BASTION_IP=$(terraform output -raw bastion_public_ip)
PRIVATE_IP=$(terraform output -raw private_instance_private_ip)

echo "Bastion IP:  $BASTION_IP"
echo "Private IP:  $PRIVATE_IP"
```

**Save these IPs** - Write them down or save to a text file:
```bash
# Save to file
cat > ~/infrastructure-ips.txt << EOF
Bastion IP:  $BASTION_IP
Private IP:  $PRIVATE_IP
EOF
```

### Step 5: SSH Setup & Verification (One-Time)

**🔒 SECURITY BEST PRACTICE: Private keys must NEVER be copied to servers.**

#### ✅ Correct SSH Access Pattern
```bash
# Your SSH key stays ONLY on your Mac
# Bastion acts as a jump host (ProxyJump)

# One-time setup: Verify key permissions
chmod 400 ~/.ssh/akramul-key.pem

# Test bastion connection
ssh -i ~/.ssh/akramul-key.pem ubuntu@<BASTION_IP>
# Should connect successfully
exit

# Test direct access to Private EC2 (via bastion jump)
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP>
# Should connect successfully
exit
```

**Why ProxyJump is correct:**
- ✅ Key stays on local machine
- ✅ Bastion only forwards connection
- ✅ No key proliferation
- ✅ Industry security standard

---

## PHASE 5: DEPLOY TO AWS EC2

**This phase is repeated for every new application deployment.**

### Deployment Flowchart
```
Mac (Local) 
    ↓ Direct transfer via ProxyJump
Private EC2 (Final destination - Docker build & run here)
```

### Step 1: Transfer Application Files to Private EC2

**✅ Direct transfer via ProxyJump (Single Command):**
```bash
# Go to your application folder
cd ~/learn-cloud-ops/weekly-tasks/week-X/task-Y-<app-name>

# Verify files exist
ls -la

# Transfer directly to Private EC2 (via bastion jump)
scp -i ~/.ssh/akramul-key.pem -r \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  /Users/mdakramulislam/learn-cloud-ops/weekly-tasks/week-X/task-Y-<app-name> \
  ubuntu@<PRIVATE_IP>:/home/ubuntu/
```

**Example:**
```bash
scp -i ~/.ssh/akramul-key.pem -r \
  -o ProxyJump=ubuntu@13.135.129.167 \
  /Users/mdakramulislam/learn-cloud-ops/weekly-tasks/week-1/task-1-flask-api \
  ubuntu@10.0.10.79:/home/ubuntu/
```

**Expected Output:**
```
requirements.txt     100%
Dockerfile           100%
app.py               100%
```

**If SCP Fails:**

**Error: Permission denied**
```bash
# Check key permissions
chmod 400 ~/.ssh/akramul-key.pem

# Try again
```

**Error: No such file or directory**
```bash
# Use absolute path, not relative
# Wrong: scp -r task-1-flask-api ubuntu@IP:~/
# Right:  scp -r /Users/mdakramulislam/learn-cloud-ops/weekly-tasks/week-1/task-1-flask-api ubuntu@IP:~/
```

### Step 2: Login to Private EC2

**✅ Direct connection via ProxyJump:**
```bash
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP>
```

**Example:**
```bash
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyJump=ubuntu@13.135.129.167 \
  ubuntu@10.0.10.79
```

**Verify folder transferred:**
```bash
ls -la
# Should see your folder
# Example: task-1-flask-api/

cd task-Y-<app-name>
ls -la
# Should see all files (Dockerfile, app files, etc.)
```

### Step 3: Build Docker Image on EC2
```bash
# Navigate to application folder
cd ~/task-Y-<app-name>

# Verify Dockerfile exists
ls -la | grep Dockerfile

# Build image
docker build -t <app-name>-prod:v1 .
```

**Wait for build to complete (1-3 minutes depending on dependencies)**

**Expected Output:**
```
Successfully built <image-id>
Successfully tagged <app-name>-prod:v1
```

**Build Errors on EC2:**

**Error: Dockerfile not found**
```
lstat /home/ubuntu/Dockerfile: no such file or directory
```
**Solution:**
```bash
# Check current directory
pwd

# Should be: /home/ubuntu/task-Y-<app-name>
# If not, navigate there
cd ~/task-Y-<app-name>

# Verify Dockerfile exists
ls -la

# Build again
docker build -t app-prod:v1 .
```

**Error: Cannot connect to Docker daemon**
```
Cannot connect to the Docker daemon
```
**Solution:**
```bash
# Check Docker service
sudo systemctl status docker

# If not running
sudo systemctl start docker

# Add user to docker group (if needed)
sudo usermod -aG docker ubuntu

# Logout and login again
exit
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP>
```

### Step 4: Run Container on EC2
```bash
# Stop any existing container with same name (if redeploying)
docker stop <container-name> 2>/dev/null || true
docker rm <container-name> 2>/dev/null || true

# Run new container
docker run -d \
  --name <container-name> \
  -p <port>:<port> \
  <app-name>-prod:v1
```

**Examples:**
```bash
# Flask API
docker run -d --name flask-api -p 5000:5000 flask-api-prod:v1

# Node API
docker run -d --name node-api -p 3000:3000 node-api-prod:v1

# Static site
docker run -d --name static-site -p 80:80 static-site-prod:v1
```

### Step 5: Verify Container Running
```bash
# Check running containers
docker ps

# Should see your container with "Up X seconds" status
```

**Expected Output:**
```
CONTAINER ID   IMAGE                   STATUS          PORTS
abc123def456   flask-api-prod:v1       Up 5 seconds    0.0.0.0:5000->5000/tcp
```

**Container Status Issues:**

**Container not in list:**
```bash
# Check all containers (including stopped)
docker ps -a

# If container exited immediately, check logs
docker logs <container-name>
```

**Common exit reasons:**
- Application crashes on startup (check logs)
- Port already in use on EC2 (choose different port)
- Missing dependencies (rebuild image)

### Step 6: Test on EC2
```bash
# Test endpoint from within EC2
curl http://localhost:<port>/

# Test specific endpoints
curl http://localhost:<port>/health
curl http://localhost:<port>/api/status
```

**Expected:** Application responds (200 OK, valid JSON/HTML)

### Step 7: Exit Back to Mac
```bash
exit  # Exit from Private EC2 → back to Mac
```

---

## PHASE 6: VALIDATION

**This confirms your deployment is accessible and working correctly.**

### Step 1: Run Validation Script
```bash
# Navigate to validation scripts folder
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/validation-extension/scripts

# Run validation
./validate.sh <container-name> <port>
```

**Examples:**
```bash
./validate.sh flask-api 5000
./validate.sh node-api 3000
./validate.sh static-site 80
./validate.sh postgres-db 5432
```

**Expected Output:**
```json
{
  "container": "flask-api",
  "port": 5000,
  "status": "Up 2 minutes",
  "http_code": "200",
  "timestamp": "2026-01-15T08:20:42Z"
}
upload: ... to s3://day-4-validation-results-.../results/...
Done
```

**Validation Status Meanings:**

- **http_code: "200"** ✅ Success - Application responding correctly
- **http_code: "404"** ⚠️ Endpoint not found - Check application routes
- **http_code: "500"** ❌ Server error - Check application logs
- **http_code: "000"** ❌ Connection failed - Container not running or wrong port

**If Validation Fails:**

**Problem: HTTP 404**
```json
"http_code": "404"
```
**Cause:** validate.sh tests root endpoint `/` but your app doesn't have it

**Solution:** Add root endpoint to your application
```python
# For Flask
@app.route('/')
def root():
    return jsonify({"status": "ok"})
```
```javascript
// For Node.js
app.get('/', (req, res) => {
  res.json({ status: 'ok' });
});
```

**Problem: HTTP 000**
```json
"http_code": "000"
```
**Cause:** Container not running or wrong port

**Solution:**
```bash
# SSH back to EC2
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP>

# Check container
docker ps

# Check logs
docker logs <container-name>

# Restart if needed
docker restart <container-name>
```

### Step 2: View S3 Results
```bash
# List all validation results
aws s3 ls s3://day-4-validation-results-*/results/

# View latest result
aws s3 cp s3://day-4-validation-results-*/results/<latest-file>.json - | python3 -m json.tool
```

### Step 3: Document Completion
```bash
# Create task summary
mkdir -p ~/learn-cloud-ops/weekly-tasks/week-X
cd ~/learn-cloud-ops/weekly-tasks/week-X

cat > task-Y-summary.txt << EOF
TASK-00Y: <Application Name> Deployment
========================================

Container Name: <container-name>
Port: <port>
Image: <app-name>-prod:v1

Files Created:
- Dockerfile
- <list other files>

Issues Faced:
1. <describe issue> - <solution>

Time Taken: ~X hours

S3 Result: <filename>.json
Status: COMPLETE ✅
EOF
```

---

## TROUBLESHOOTING GUIDE

### SSH Connection Issues

**Problem: Cannot SSH to Bastion**

**Error:**
```
Permission denied (publickey)
```

**Solutions:**
```bash
# 1. Check key permissions
chmod 400 ~/.ssh/akramul-key.pem

# 2. Verify key exists
ls -la ~/.ssh/akramul-key.pem

# 3. Check IP is correct
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/day-4-iam-roles
terraform output bastion_public_ip

# 4. Try with verbose output
ssh -v -i ~/.ssh/akramul-key.pem ubuntu@<BASTION_IP>
```

**Problem: Cannot SSH to Private EC2 via ProxyJump**

**Error:**
```
Permission denied (publickey)
```

**Solutions:**
```bash
# 1. Check key permissions on LOCAL machine
chmod 400 ~/.ssh/akramul-key.pem

# 2. Test bastion connection first
ssh -i ~/.ssh/akramul-key.pem ubuntu@<BASTION_IP>
# Should work
exit

# 3. Test ProxyJump with verbose
ssh -v -i ~/.ssh/akramul-key.pem \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP>

# 4. Try with StrictHostKeyChecking disabled
ssh -i ~/.ssh/akramul-key.pem \
  -o StrictHostKeyChecking=no \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP>
```

**Common ProxyJump Errors:**

**Error: "Host key verification failed"**
```bash
# Solution: Accept host key
ssh -i ~/.ssh/akramul-key.pem \
  -o StrictHostKeyChecking=no \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP>
```

**Error: "Connection timed out"**
```bash
# Check security group allows your IP
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/day-4-iam-roles

# Get your current IP
curl ifconfig.me

# Update terraform.tfvars with new IP
nano terraform.tfvars

# Apply changes
terraform apply
```

### Docker Build Issues

**Problem: Dockerfile syntax errors**

**Error:**
```
unknown instruction: <WORD>
```

**Solutions:**
```bash
# Check instruction capitalization
# Correct: FROM, RUN, COPY, CMD, EXPOSE
# Wrong:   from, run, copy

# Check for typos
# Correct: WORKDIR
# Wrong:   WORKINGDIR, WORKDIRECTORY

# Validate format
docker build -t test:v1 . --no-cache
```

**Problem: COPY fails - file not found**

**Error:**
```
COPY failed: file not found in build context
```

**Solution:**
```bash
# List files in current directory
ls -la

# Files must be in same directory as Dockerfile
# Wrong directory structure:
# /home/user/
#   ├── Dockerfile
#   └── src/
#       └── app.py    # COPY app.py won't find this

# Correct directory structure:
# /home/user/project/
#   ├── Dockerfile
#   └── app.py        # COPY app.py works
```

### Docker Run Issues

**Problem: Port already in use**

**Error:**
```
bind: address already in use
```

**Solutions:**
```bash
# Option 1: Stop existing container
docker ps
docker stop <container-using-port>
docker rm <container-using-port>

# Option 2: Use different port
docker run -d --name app -p 8081:5000 app:v1  # Instead of 8080

# Option 3: Kill process using port (careful!)
lsof -i :5000
kill -9 <PID>
```

**Problem: Container exits immediately**

**Error:**
```
# docker ps shows nothing
```

**Solutions:**
```bash
# Check exit status
docker ps -a

# View logs
docker logs <container-name>

# Common causes:
# 1. Application crash - fix code
# 2. Wrong CMD - check Dockerfile
# 3. Missing dependencies - rebuild image
# 4. Port conflicts - change port

# Run interactively to debug
docker run -it --rm <image-name> /bin/sh
```

### Application Issues

**Problem: 404 Not Found**

**Cause:** Endpoint doesn't exist

**Solutions:**
```bash
# Check what endpoints your application has
# For Flask: look at @app.route()
# For Node: look at app.get(), app.post()

# Add missing root endpoint if needed
# Flask:
@app.route('/')
def root():
    return jsonify({"status": "ok"})

# Node.js:
app.get('/', (req, res) => {
  res.json({ status: 'ok' });
});
```

**Problem: 500 Internal Server Error**

**Cause:** Application crash

**Solutions:**
```bash
# Check container logs
docker logs <container-name>

# Common causes:
# - Missing environment variables
# - Database connection failed
# - Syntax errors in code

# Fix code and redeploy
```

### Terraform Issues

**Problem: State lock error**

**Error:**
```
Error acquiring the state lock
```

**Solution:**
```bash
# Force unlock (use carefully!)
terraform force-unlock <LOCK_ID>

# Or wait and try again
```

**Problem: Resource already exists**

**Error:**
```
resource already exists
```

**Solution:**
```bash
# Import existing resource
terraform import <resource> <id>

# Or destroy and recreate
terraform destroy
terraform apply
```

---

## QUICK REFERENCE COMMANDS

### Local Development
```bash
# Build image
docker build -t <app>:v1 .

# Run locally
docker run -d --name test -p 8080:<port> <app>:v1

# Test
curl http://localhost:8080/

# Clean up
docker stop test && docker rm test
```

### Get Infrastructure IPs
```bash
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/day-4-iam-roles
terraform output bastion_public_ip
terraform output private_instance_private_ip
```

### Deploy to EC2 (Complete Flow)
```bash
# 1. Transfer directly to Private EC2 (one command)
scp -i ~/.ssh/akramul-key.pem -r \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  /Users/mdakramulislam/learn-cloud-ops/weekly-tasks/week-X/task-Y-app \
  ubuntu@<PRIVATE_IP>:/home/ubuntu/

# 2. Login to Private EC2
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP>

# 3. Build and run
cd ~/task-Y-app
docker build -t app-prod:v1 .
docker run -d --name app -p <port>:<port> app-prod:v1
curl http://localhost:<port>/
exit

# 4. Validate
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/validation-extension/scripts
./validate.sh app <port>
```

### Docker Management on EC2
```bash
# List running containers
docker ps

# List all containers
docker ps -a

# View logs
docker logs <container-name>

# Follow logs
docker logs -f <container-name>

# Stop container
docker stop <container-name>

# Remove container
docker rm <container-name>

# Restart container
docker restart <container-name>

# Remove all stopped containers
docker container prune
```

### SSH Quick Commands
```bash
# Connect to Private EC2 (one command, key stays local)
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP>

# Transfer files (one command)
scp -i ~/.ssh/akramul-key.pem -r \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  /local/path/app \
  ubuntu@<PRIVATE_IP>:/home/ubuntu/

# Run remote command
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyJump=ubuntu@<BASTION_IP> \
  ubuntu@<PRIVATE_IP> "docker ps"
```

---

## 🔒 SECURITY BEST PRACTICES

### SSH Key Management

**✅ DO:**
- Keep private keys ONLY on local machine
- Use ProxyJump for bastion access
- Use `chmod 400` on private keys
- Use IAM roles for AWS service access

**❌ DON'T:**
- Copy private keys to servers
- Store keys in code repositories
- Share keys via email/Slack
- Use same key for multiple environments

### Interview Answer (Memorize)

**Q: How do you access private EC2 instances?**

> "I use SSH ProxyJump through a bastion host, keeping private keys only on my local machine. This prevents key proliferation and follows AWS security best practices. In production, we'd use AWS Systems Manager Session Manager or CI/CD pipelines, but for development, ProxyJump provides secure, auditable access."

---

## DEPLOYMENT CHECKLIST

Use this checklist for every deployment:

### Pre-Deployment
- [ ] Received all files from developer
- [ ] Created project folder
- [ ] Analyzed application requirements
- [ ] Written Dockerfile
- [ ] Built image locally
- [ ] Tested locally (curl endpoints)
- [ ] Cleaned up local test

### Deployment
- [ ] Got Bastion and Private IPs
- [ ] Transferred files to Private EC2 (via ProxyJump)
- [ ] Connected to Private EC2 (via ProxyJump)
- [ ] Built image on EC2
- [ ] Ran container on EC2
- [ ] Tested on EC2 (curl endpoints)
- [ ] Exited back to Mac

### Validation
- [ ] Ran validate.sh script
- [ ] Got HTTP 200 response
- [ ] Checked S3 for results
- [ ] Documented completion

### Optional
- [ ] Took screenshots
- [ ] Updated weekly summary
- [ ] Cleaned up old containers

---

## NEXT STEPS

After completing a deployment:

1. **Document lessons learned**
2. **Note any issues and solutions**
3. **Update weekly summary**
4. **Prepare for next task**

---

**This guide works for ANY containerized application. Follow these phases systematically for consistent, successful deployments.**