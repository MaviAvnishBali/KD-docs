# Deployment Guide — Kila Darbar
## Production Deployment on AWS EKS

---

## Prerequisites

```bash
# Required tools
aws --version       # AWS CLI v2
kubectl version     # 1.30+
helm version        # 3.15+
terraform --version # 1.8+
docker --version    # 25+
```

---

## Step 1: AWS Infrastructure (Terraform)

```bash
cd devops/terraform

# Initialize
terraform init

# Plan
terraform plan -var-file=prod.tfvars -out=tfplan

# Apply
terraform apply tfplan

# Output
terraform output
# → eks_cluster_name
# → rds_endpoint
# → redis_endpoint
# → ecr_registry
```

**`prod.tfvars`:**
```hcl
environment       = "prod"
region            = "ap-south-1"
vpc_cidr          = "10.0.0.0/16"
eks_cluster_name  = "kila-darbar-prod"
eks_node_type     = "t3.medium"
eks_min_nodes     = 3
eks_max_nodes     = 20
rds_instance      = "db.r6g.large"
redis_node_type   = "cache.r6g.large"
db_name           = "kiladarbar"
s3_bucket         = "kiladarbar-media-prod"
```

---

## Step 2: Configure kubectl

```bash
aws eks update-kubeconfig \
  --name kila-darbar-prod \
  --region ap-south-1

kubectl get nodes
# Should list 3+ Ready nodes
```

---

## Step 3: Create Namespaces & Secrets

```bash
# Namespace
kubectl create namespace kila-darbar

# Secrets (replace values)
kubectl create secret generic kila-darbar-secrets \
  --namespace kila-darbar \
  --from-literal=db-url="jdbc:postgresql://<RDS_ENDPOINT>:5432/kiladarbar" \
  --from-literal=db-username="kiladarbar" \
  --from-literal=db-password="<DB_PASSWORD>" \
  --from-literal=jwt-secret="<64-char-random-string>" \
  --from-literal=razorpay-key-id="<RAZORPAY_KEY>" \
  --from-literal=razorpay-key-secret="<RAZORPAY_SECRET>" \
  --from-literal=aws-access-key="<AWS_KEY>" \
  --from-literal=aws-secret-key="<AWS_SECRET>"

# Firebase credentials
kubectl create secret generic firebase-credentials \
  --namespace kila-darbar \
  --from-file=firebase-service-account.json=./firebase-service-account.json

# ConfigMap
kubectl apply -f devops/kubernetes/configmaps/
```

---

## Step 4: Install Nginx Ingress Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"=nlb
```

---

## Step 5: Install Cert-Manager (SSL)

```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.15.0 \
  --set crds.enabled=true

# ClusterIssuer for Let's Encrypt
kubectl apply -f devops/kubernetes/ingress/cluster-issuer.yaml
```

---

## Step 6: Build & Push Docker Images

```bash
# Login to ECR
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com

# Build API
docker build -t kiladarbar/api:1.0.0 \
  -f devops/docker/Dockerfile.api \
  backend/kila-darbar-api/

# Tag & push
docker tag kiladarbar/api:1.0.0 \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/kila-darbar-api:1.0.0
docker push \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/kila-darbar-api:1.0.0

# Repeat for: customer-website, admin-dashboard, kds
```

---

## Step 7: Deploy to Kubernetes

```bash
# Apply all deployments
kubectl apply -f devops/kubernetes/deployments/ -n kila-darbar
kubectl apply -f devops/kubernetes/services/ -n kila-darbar
kubectl apply -f devops/kubernetes/hpa/ -n kila-darbar
kubectl apply -f devops/kubernetes/ingress/ -n kila-darbar

# Watch rollout
kubectl rollout status deployment/kila-darbar-api -n kila-darbar

# Verify pods
kubectl get pods -n kila-darbar
```

---

## Step 8: Database Migrations

Flyway runs automatically on API startup. To run manually:

```bash
# Port-forward for direct access
kubectl port-forward svc/kila-darbar-api 8080:8080 -n kila-darbar

# Check migration status
curl http://localhost:8080/api/actuator/flyway
```

---

## Step 9: Monitoring Setup

```bash
# Prometheus + Grafana via Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values devops/monitoring/prometheus/values.yaml

# Access Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
# Default: admin / prom-operator
```

---

## Step 10: DNS Configuration

```bash
# Get ALB DNS name
kubectl get svc ingress-nginx-controller -n ingress-nginx

# In AWS Route 53:
# api.kiladarbar.com    → ALB DNS (A record alias)
# kiladarbar.com        → ALB DNS (A record alias)
# admin.kiladarbar.com  → ALB DNS (A record alias)
# kds.kiladarbar.com    → ALB DNS (A record alias)
```

---

## Rollback Procedure

```bash
# Get revision history
kubectl rollout history deployment/kila-darbar-api -n kila-darbar

# Rollback to previous version
kubectl rollout undo deployment/kila-darbar-api -n kila-darbar

# Rollback to specific revision
kubectl rollout undo deployment/kila-darbar-api \
  --to-revision=3 -n kila-darbar

# Verify
kubectl rollout status deployment/kila-darbar-api -n kila-darbar
```

---

## Zero-Downtime Deployment Checklist

- [ ] Build passes in CI
- [ ] All tests green
- [ ] Security scan cleared
- [ ] New Docker image pushed to ECR
- [ ] Database migration tested on staging
- [ ] Rolling update strategy set (maxUnavailable: 0)
- [ ] Health checks configured
- [ ] Rollback plan ready
- [ ] Notify team on Slack before deployment
- [ ] Monitor Grafana for 15 minutes post-deploy
- [ ] Check error rate in Sentry
- [ ] Verify new features on production
- [ ] Update deployment log

---

## Environment URLs

| Environment | URL | Notes |
|---|---|---|
| Production API | https://api.kiladarbar.com | |
| Production Website | https://kiladarbar.com | |
| Admin Dashboard | https://admin.kiladarbar.com | VPN required |
| KDS | https://kds.kiladarbar.com | Kitchen-only |
| Staging API | https://staging-api.kiladarbar.com | |
| Swagger UI | https://api.kiladarbar.com/api/swagger-ui.html | |
| Grafana | https://monitoring.kiladarbar.com | VPN required |
