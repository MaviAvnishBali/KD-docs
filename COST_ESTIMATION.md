# Cost Estimation — Kila Darbar
## Development + Infrastructure Costs (India Market)

---

## 1. Development Team Cost (7 Months)

| Role | Count | Monthly (₹) | 7 Months (₹) |
|---|---|---|---|
| Solution Architect (Part-time) | 1 | 1,50,000 | 10,50,000 |
| Backend Dev (Java, Senior) | 2 | 1,20,000 | 16,80,000 |
| Backend Dev (Java, Mid) | 1 | 80,000 | 5,60,000 |
| Android Dev (Kotlin, Senior) | 1 | 1,10,000 | 7,70,000 |
| Android Dev (Kotlin, Mid) | 1 | 75,000 | 5,25,000 |
| Frontend Dev (Next.js, Senior) | 1 | 1,00,000 | 7,00,000 |
| Frontend Dev (Next.js, Mid) | 1 | 70,000 | 4,90,000 |
| DevOps Engineer | 1 | 1,00,000 | 7,00,000 |
| QA Engineer (Senior) | 1 | 70,000 | 4,90,000 |
| QA Engineer (Mid) | 1 | 50,000 | 3,50,000 |
| UI/UX Designer | 1 | 80,000 | 5,60,000 |
| Product Manager | 1 | 1,00,000 | 7,00,000 |
| **Total Team** | **12** | **9,05,000** | **85,75,000** |

---

## 2. AWS Infrastructure Cost (Monthly — Post Launch)

### Compute (EKS)
| Service | Config | Monthly (₹) |
|---|---|---|
| EKS Cluster | 1 cluster | 5,500 |
| EC2 Worker Nodes (API) | 3x t3.medium (auto-scale) | 12,000 |
| EC2 Worker Nodes (Frontend) | 2x t3.small | 5,000 |
| NAT Gateway | 2 AZs | 8,000 |

### Database
| Service | Config | Monthly (₹) |
|---|---|---|
| RDS PostgreSQL | db.t3.medium, Multi-AZ | 18,000 |
| RDS Read Replica | db.t3.small | 9,000 |
| ElastiCache Redis | cache.t3.small, cluster | 7,000 |

### Storage & CDN
| Service | Config | Monthly (₹) |
|---|---|---|
| S3 (media storage) | ~100GB + requests | 2,000 |
| CloudFront CDN | 1TB transfer | 5,000 |
| Elasticsearch | t3.small.elasticsearch | 8,000 |

### Other Services
| Service | Monthly (₹) |
|---|---|
| Application Load Balancer | 3,500 |
| Route 53 | 500 |
| CloudWatch + Logs | 3,000 |
| SES (Email) | 1,000 |
| Secrets Manager | 500 |
| **Total AWS (Launch month)** | **88,000** |
| **Scaled (1 year, ~50K users)** | **1,80,000** |

---

## 3. Third-Party Services (Monthly)

| Service | Plan | Monthly (₹) |
|---|---|---|
| Razorpay | 2% per transaction (at ₹5L GMV) | 10,000 |
| Firebase (FCM) | Spark → Blaze | 2,000 |
| WhatsApp Business API | ~10K messages | 5,000 |
| MSG91 SMS | ~5K OTPs + 10K notifications | 3,000 |
| Google Maps API | ~1L map loads | 3,500 |
| Google Analytics | Free | 0 |
| Sentry (error tracking) | Team plan | 2,000 |
| **Total 3rd Party** | | **25,500** |

---

## 4. One-Time Costs

| Item | Cost (₹) |
|---|---|
| Apple Developer Account | 8,000/year |
| Google Play Console | 1,800 (one-time) |
| SSL Certificate (Wildcard) | 15,000/year |
| Domain Registration | 1,500/year |
| Figma Pro (1 year) | 15,000 |
| SonarQube | 25,000 |
| Security Pen Testing | 75,000 |
| Legal (ToS, Privacy Policy) | 50,000 |
| **Total One-time** | | **1,91,300** |

---

## 5. Total Cost Summary

| Category | Amount (₹) |
|---|---|
| Development (7 months) | 85,75,000 |
| AWS Infrastructure (7 months pre-launch) | 3,08,000 |
| 3rd Party (7 months) | 1,78,500 |
| One-Time Costs | 1,91,300 |
| **Total Project Budget** | **~₹93 Lakhs** |

---

## 6. Post-Launch Monthly Operating Cost

| Category | Monthly (₹) |
|---|---|
| AWS Infrastructure | 88,000 |
| 3rd Party Services | 25,500 |
| 1–2 Maintenance Engineers | 1,20,000 |
| Customer Support (2 staff) | 40,000 |
| **Total Monthly Ops** | **~₹2,73,500** |

---

## 7. ROI Analysis

| Metric | Value |
|---|---|
| Expected Monthly GMV (6 months) | ₹15,00,000 |
| Platform Fee (if SaaS model) | 3% = ₹45,000 |
| Revenue from higher avg order value | +₹23 per order × 1000 orders = ₹23,000 |
| Delivery revenue | ₹30 × 800 deliveries = ₹24,000 |
| **Break-even point** | 18–24 months |

---

## 8. Cost Optimization Strategies

1. **Reserved Instances:** 40% savings on EC2/RDS (1-year commitment)
2. **Spot Instances:** Use for batch analytics jobs
3. **CDN Caching:** Reduce API calls by 60% for menu data
4. **Database Connection Pooling:** Reduce RDS costs with HikariCP
5. **S3 Lifecycle Policies:** Move old media to S3-IA after 90 days
6. **Auto-scaling:** Scale down to 1 replica during off-peak (2AM–8AM)
7. **Compression:** Gzip API responses, WebP images = 30% data savings

> **Revised Optimized Monthly Ops:** ~₹1,90,000 (after year 1)
