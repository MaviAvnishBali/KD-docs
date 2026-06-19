# Sprint Planning — Kila Darbar
## Methodology: Scrum | Sprint Duration: 2 weeks | Team: 12 engineers

---

## Team Structure

| Role | Count | Focus |
|---|---|---|
| Backend Dev (Java) | 3 | Spring Boot, PostgreSQL, Redis |
| Android Dev (Kotlin) | 2 | Customer app, Delivery app |
| Frontend Dev (Next.js) | 2 | Website, Admin dashboard, KDS |
| DevOps | 1 | AWS, Docker, K8s, CI/CD |
| QA | 2 | Manual + Automation testing |
| UI/UX Designer | 1 | Figma designs, prototypes |
| Product Manager | 1 | Backlog, stakeholder mgmt |

---

## Phase 1: Foundation (Sprints 1–4) — Weeks 1–8

### Sprint 1 — Infrastructure & Auth
**Goal:** Running backend + databases + CI/CD + Auth flow

| Task | Owner | Story Points |
|---|---|---|
| Set up AWS EKS cluster (Terraform) | DevOps | 8 |
| PostgreSQL + Redis + Elasticsearch setup | DevOps | 5 |
| Spring Boot project skeleton + CI/CD | Backend | 5 |
| Database migrations V1 (core schema) | Backend | 8 |
| JWT + OTP authentication API | Backend | 13 |
| Google OAuth2 integration | Backend | 8 |
| User management service + API | Backend | 8 |
| Android project setup + theme + nav | Android | 5 |
| Next.js website setup + global layout | Frontend | 5 |
| Figma design system + color scheme | UX | 13 |
| **Total** | | **78** |

### Sprint 2 — Menu & Catalog
**Goal:** Full menu browsable on all clients

| Task | Owner | Story Points |
|---|---|---|
| Category + MenuItem entities + migrations | Backend | 8 |
| Menu CRUD REST APIs | Backend | 13 |
| Elasticsearch indexing for menu search | Backend | 8 |
| S3 image upload service | Backend | 5 |
| AWS CloudFront CDN setup | DevOps | 5 |
| Menu browsing screens (Android) | Android | 13 |
| Item detail screen + customization UI | Android | 13 |
| Customer website: Home page | Frontend | 13 |
| Customer website: Menu page | Frontend | 13 |
| **Total** | | **91** |

### Sprint 3 — Cart & Ordering
**Goal:** End-to-end order placement (no payment yet)

| Task | Owner | Story Points |
|---|---|---|
| Cart service (Redis-backed) | Backend | 8 |
| Order entity + service + API | Backend | 21 |
| Order number generation + validation | Backend | 5 |
| GST calculation engine | Backend | 8 |
| Coupon service + validation | Backend | 13 |
| Cart screen (Android) | Android | 13 |
| Checkout screen (Android) | Android | 13 |
| Cart + Checkout (Website) | Frontend | 13 |
| Admin order list page | Frontend | 8 |
| **Total** | | **102** |

### Sprint 4 — Payments & Notifications
**Goal:** Full payment flow + real-time notifications

| Task | Owner | Story Points |
|---|---|---|
| Razorpay integration (order create + verify) | Backend | 13 |
| Razorpay webhook handler | Backend | 8 |
| Wallet service | Backend | 8 |
| Loyalty points earn/redeem engine | Backend | 13 |
| Firebase FCM push notification service | Backend | 8 |
| SMS gateway integration (MSG91) | Backend | 5 |
| Payment screen (Android) | Android | 13 |
| WebSocket setup (order status updates) | Backend | 8 |
| Order tracking screen (Android) | Android | 13 |
| Order status WebSocket (Website) | Frontend | 8 |
| **Total** | | **97** |

---

## Phase 2: Operations (Sprints 5–8) — Weeks 9–16

### Sprint 5 — KDS & Kitchen Flow
**Goal:** Kitchen staff can process orders on KDS

| Task | Owner | Story Points |
|---|---|---|
| KDS service + WebSocket broadcast | Backend | 13 |
| KDS order queue management | Backend | 8 |
| KDS Next.js app — board view | Frontend | 21 |
| KDS sound alerts + timer | Frontend | 5 |
| Station routing logic | Backend | 8 |
| Kitchen analytics API | Backend | 8 |
| Order status auto-progression | Backend | 5 |
| **Total** | | **68** |

### Sprint 6 — POS & Billing
**Goal:** Cashier can take in-store payments via POS

| Task | Owner | Story Points |
|---|---|---|
| POS order service (offline-capable) | Backend | 13 |
| Table management + floor plan API | Backend | 8 |
| GST invoice + receipt generation | Backend | 8 |
| UPI QR code generation | Backend | 5 |
| POS React UI — quick-add items | Frontend | 13 |
| POS — table selection + billing | Frontend | 13 |
| POS — split bill feature | Frontend | 8 |
| Day-end settlement report | Frontend | 8 |
| **Total** | | **76** |

