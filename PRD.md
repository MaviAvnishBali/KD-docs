# Product Requirement Document (PRD)
## Kila Darbar Restaurant Management Ecosystem
**Version:** 1.0.0 | **Date:** June 2025 | **Status:** Approved

---

## 1. Executive Summary

Kila Darbar is a family restaurant offering dine-in, takeaway, home delivery, party orders, and catering services. This PRD defines the complete digital ecosystem to manage all restaurant operations from a single unified platform, designed to scale from one branch to a pan-India franchise network.

**Business Goals:**
- Increase online revenue by 40% within 6 months of launch
- Reduce operational costs through automation by 25%
- Achieve 4.5+ star rating on Google within 3 months
- Support 10,000 daily active customers at peak load
- Enable multi-branch expansion within 12 months

---

## 2. Stakeholders

| Stakeholder | Role | Primary Concern |
|---|---|---|
| Restaurant Owner | Primary decision maker | Revenue, profitability |
| Kitchen Manager | Operations | Order flow, KDS efficiency |
| Floor Manager | Service | Table management, reservations |
| Cashier | POS usage | Billing speed, accuracy |
| Chef | Food preparation | KDS display, timer alerts |
| Delivery Partner | Delivery execution | Route optimization |
| Customer | End user | Ordering experience |
| Super Admin | Platform management | Multi-branch control |

---

## 3. User Personas

### P1 — Priya (28, Urban Professional)
- Orders food 3–4 times/week from mobile apps
- Values speed, customization, and loyalty rewards
- Uses UPI for payments exclusively
- Expects < 30 min delivery

### P2 — Ramesh (45, Family Head)
- Visits restaurant for dine-in on weekends
- Books tables in advance, needs party packages
- Prefers WhatsApp communication
- Brand-loyal if quality is consistent

### P3 — Meenakshi (35, Event Coordinator)
- Places bulk catering orders for corporate events
- Needs custom menu, quotation, advance payment
- Communicates via email and phone

### P4 — Arjun (22, Delivery Partner)
- Works on shift basis, 8 hours/day
- Needs GPS navigation, earnings dashboard
- Limited data connectivity in some zones

---

## 4. System Architecture Overview

### 4.1 Core Principles
- **API-first:** All client apps consume the same REST API
- **Offline-capable:** POS and KDS work without internet (sync on reconnect)
- **Event-driven:** Orders trigger real-time events across all systems
- **Multi-tenant ready:** Branch isolation at database level
- **GDPR/PDPA compliant:** Data privacy by design

### 4.2 Service Domains
1. **Identity & Access** — Authentication, authorization, roles
2. **Catalog** — Menu, categories, items, customizations
3. **Commerce** — Orders, cart, checkout, payments
4. **Operations** — KDS, POS, delivery, inventory
5. **Engagement** — CRM, loyalty, notifications, marketing
6. **Analytics** — Reports, forecasting, AI insights
7. **Administration** — Branch management, super admin

---

## 5. Feature Requirements by Module

### 5.1 Customer Mobile App

#### Authentication
| Feature | Priority | Acceptance Criteria |
|---|---|---|
| Mobile OTP Login | P0 | OTP delivered < 10s, 6-digit, 5-min expiry |
| Google OAuth | P0 | Standard OAuth2 flow, token refresh |
| Apple Sign In | P1 | Required for App Store compliance |
| Email/Password | P1 | Min 8 chars, bcrypt hashed |
| Guest Checkout | P2 | No account required, order tracked by phone |

#### Menu & Ordering
| Feature | Priority | Acceptance Criteria |
|---|---|---|
| Category browsing | P0 | < 500ms load from cache |
| Item search | P0 | Elasticsearch, fuzzy match, < 200ms |
| Veg/Non-veg filter | P0 | Green/Red dot indicators per FSSAI |
| Customizations | P0 | Add-ons, remove ingredients, spice level |
| Cart persistence | P0 | Survive app kill, sync across devices |
| Combo meals | P1 | Bundled pricing, auto-calculate savings |
| Nutritional info | P2 | Per 100g or per serving |

