# Future Scalability Plan — Kila Darbar
## Roadmap for Multi-Branch, Franchise & 10M+ Users

---

## Phase 2 — Multi-Branch (Months 8–12)

### Branch Management
- Each branch has independent menu, pricing, inventory, and staff
- Central menu library — branches inherit and customize
- Inter-branch reporting aggregated by owner/super-admin
- Branch-specific delivery zones and charge matrices

### Database Changes for Multi-Branch
```sql
-- Branch isolation: ALL tables already have branch_id
-- Add branch-level config table
CREATE TABLE branch_configs (
    branch_id       UUID PRIMARY KEY REFERENCES branches(id),
    tax_profile     JSONB,          -- per-branch GST configuration
    delivery_slots  JSONB,          -- available delivery time windows
    custom_fees     JSONB,          -- packaging, platform fees
    printer_config  JSONB,          -- thermal printer settings
    payment_methods TEXT[]
);

-- Menu inheritance: items without branch_id = global template
-- Branch can override price/availability per item
CREATE TABLE branch_menu_overrides (
    branch_id       UUID REFERENCES branches(id),
    menu_item_id    UUID REFERENCES menu_items(id),
    price           DECIMAL(10,2),
    is_available    BOOLEAN,
    PRIMARY KEY (branch_id, menu_item_id)
);
```

### Architecture Change
- Add `X-Branch-ID` request header
- Middleware injects branch context into all service calls
- Redis keys scoped: `menu:{branchId}:categories`
- Separate Elasticsearch index per branch (or branch filter)

---

## Phase 3 — Microservices Migration (Months 12–18)

Current monolith is modular by design — extract to services along domain boundaries:

```
┌─────────────────────────────────────────────────────┐
│                  API Gateway (Kong)                  │
└──┬──────┬──────┬──────┬──────┬──────┬──────┬──────┘
   │      │      │      │      │      │      │
   ▼      ▼      ▼      ▼      ▼      ▼      ▼
 Auth   Menu   Order  Payment Delivery Notif  Analytics
  Svc    Svc    Svc     Svc     Svc     Svc    Svc
```

### Service Communication
- **Sync:** REST via Kong (internal) with service mesh (Istio)
- **Async:** Apache Kafka for events
  - `order.created`, `order.status.changed`
  - `payment.completed`, `payment.failed`
  - `inventory.low-stock`
  - `delivery.assigned`, `delivery.completed`

### Kafka Event Schema (Avro)
```json
{
  "type": "record",
  "name": "OrderEvent",
  "namespace": "com.kiladarbar",
  "fields": [
    {"name": "eventId", "type": "string"},
    {"name": "eventType", "type": "string"},
    {"name": "orderId", "type": "string"},
    {"name": "branchId", "type": "string"},
    {"name": "status", "type": "string"},
    {"name": "timestamp", "type": "long"},
    {"name": "payload", "type": "string"}
  ]
}
```

---

## Phase 4 — Franchise Management (Months 12–18)

### Franchise Model
```
Super Admin (Platform)
├── Franchisor (e.g., Kila Darbar HQ)
│   ├── Branch A (Owned)
│   ├── Branch B (Franchise)
│   └── Branch C (Cloud Kitchen)
└── Franchisor 2 (Future expansion)
```

### New Entities
```sql
CREATE TABLE franchise_agreements (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    franchisee_id   UUID NOT NULL REFERENCES users(id),
    branch_id       UUID NOT NULL REFERENCES branches(id),
    royalty_rate    DECIMAL(5,2) NOT NULL,  -- % of GMV
    start_date      DATE NOT NULL,
    end_date        DATE,
    terms           JSONB
);

CREATE TABLE royalty_settlements (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agreement_id    UUID NOT NULL REFERENCES franchise_agreements(id),
    period_from     DATE NOT NULL,
    period_to       DATE NOT NULL,
    gross_sales     DECIMAL(12,2) NOT NULL,
    royalty_amount  DECIMAL(12,2) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    settled_at      TIMESTAMPTZ
);
```

---

## Phase 5 — Cloud Kitchen Support (Months 18–24)

- Cloud kitchen = kitchen with no dine-in; delivery/pickup only
- Multiple virtual brands operating from same kitchen
- Single KDS shows orders tagged by brand
- Separate menus and pricing per brand
- Shared inventory deduction

```sql
-- Virtual brand within a cloud kitchen
CREATE TABLE virtual_brands (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id   UUID NOT NULL REFERENCES branches(id),  -- the cloud kitchen
    name        VARCHAR(100) NOT NULL,
    slug        VARCHAR(100) NOT NULL,
    logo_url    TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

-- Menu items belong to a brand
ALTER TABLE menu_items ADD COLUMN virtual_brand_id UUID REFERENCES virtual_brands(id);
```

---

## Phase 6 — AI & ML Features (Months 12–24)

### 1. Personalized Recommendations (Collaborative Filtering)
```python
# Tech: Python + FastAPI + TensorFlow Recommenders
# Training: User order history + item embeddings
# Serving: Redis-cached recommendations per user (TTL: 1 hour)

# API endpoint consumed by Spring Boot
GET /ml/recommendations/{userId}?limit=10
```

### 2. Demand Forecasting (Time-Series)
```python
# Tech: Prophet (Meta) or LSTM
# Input: Historical order data, weather, events, day-of-week
# Output: Expected orders per hour for next 7 days
# Use case: Pre-prep schedule for kitchen, staff rostering
```

### 3. Dynamic Pricing
- Surge pricing during peak hours (7-9 PM weekends)
- Discounts during off-peak (3-5 PM)
- Inventory-based pricing (near-expiry items get discount)

### 4. Automated Inventory Reordering
```python
# When stock hits reorder level:
# 1. ML predicts consumption for next 7 days
# 2. Auto-generate purchase order to preferred vendor
# 3. Send WhatsApp to vendor with PO
# 4. Manager approves via mobile notification
```

### 5. Review Sentiment Analysis
```python
# Tech: HuggingFace transformers (distilbert-multilingual)
# Input: Customer review text (English + Hindi)
# Output: Sentiment (POSITIVE/NEUTRAL/NEGATIVE) + keywords
# Use: Alert admin on negative reviews instantly
```

---

## Performance Scaling Targets

| Users | Orders/Day | Architecture Change |
|---|---|---|
| 0–10K | 0–2K | Current: Monolith + 3 API pods |
| 10K–50K | 2K–10K | Add read replica, ElastiSearch cluster |
| 50K–200K | 10K–40K | Split Auth + Order services |
| 200K–1M | 40K–200K | Full microservices + Kafka |
| 1M+ | 200K+ | Multi-region + global CDN + sharding |

---

## Database Sharding Strategy (1M+ users)

- **Phase 1 (current):** Single PostgreSQL + Read Replica
- **Phase 2:** Read-Write split (CQRS pattern)
- **Phase 3:** Horizontal sharding by `branch_id` (branch-local data)
- **Phase 4:** Global tables (users, menu) + branch-sharded tables (orders, inventory)

---

## Global Expansion Readiness

### i18n (Phase 2)
- Backend: `Accept-Language` header, i18n message bundles
- Menu items: Name and description in multiple languages
- Supported: `en`, `hi` (Phase 2), `ar`, `ur` (Phase 3)

### Multi-Currency (Phase 3)
- Add `currency` column to branches
- Exchange rate service (daily cache from ECB/RBI)
- INR, AED, USD, GBP support

### Compliance
- **PDPA (India):** Data export, deletion on request — DONE
- **GDPR (EU):** If expanding to UAE/UK
- **VAT:** UAE 5% VAT handling in invoices