### Sprint 7 — Delivery Management
**Goal:** Real-time delivery tracking end-to-end

| Task | Owner | Story Points |
|---|---|---|
| Delivery partner entity + onboarding | Backend | 8 |
| Auto-assignment algorithm | Backend | 13 |
| GPS location update API | Backend | 5 |
| Route optimization (Google Maps) | Backend | 8 |
| Delivery partner mobile app (Android) | Android | 21 |
| Live GPS tracking on customer app | Android | 13 |
| Live map on customer website | Frontend | 8 |
| Proof of delivery (photo + OTP) | Android | 8 |
| Driver earnings dashboard | Android | 8 |
| **Total** | | **92** |

### Sprint 8 — Inventory Management
**Goal:** Full stock tracking with auto-deduction

| Task | Owner | Story Points |
|---|---|---|
| Inventory item + stock movement models | Backend | 8 |
| Recipe ingredient mapping | Backend | 8 |
| Auto inventory deduction on order | Backend | 13 |
| Low stock alert scheduler | Backend | 5 |
| Vendor + Purchase Order service | Backend | 13 |
| Inventory admin UI | Frontend | 21 |
| Stock movement history | Frontend | 8 |
| Purchase order creation + receive flow | Frontend | 13 |
| **Total** | | **89** |

---

## Phase 3: Engagement (Sprints 9–12) — Weeks 17–24

### Sprint 9 — Reservations & Party
| Task | Story Points |
|---|---|
| Reservation entity + availability algorithm | 13 |
| Table booking API + conflict detection | 8 |
| Reservation confirmation notifications | 5 |
| Booking page on website | 13 |
| Booking management in admin | 8 |
| Party package management | 8 |
| Catering inquiry form + quotation | 8 |
| **Total** | **63** |

### Sprint 10 — CRM & Marketing
| Task | Story Points |
|---|---|
| Customer segmentation service | 13 |
| WhatsApp Business API integration | 13 |
| Campaign management service | 8 |
| Email campaign (SES) | 8 |
| Birthday/anniversary auto-trigger | 5 |
| Marketing campaigns admin UI | 13 |
| Coupon management UI | 8 |
| **Total** | **68** |

### Sprint 11 — Analytics & Reporting
| Task | Story Points |
|---|---|
| Sales analytics queries + aggregation | 13 |
| Dashboard overview API | 8 |
| PDF/Excel/CSV export service | 8 |
| Reports admin UI (charts) | 21 |
| Inventory consumption reports | 8 |
| Staff performance reports | 8 |
| Customer retention analytics | 8 |
| **Total** | **74** |

### Sprint 12 — Employee Management
| Task | Story Points |
|---|---|
| Employee entity + onboarding API | 8 |
| Attendance tracking (QR-based) | 8 |
| Shift scheduling system | 13 |
| Payroll calculation engine | 13 |
| Leave management | 8 |
| Employee admin UI | 13 |
| **Total** | **63** |

---

## Phase 4: Quality & Launch (Sprints 13–14) — Weeks 25–28

### Sprint 13 — Testing & Security
| Task | Story Points |
|---|---|
| Integration test suite (TestContainers) | 13 |
| Android UI test suite (Espresso) | 13 |
| Security audit + pen testing | 8 |
| Performance testing (k6) — 10K users | 8 |
| Bug fixes + edge case handling | 21 |
| **Total** | **63** |

### Sprint 14 — Launch Prep
| Task | Story Points |
|---|---|
| Production infrastructure hardening | 8 |
| SSL/TLS + WAF + DDoS protection | 5 |
| Data seeding + menu upload | 5 |
| App Store + Play Store submission | 8 |
| SEO + Google Analytics setup | 5 |
| Monitoring dashboards (Grafana) | 5 |
| Staff training documentation | 5 |
| Go-live cutover plan | 3 |
| **Total** | **44** |

---

## Velocity Summary

| Phase | Sprints | Weeks | Total Points |
|---|---|---|---|
| Phase 1 — Foundation | 1–4 | 1–8 | 368 |
| Phase 2 — Operations | 5–8 | 9–16 | 325 |
| Phase 3 — Engagement | 9–12 | 17–24 | 268 |
| Phase 4 — Quality | 13–14 | 25–28 | 107 |
| **Total** | **14** | **28** | **1,068** |

**Expected Go-Live: Week 28 (7 months from kickoff)**

---

## Definition of Done

- [ ] Unit tests written with >80% coverage
- [ ] Integration tests passing
- [ ] API documentation updated (OpenAPI)
- [ ] Code reviewed by 2+ engineers
- [ ] No critical SonarQube findings
- [ ] Feature tested on staging
- [ ] Mobile tested on Android 10+ and iOS 16+
- [ ] Performance benchmarks within SLA
- [ ] Security checklist verified
