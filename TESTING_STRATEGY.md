# Testing Strategy — Kila Darbar
## Quality Assurance Framework

---

## Testing Pyramid

```
                    ┌──────────┐
                    │  E2E     │  5%
                   /│  Tests   │\
                  / └──────────┘ \
                 /  ┌──────────┐  \
                /   │Integration│  \  15%
               /    │  Tests    │   \
              /     └──────────┘    \
             / ┌─────────────────┐   \
            /  │   Unit Tests    │    \  80%
           /   └─────────────────┘     \
```

---

## 1. Backend Testing (Spring Boot)

### Unit Tests (JUnit 5 + Mockito)

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock private OrderRepository orderRepository;
    @Mock private InventoryService inventoryService;
    @Mock private LoyaltyService loyaltyService;
    @InjectMocks private OrderServiceImpl orderService;

    @Test
    @DisplayName("Should place order and deduct inventory")
    void placeOrder_ShouldDeductInventory() {
        // Given
        CreateOrderRequest request = buildTestOrderRequest();
        User user = buildTestUser();
        Branch branch = buildTestBranch();
        when(orderRepository.save(any())).thenReturn(buildTestOrder());

        // When
        OrderResponse response = orderService.placeOrder(request, user.getId());

        // Then
        assertThat(response.getStatus()).isEqualTo(OrderStatus.PENDING);
        verify(inventoryService, times(1)).deductForOrder(any());
        verify(orderRepository, times(1)).save(any());
    }

    @Test
    @DisplayName("Should throw when branch is closed")
    void placeOrder_WhenBranchClosed_ShouldThrow() {
        Branch closedBranch = buildTestBranch();
        closedBranch.setActive(false);

        assertThatThrownBy(() -> orderService.placeOrder(request, userId))
            .isInstanceOf(BusinessException.class)
            .hasMessageContaining("closed");
    }
}
```

### Integration Tests (TestContainers)

```java
@SpringBootTest
@Testcontainers
@ActiveProfiles("test")
class OrderIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine")
            .withDatabaseName("kiladarbar_test")
            .withUsername("test")
            .withPassword("test");

    @Container
    static GenericContainer<?> redis = new GenericContainer<>("redis:7-alpine")
            .withExposedPorts(6379);

    @Autowired private MockMvc mockMvc;
    @Autowired private UserRepository userRepository;
    @Autowired private OrderRepository orderRepository;

    @Test
    @WithMockUser(roles = "CUSTOMER")
    void placeOrder_E2E_ShouldCreateOrderAndReturn201() throws Exception {
        String requestBody = """
            {
                "branchId": "...",
                "orderType": "DELIVERY",
                "items": [{"menuItemId": "...", "quantity": 1}]
            }
        """;

        mockMvc.perform(post("/api/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.orderNumber").value(startsWith("KD-")))
                .andExpect(jsonPath("$.data.status").value("PENDING"));
    }
}
```

### Coverage Requirements
- Minimum coverage: 80% overall
- Critical paths (auth, order, payment): 95%
- Use JaCoCo for coverage reports

---

## 2. Frontend Testing (Next.js)

### Component Tests (Jest + React Testing Library)

```typescript
// MenuItemCard.test.tsx
import { render, screen, fireEvent } from "@testing-library/react";
import { MenuItemCard } from "@/components/menu/MenuItemCard";
import { mockMenuItem } from "@/test/mocks";

describe("MenuItemCard", () => {
  it("should display item name and price", () => {
    render(<MenuItemCard item={mockMenuItem} />);
    expect(screen.getByText("Royal Chicken Biryani")).toBeInTheDocument();
    expect(screen.getByText("₹280")).toBeInTheDocument();
  });

  it("should show discount price when available", () => {
    const itemWithDiscount = { ...mockMenuItem, price: 320, discountPrice: 280 };
    render(<MenuItemCard item={itemWithDiscount} />);
    expect(screen.getByText("₹280")).toBeInTheDocument();
    expect(screen.getByText("₹320")).toHaveClass("line-through");
  });

  it("should add to cart on button click", () => {
    const { addItem } = useCartStore.getState();
    render(<MenuItemCard item={mockMenuItem} />);
    fireEvent.click(screen.getByText("Add"));
    expect(addItem).toHaveBeenCalledWith(mockMenuItem);
  });

  it("should show unavailable state", () => {
    render(<MenuItemCard item={{ ...mockMenuItem, isAvailable: false }} />);
    expect(screen.getByText("Sold Out")).toBeDisabled();
  });
});
```

### E2E Tests (Playwright)

```typescript
// order-flow.spec.ts
import { test, expect } from "@playwright/test";

test.describe("Order Flow", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await loginWithOtp(page, "+919999999999");
  });

  test("should complete full order flow", async ({ page }) => {
    // Navigate to menu
    await page.click("text=Order Now");
    await expect(page).toHaveURL("/menu");

    // Add item to cart
    await page.click('[data-testid="item-royal-biryani"] >> text=Add');
    await expect(page.locator('[data-testid="cart-count"]')).toHaveText("1");

    // Go to cart
    await page.click('[data-testid="cart-icon"]');
    await expect(page).toHaveURL("/cart");

    // Proceed to checkout
    await page.click("text=Proceed to Checkout");
    await expect(page).toHaveURL("/checkout");

    // Select payment
    await page.click('[data-value="UPI"]');
    await page.click("text=Place Order");

    // Verify order placed
    await expect(page.locator("text=Order Placed!")).toBeVisible({ timeout: 10000 });
    await expect(page.locator('[data-testid="order-number"]')).toContainText("KD-");
  });
});
```

---

## 3. Android Testing (Kotlin)

### Unit Tests (JUnit 5 + MockK)

```kotlin
class OrderViewModelTest {

