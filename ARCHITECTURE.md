# System Architecture — Kila Darbar
## Production Cloud Architecture on AWS

---

## Architecture Diagram

```
╔══════════════════════════════════════════════════════════════════╗
║                         CLIENTS                                  ║
║  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────┐          ║
║  │Android  │  │iOS App  │  │Website  │  │Admin/KDS │          ║
║  │  App    │  │(SwiftUI)│  │(Next.js)│  │(React)   │          ║
║  └────┬────┘  └────┬────┘  └────┬────┘  └────┬─────┘          ║
╚═══════╪════════════╪════════════╪═════════════╪═════════════════╝
        │            │            │             │
        ▼            ▼            ▼             ▼
╔═══════════════════════════════════════════════════════════════╗
║                    AWS CloudFront CDN                          ║
║         (Static assets, API response caching)                  ║
╚═══════════════════════════┬═══════════════════════════════════╝
                            │
╔═══════════════════════════▼═══════════════════════════════════╗
║              Application Load Balancer (ALB)                   ║
║         SSL Termination | WAF | Rate Limiting                  ║
╚═══════╤═══════════════╤══════════════╤══════════════╤══════════╝
        │               │              │              │
        ▼               ▼              ▼              ▼
╔═══════════╗  ╔════════════╗  ╔════════════╗  ╔═══════════╗
║ API Pods  ║  ║Website Pods║  ║Admin Pods  ║  ║ KDS Pods  ║
║  (3–20x)  ║  ║  (2–5x)   ║  ║  (1–3x)   ║  ║  (1–3x)   ║
╚═════╤═════╝  ╚════════════╝  ╚════════════╝  ╚═══════════╝
      │
      ├──────────────────────────────────────┐
      ▼                                      ▼
╔═══════════════╗                    ╔═══════════════╗
║  PostgreSQL   ║                    ║  Redis Cache  ║
║  RDS Multi-AZ ║                    ║  (ElastiCache)║
║  Primary +    ║                    ║  Sessions     ║
║  Read Replica ║                    ║  Cart/Cache   ║
╚═══════════════╝                    ╚═══════════════╝
      │
      ▼
╔═══════════════╗    ╔═══════════════╗    ╔═══════════════╗
║ Elasticsearch ║    ║    AWS S3      ║    ║    Firebase   ║
║ (Menu Search) ║    ║ (Media/Images)║    ║ (Push Notifs) ║
╚═══════════════╝    ╚═══════════════╝    ╚═══════════════╝
```

---

## AWS Region: ap-south-1 (Mumbai)

### VPC Architecture
- **CIDR:** 10.0.0.0/16
- **Public Subnets (2 AZs):** 10.0.1.0/24, 10.0.2.0/24 (ALB, NAT Gateway)
- **Private App Subnets (2 AZs):** 10.0.10.0/24, 10.0.11.0/24 (EKS nodes)
- **Private DB Subnets (2 AZs):** 10.0.20.0/24, 10.0.21.0/24 (RDS, Redis)

### Security Groups
| SG | Inbound | Outbound |
|---|---|---|
| ALB | 80/443 from 0.0.0.0/0 | All to App nodes |
| App Nodes | 8080 from ALB SG | DB SGs, Redis SG, internet |
| RDS | 5432 from App Nodes SG | None |
| Redis | 6379 from App Nodes SG | None |
| Elasticsearch | 9200 from App Nodes SG | None |

---

## Kubernetes Architecture (EKS)

### Namespace: kila-darbar
```
kila-darbar/
├── Deployments
│   ├── kila-darbar-api          # 3–20 replicas (HPA)
│   ├── kila-darbar-website      # 2–5 replicas
│   ├── kila-darbar-admin        # 1–3 replicas
│   └── kila-darbar-kds          # 1–3 replicas
├── Services
│   ├── api-service              # ClusterIP
│   ├── website-service          # ClusterIP
│   ├── admin-service            # ClusterIP
│   └── kds-service              # ClusterIP
├── Ingress
│   └── nginx-ingress            # ALB Ingress Controller
├── HPA
│   └── api-hpa (cpu 60%, mem 70%)
├── ConfigMaps
│   └── kila-darbar-config
└── Secrets
    └── kila-darbar-secrets
```

---

## Data Architecture

### PostgreSQL (Primary Data Store)
- Instance: `db.r6g.large` (8GB RAM) → `db.r6g.xlarge` on scale
- Multi-AZ: Yes (automatic failover)
- Read Replica: 1 (for analytics + reporting)
- Storage: 100GB gp3 SSD (auto-scaling to 1TB)
- Backup: 7-day automated backup + manual before deployments
- Parameter Group:
  ```
  max_connections = 200
  shared_buffers = 2GB
  effective_cache_size = 6GB
  work_mem = 50MB
  checkpoint_completion_target = 0.9
  ```

