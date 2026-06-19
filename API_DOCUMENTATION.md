# API Documentation — Kila Darbar
## REST API v1.0 | Base URL: `https://api.kiladarbar.com/api`

All endpoints return `ApiResponse<T>`:
```json
{
  "success": true,
  "message": "string",
  "data": {},
  "timestamp": "2025-06-18T10:00:00"
}
```

---

## Authentication

### POST /auth/otp/send
Send OTP to mobile number.
```json
// Request
{ "phone": "+919876543210" }

// Response 200
{ "success": true, "message": "OTP sent successfully" }
```

### POST /auth/otp/verify
```json
// Request
{ "phone": "+919876543210", "otp": "123456" }

// Response 200
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "tokenType": "Bearer",
    "expiresIn": 86400000,
    "user": {
      "id": "uuid",
      "name": "Priya Sharma",
      "phone": "+919876543210",
      "role": "CUSTOMER",
      "loyaltyPoints": 450
    }
  }
}
```

### POST /auth/google
```json
// Request
{ "idToken": "google-id-token" }
```

### POST /auth/refresh
```json
// Request
{ "refreshToken": "eyJhbGc..." }
```

### POST /auth/logout
Headers: `Authorization: Bearer {token}`

---

## Menu

### GET /menu/categories
```
Query: branchId (optional UUID)
```
```json
// Response 200
{
  "data": [
    {
      "id": 1,
      "name": "Biryani",
      "slug": "biryani",
      "imageUrl": "https://cdn.kiladarbar.com/categories/biryani.jpg",
      "displayOrder": 1,
      "itemCount": 12
    }
  ]
}
```

### GET /menu/categories/{id}/items
```
Query: foodType (VEG|NON_VEG|EGG|VEGAN|JAIN), branchId, page, size
```

### GET /menu/items/{id}
```json
{
  "data": {
    "id": "uuid",
    "name": "Royal Chicken Biryani",
    "slug": "royal-chicken-biryani",
    "description": "Slow-cooked in dum style...",
    "price": 320.00,
    "discountPrice": 280.00,
    "foodType": "NON_VEG",
    "preparationTime": 25,
    "calories": 650,
    "isAvailable": true,
    "isBestSeller": true,
    "images": [
      { "id": 1, "url": "https://cdn...", "isPrimary": true }
    ],
    "customizationGroups": [
      {
        "id": 1,
        "name": "Spice Level",
        "type": "SINGLE",
        "isRequired": true,
        "options": [
          { "id": 1, "name": "Mild", "additionalPrice": 0 },
          { "id": 2, "name": "Medium", "additionalPrice": 0 },
          { "id": 3, "name": "Extra Spicy", "additionalPrice": 10 }
        ]
      }
    ],
    "addons": [
      { "id": 1, "name": "Extra Raita", "price": 40 },
      { "id": 2, "name": "Salan", "price": 30 }
    ]
  }
}
```

### GET /menu/search
```
Query: q (string), foodType, branchId, page, size
```

### GET /menu/best-sellers
### GET /menu/recommended
### GET /menu/combos
### GET /menu/seasonal

---

## Orders

### POST /orders *(Auth Required)*
```json
// Request
{
  "branchId": "uuid",
  "orderType": "DELIVERY",
  "items": [
    {
      "menuItemId": "uuid",
      "quantity": 2,
      "selectedCustomizationOptionIds": [2],
      "selectedAddonIds": [1],
      "specialInstruction": "Less oil please"
    }
  ],
  "deliveryAddressId": "uuid",
  "deliveryInstructions": "Ring the doorbell",
  "couponCode": "FIRST50",
  "redeemPoints": 100,
  "tipAmount": 20,
  "paymentMethod": "UPI"
}

// Response 201
{
  "data": {
    "id": "uuid",
    "orderNumber": "KD-20250618-00001",
    "status": "PENDING",
    "orderType": "DELIVERY",
    "subtotal": 560.00,
    "discountAmount": 50.00,
    "deliveryCharge": 30.00,
    "cgstAmount": 25.50,
    "sgstAmount": 25.50,
    "totalAmount": 591.00,
    "pointsEarned": 59,
    "createdAt": "2025-06-18T10:00:00"
  }
}
```

### GET /orders/me *(Auth Required)*
```
Query: page, size
```

### GET /orders/{id} *(Auth Required)*

### POST /orders/{id}/cancel *(Auth Required)*
```
Query: reason (string)
```

### GET /orders/{id}/track *(Auth Required)*
Returns full order with delivery partner GPS location.

### POST /orders/{id}/rate *(Auth Required)*
```json
{
  "foodRating": 5,
  "deliveryRating": 4,
  "restaurantRating": 5,
  "comment": "Amazing biryani!"
}
```

### POST /orders/{id}/reorder *(Auth Required)*

---

## Payments