#### Checkout & Payment
| Feature | Priority | Acceptance Criteria |
|---|---|---|
| Address autocomplete | P0 | Google Places API integration |
| Delivery time estimate | P0 | Dynamic based on kitchen load + distance |
| UPI payment | P0 | Razorpay, < 3s confirmation |
| COD | P1 | Available for orders < ₹500 |
| Promo code | P1 | Real-time validation, multiple types |
| Scheduled orders | P2 | Min 2hr advance, max 7 days |

#### Live Order Tracking
| Feature | Priority | Acceptance Criteria |
|---|---|---|
| Status timeline | P0 | WebSocket real-time, 5 states |
| Driver GPS tracking | P0 | Google Maps SDK, 15s refresh |
| ETA calculation | P0 | Recalculated every minute |
| Delivery proof | P1 | Photo capture on delivery |

#### Loyalty & Rewards
| Feature | Priority | Acceptance Criteria |
|---|---|---|
| Points earning | P0 | 1 point per ₹10 spent |
| Points redemption | P0 | 100 points = ₹10 discount |
| Referral program | P1 | ₹50 each on first order |
| Birthday offer | P1 | Auto-apply on birthday month |
| Tier system | P2 | Bronze/Silver/Gold/Platinum |

---

### 5.2 Customer Website

| Page | Priority | Key Elements |
|---|---|---|
| Home | P0 | Hero, featured items, offers, testimonials |
| Menu | P0 | Full catalog with ordering |
| Online Order | P0 | Embedded ordering flow |
| Table Reservation | P0 | Calendar, time slots, party size |
| About Us | P1 | Story, team, values |
| Gallery | P1 | Food photography, ambiance |
| Catering | P1 | Inquiry form, package preview |
| Blog | P2 | Food stories, recipes |
| Careers | P2 | Job listings |
| Contact | P1 | Map, hours, contact form |

**SEO Requirements:**
- Core Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1
- Structured data: Restaurant, Menu, LocalBusiness schemas
- Sitemap.xml auto-generation
- Open Graph for social sharing

---

### 5.3 Kitchen Display System (KDS)

| Feature | Priority | Details |
|---|---|---|
| Incoming order display | P0 | Auto-arrive, sorted by time |
| Order timer | P0 | Color-coded: green < 10min, yellow 10-20, red > 20 |
| Priority orders | P0 | VIP, express orders highlighted |
| Station routing | P1 | Route items to grill/fry/cold stations |
| Preparation status | P0 | Pending → Preparing → Ready |
| Audio alerts | P0 | New order sound, overdue alert |
| Offline mode | P0 | Local queue, sync on reconnect |

---

### 5.4 POS Billing System

| Feature | Priority | Details |
|---|---|---|
| Quick add items | P0 | Search by name/code, barcode scan |
| Dine-in table billing | P0 | Table map, merge/split tables |
| Split bill | P1 | Split by item or equal amount |
| GST calculation | P0 | CGST + SGST per item category |
| Discount types | P0 | Flat, %, coupon, manager override |
| UPI QR payment | P0 | Dynamic QR per transaction |
| Receipt printing | P0 | Thermal 80mm + A4 format |
| Void/refund | P1 | Requires manager PIN |
| Day-end settlement | P0 | Cash drawer reconciliation |
| Offline POS | P0 | All operations work without internet |

---

### 5.5 Delivery Management

| Feature | Priority | Details |
|---|---|---|
| Auto-assignment | P0 | Nearest available driver |
| Manual assignment | P1 | Admin override |
| Route optimization | P1 | Google Maps Directions API |
| Live GPS tracking | P0 | Driver app, WebSocket streaming |
| Proof of delivery | P1 | Photo + OTP confirmation |
| Delivery earnings | P0 | Per-delivery + daily/weekly summary |
| Zone management | P1 | Define delivery radius per branch |