    @get:Rule val instantExecutorRule = InstantTaskExecutorRule()

    private val orderRepository: OrderRepository = mockk()
    private val viewModel = OrderViewModel(orderRepository)

    @Test
    fun `placeOrder should emit Success state with order`() = runTest {
        val expectedOrder = buildTestOrder()
        coEvery { orderRepository.placeOrder(any()) } returns Result.success(expectedOrder)

        viewModel.placeOrder(buildOrderRequest())

        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state).isInstanceOf(OrderUiState.Success::class.java)
            assertThat((state as OrderUiState.Success).order.orderNumber)
                .startsWith("KD-")
        }
    }

    @Test
    fun `placeOrder should emit Error state on failure`() = runTest {
        coEvery { orderRepository.placeOrder(any()) } returns
            Result.failure(BusinessException("Branch closed"))

        viewModel.placeOrder(buildOrderRequest())

        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state).isInstanceOf(OrderUiState.Error::class.java)
        }
    }
}
```

### UI Tests (Compose Testing)

```kotlin
@RunWith(AndroidJUnit4::class)
class HomeScreenTest {

    @get:Rule val composeTestRule = createComposeRule()

    @Test
    fun homeScreen_DisplaysBestSellers() {
        composeTestRule.setContent {
            KilaDarbarTheme {
                HomeScreen(
                    onMenuClick = {},
                    onCategoryClick = {},
                    onItemClick = {},
                    onCartClick = {},
                    onOrdersClick = {},
                    onProfileClick = {},
                )
            }
        }

        composeTestRule.onNodeWithText("Best Sellers").assertIsDisplayed()
        composeTestRule.onNodeWithTag("CategoryRow").assertIsDisplayed()
    }

    @Test
    fun addToCart_UpdatesCartBadge() {
        composeTestRule.setContent { /* ... */ }

        composeTestRule.onNodeWithText("Add").performClick()
        composeTestRule.onNodeWithTag("CartBadge").assertTextEquals("1")
    }
}
```

---

## 4. Performance Testing (k6)

```javascript
// load-test.js
import http from "k6/http";
import { check, sleep } from "k6";
import { Rate } from "k6/metrics";

const errorRate = new Rate("errors");

export const options = {
  stages: [
    { duration: "2m", target: 100 },   // Ramp up
    { duration: "5m", target: 500 },   // Peak load
    { duration: "2m", target: 1000 },  // Stress
    { duration: "2m", target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ["p(95)<200", "p(99)<500"],
    http_req_failed: ["rate<0.01"],
    errors: ["rate<0.01"],
  },
};

export default function() {
  // Menu load test
  const menuRes = http.get(`${__ENV.BASE_URL}/api/menu/categories`);
  check(menuRes, {
    "menu loads 200": (r) => r.status === 200,
    "menu loads fast": (r) => r.timings.duration < 200,
  });

  // Search test
  const searchRes = http.get(`${__ENV.BASE_URL}/api/menu/search?q=biryani`);
  check(searchRes, {
    "search 200": (r) => r.status === 200,
    "search < 300ms": (r) => r.timings.duration < 300,
  });

  sleep(1);
}
```

Run with:
```bash
k6 run --env BASE_URL=https://api.kiladarbar.com load-test.js
```

---

## 5. Security Testing

### OWASP ZAP (Automated)
```bash
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t https://api.kiladarbar.com \
  -r security-report.html
```

### Checklist
- [ ] SQL Injection (parameterized queries — Hibernate handles)
- [ ] XSS (Spring Security CSP headers)
- [ ] CSRF (stateless JWT — N/A)
- [ ] Authentication bypass
- [ ] Privilege escalation (role-based tests)
- [ ] Razorpay signature verification
- [ ] Rate limiting effectiveness
- [ ] Sensitive data in logs
- [ ] JWT algorithm confusion (RS256 vs HS256)
- [ ] Mass assignment protection
- [ ] File upload validation (MIME type + size)

---

## 6. QA Environments

| Environment | Purpose | Data |
|---|---|---|
| Local | Dev testing | Seed data |
| Dev | Feature integration | Seed data |
| Staging | Pre-release validation | Anonymized prod copy |
| Production | Live | Real customer data |

---

## 7. Bug Severity Matrix

| Severity | Description | SLA |
|---|---|---|
| P0 - Critical | App crash, payment failure, data loss | Fix in 2 hours |
| P1 - High | Feature broken, incorrect billing | Fix in 8 hours |
| P2 - Medium | Minor feature broken, UI issue | Fix in 2 days |
| P3 - Low | Cosmetic, enhancement | Next sprint |

---

## 8. CI/CD Gate Requirements

A PR cannot be merged if:
- [ ] Unit test coverage drops below 80%
- [ ] Any SonarQube critical finding
- [ ] Performance regression > 10%
- [ ] Build fails
- [ ] Type check fails (TypeScript)
- [ ] lint errors present