### POST /payments/initiate *(Auth Required)*
```json
// Request
{ "orderId": "uuid", "method": "UPI" }

// Response
{
  "data": {
    "gatewayOrderId": "order_xxx",
    "amount": 59100,
    "currency": "INR",
    "keyId": "rzp_live_xxx"
  }
}
```

### POST /payments/verify *(Auth Required)*
```json
{
  "orderId": "uuid",
  "razorpayOrderId": "order_xxx",
  "razorpayPaymentId": "pay_xxx",
  "razorpaySignature": "signature_hash"
}
```

### POST /payments/webhook/razorpay
Handled internally; Razorpay signature verified via HMAC-SHA256.

---

## Reservations

### GET /reservations/availability
```
Query: branchId, date (YYYY-MM-DD), partySize
Response: Available time slots
```

### POST /reservations *(Auth Required)*
```json
{
  "branchId": "uuid",
  "partySize": 4,
  "date": "2025-06-20",
  "time": "19:30",
  "occasion": "BIRTHDAY",
  "specialRequest": "Window table please",
  "tableId": "uuid"
}
```

### GET /reservations/me *(Auth Required)*
### PATCH /reservations/{id}/cancel *(Auth Required)*

---

## Profile & Loyalty

### GET /users/me *(Auth Required)*
### PUT /users/me *(Auth Required)*
### GET /users/me/addresses *(Auth Required)*
### POST /users/me/addresses *(Auth Required)*
### GET /loyalty/account *(Auth Required)*
### GET /loyalty/transactions *(Auth Required)*
### GET /loyalty/referral-code *(Auth Required)*

---

## Admin — Orders

### GET /admin/orders *(Manager+)*
```
Query: branchId, status, type, from, to, page, size
```

### PATCH /admin/orders/{id}/status *(Manager+)*
```
Query: status (CONFIRMED|PREPARING|READY|DELIVERED)
```

### PATCH /admin/orders/{id}/assign-driver *(Manager+)*
### POST /admin/orders/{id}/refund *(Manager+)*

---

## Admin — Menu

### POST /admin/menu/items *(Manager+)*
```json
{
  "categoryId": 1,
  "name": "New Dish",
  "description": "...",
  "price": 250.00,
  "foodType": "VEG",
  "gstRate": 5.00,
  "preparationTime": 20,
  "isAvailable": true,
  "customizationGroups": [...],
  "addons": [...]
}
```

### PUT /admin/menu/items/{id} *(Manager+)*
### DELETE /admin/menu/items/{id} *(Manager+)*
### PATCH /admin/menu/items/{id}/toggle-availability *(Manager+)*
### POST /admin/menu/items/{id}/images *(Manager+)* — multipart/form-data

---

## KDS

### GET /kds/orders *(Chef+)*
```
Query: branchId, station
```

### PATCH /kds/orders/{orderId}/start *(Chef+)*
### PATCH /kds/orders/{orderId}/ready *(Chef+)*
### PATCH /kds/orders/{orderId}/items/{itemId}/ready *(Chef+)*

WebSocket: `ws://api.kiladarbar.com/ws`
- Subscribe: `/topic/kds/{branchId}`
- Events: `ORDER_CREATED`, `ORDER_UPDATED`, `ORDER_CANCELLED`

---

## Inventory

### GET /inventory/items *(Manager+)*
### POST /inventory/items *(Manager+)*
### POST /inventory/items/{id}/stock-in *(Manager+)*
### POST /inventory/items/{id}/waste *(Manager+)*
### GET /inventory/low-stock-alerts *(Manager+)*
### GET /inventory/stock-movements *(Manager+)*
### POST /inventory/purchase-orders *(Manager+)*

---

## Reports

### GET /reports/dashboard *(Manager+)*
### GET /reports/sales *(Manager+)*
```
Query: branchId, period (DAILY|WEEKLY|MONTHLY|YEARLY|CUSTOM), from, to
```

### GET /reports/items/top-selling *(Manager+)*
### GET /reports/customers *(Manager+)*
### GET /reports/profit *(Manager+)*
### GET /reports/export/sales *(Manager+)*
```
Query: format (PDF|EXCEL|CSV)
Response: Binary file download
```

---

## Error Codes

| HTTP | Code | Description |
|---|---|---|
| 400 | VALIDATION_ERROR | Request validation failed |
| 401 | UNAUTHORIZED | Invalid or expired token |
| 403 | FORBIDDEN | Insufficient permissions |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource already exists |
| 422 | BUSINESS_ERROR | Business rule violation |
| 429 | RATE_LIMITED | Too many requests |
| 500 | INTERNAL_ERROR | Server error |

---

## Rate Limiting

| Endpoint Group | Limit |
|---|---|
| OTP Send | 5 requests/phone/hour |
| Auth endpoints | 20 requests/IP/minute |
| Order placement | 10 orders/user/minute |
| General API | 300 requests/user/minute |
| Admin API | 600 requests/user/minute |