---

### 5.6 Inventory Management

| Feature | Priority | Details |
|---|---|---|
| Raw material catalog | P0 | Units, category, reorder level |
| Stock receipt (GRN) | P0 | Vendor, invoice, quantity |
| Auto-deduction | P0 | Recipe-based consumption per order |
| Stock alerts | P0 | Push notification at reorder level |
| Expiry tracking | P0 | FIFO, expiry date alerts 3 days prior |
| Waste recording | P1 | Reason, quantity, responsible staff |
| Vendor management | P1 | Supplier catalog, contact, payment terms |
| Purchase orders | P1 | Automated PO generation |
| Consumption reports | P0 | Daily/weekly material usage |

---

### 5.7 Employee Management

| Feature | Priority | Details |
|---|---|---|
| Attendance (biometric/QR) | P0 | Check-in/out timestamps |
| Shift scheduling | P0 | Weekly roster, conflict detection |
| Payroll calculation | P1 | Attendance-based, deductions |
| Role-based access | P0 | 7 distinct roles |
| Performance metrics | P2 | Orders handled, delivery rating |
| Leave management | P1 | Request, approve, balance |

---

### 5.8 CRM & Marketing

| Feature | Priority | Details |
|---|---|---|
| Customer segments | P0 | Active, lapsed, new, high-value |
| WhatsApp campaigns | P0 | Template-based, WABA compliant |
| Push notifications | P0 | Firebase FCM, scheduled |
| Email campaigns | P1 | Nodemailer/SES, HTML templates |
| Coupon engine | P0 | Multiple discount types, usage limits |
| Birthday/anniversary | P1 | Automated trigger, personalized offer |

---

## 6. Non-Functional Requirements

### Performance
- API response time: P95 < 200ms, P99 < 500ms
- Database queries: < 50ms with indexes
- Mobile app launch: < 2 seconds cold start
- Website: < 3s on 4G connection

### Scalability
- Handle 10,000 concurrent users
- 50,000 orders per day at peak
- Horizontal scaling via Kubernetes HPA
- Database read replicas for analytics

### Availability
- SLA: 99.9% uptime (< 8.7 hrs/year downtime)
- POS and KDS: 99.99% (offline-capable)
- Automated failover within 30 seconds

### Security
- HTTPS everywhere (TLS 1.3)
- OWASP Top 10 compliance
- PCI-DSS for card payments
- Data encryption at rest (AES-256)
- Regular penetration testing quarterly

### Data Retention
- Order data: 7 years (GST compliance)
- Customer data: User-deletable (PDPA)
- Logs: 90 days hot, 1 year cold storage

---

## 7. Constraints

- All amounts in Indian Rupees (INR) with GST compliance
- SMS via Indian carrier (DLT-registered templates)
- WhatsApp via verified WABA account
- UPI via Razorpay (RBI-regulated)
- App Store & Play Store compliance

---

## 8. Assumptions

1. Restaurant initially operates from 1 branch
2. Delivery radius: 10 km from restaurant
3. Operating hours: 11 AM – 11 PM daily
4. Peak load: Weekend evenings 7–9 PM
5. Primary language: English + Hindi support planned for v2

---

## 9. Out of Scope (v1)

- PAN-India logistics integration (Dunzo/Swiggy)
- Franchise portal (v2)
- Multi-language (v2)
- Desktop POS with hardware integration (v2)
- ML-based demand forecasting (v2)

---

## 10. Success Metrics

| KPI | Baseline | Target (6 months) |
|---|---|---|
| Online order GMV | ₹0 | ₹15 lakhs/month |
| App downloads | 0 | 10,000 |
| Customer retention | - | 60% month-2 |
| Average order value | ₹350 | ₹450 |
| Delivery time | 60 min | 35 min |
| Customer rating | - | 4.5+ |
| Cart abandonment | - | < 25% |