### Redis (Cache + Sessions + Real-time)
- `cache.r6g.large` (6.38GB)
- Used for:
  - JWT token blacklist (logout)
  - OTP storage (5-min TTL)
  - Cart sessions (24-hour TTL)
  - Menu cache (5-min TTL)
  - Rate limiting counters
  - Real-time order status pub/sub

### Elasticsearch (Search)
- `r6g.large.elasticsearch` (3 nodes)
- Indexes:
  - `menu_items` (full-text search, filters)
  - `orders` (admin search by customer/number)
  - `customers` (CRM search)

---

## Event Flow — Order Lifecycle

```
Customer Places Order
        │
        ▼
API: POST /orders ──→ PostgreSQL (create order)
        │
        ├──→ Redis PubSub: ORDER_CREATED event
        │           │
        │           ├──→ KDS WebSocket: New order on board
        │           ├──→ Push Notification: "Order received"
        │           └──→ WhatsApp/SMS: Order confirmation
        │
        ▼
Payment Gateway (Razorpay)
        │
        ▼
API: Webhook → Update payment status → ORDER_CONFIRMED
        │
        ├──→ KDS: Order moves to INCOMING queue
        ├──→ Delivery: Auto-assign nearest driver
        └──→ Notification: "Your order is confirmed!"
        │
        ▼
KDS: Chef marks PREPARING
        │
        └──→ Customer notification: "Your food is being prepared"
        │
        ▼
KDS: Chef marks READY
        │
        ├──→ Delivery Partner notified: "Pickup ready"
        └──→ Customer notified: "Your order is ready for pickup"
        │
        ▼
Driver marks OUT_FOR_DELIVERY
        │
        └──→ Customer: Live GPS tracking enabled
        │
        ▼
Driver marks DELIVERED
        │
        ├──→ Loyalty points awarded
        ├──→ Customer: Review prompt notification
        ├──→ Inventory: Deduction logged
        └──→ Analytics: Order metrics updated
```

---

## Caching Strategy

| Data | Cache Key | TTL | Invalidation |
|---|---|---|---|
| Menu categories | `menu:categories:{branchId}` | 5 min | On admin update |
| Menu items by category | `menu:category:{id}:{page}` | 5 min | On item update |
| Best sellers | `menu:best-sellers:{branchId}` | 15 min | Hourly |
| Branch info | `branch:{id}` | 1 hour | On admin update |
| User profile | `user:{id}` | 10 min | On profile update |
| Cart | `cart:{userId}` | 24 hours | On checkout |
| OTP | `otp:{phone}` | 5 min | On use |
| Rate limit | `rl:{ip}:{endpoint}` | 1 min | Sliding window |
| JWT blacklist | `jwt:blacklist:{jti}` | Token TTL | — |

---

## Disaster Recovery

### RTO (Recovery Time Objective): 30 minutes
### RPO (Recovery Point Objective): 5 minutes

| Failure Scenario | Recovery Strategy | Time |
|---|---|---|
| Single API pod fails | K8s auto-restarts pod | < 30 sec |
| All API pods fail | K8s recreates from deployment | 2–3 min |
| Database failover | RDS Multi-AZ auto-failover | 1–2 min |
| Redis failure | App falls back to DB | Immediate |
| AZ outage | Multi-AZ + ALB health check reroute | 2–3 min |
| Region outage | Manual failover to ap-southeast-1 | 30 min |

### Backup Strategy
- PostgreSQL: Daily automated backup (S3) + point-in-time recovery (5-min granularity)
- Redis: AOF + RDB snapshots every 15 min
- S3 (media): Cross-region replication to ap-southeast-1
- Code: Git (GitHub) with protected main branch

---

## Monitoring & Observability

### Metrics (Prometheus + Grafana)
- API latency (P50, P95, P99)
- Error rate per endpoint
- Database query performance
- Redis cache hit rate
- Active WebSocket connections
- Order success rate
- Payment success rate
- Business KPIs (GMV, orders/hour)

### Logs (ELK Stack / CloudWatch)
- Structured JSON logs from Spring Boot
- Log levels: ERROR (always alert), WARN (threshold alert), INFO (audit)
- 90-day hot storage, 1-year cold storage (S3 Glacier)

### Alerts (PagerDuty/Slack)
| Alert | Threshold | Severity |
|---|---|---|
| API error rate | > 1% | P2 |
| API P95 latency | > 500ms | P2 |
| Payment failure rate | > 2% | P1 |
| DB connection pool | > 80% | P2 |
| Pod crash loop | 3x in 5min | P1 |
| Low stock (any item) | Below reorder level | P3 |
| Disk usage (RDS) | > 80% | P2 |
