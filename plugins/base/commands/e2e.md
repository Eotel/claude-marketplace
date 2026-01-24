---
description: Generate and run end-to-end tests with Playwright. Creates test journeys, runs tests, captures screenshots/videos/traces, and uploads artifacts.
---

# E2E Command

This command invokes the **e2e-runner** agent to generate, maintain, and execute end-to-end tests using Playwright.

## What This Command Does

1. **Generate Test Journeys** - Create Playwright tests for user flows
2. **Run E2E Tests** - Execute tests across browsers
3. **Capture Artifacts** - Screenshots, videos, traces on failures
4. **Upload Results** - HTML reports and JUnit XML
5. **Identify Flaky Tests** - Quarantine unstable tests

## When to Use

Use `/e2e` when:
- Testing critical user journeys (login, checkout, profile updates)
- Verifying multi-step flows work end-to-end
- Testing UI interactions and navigation
- Validating integration between frontend and backend
- Preparing for production deployment

## How It Works

The e2e-runner agent will:

1. **Analyze user flow** and identify test scenarios
2. **Generate Playwright test** using Page Object Model pattern
3. **Run tests** across multiple browsers (Chrome, Firefox, Safari)
4. **Capture failures** with screenshots, videos, and traces
5. **Generate report** with results and artifacts
6. **Identify flaky tests** and recommend fixes

## Example Usage

```
User: /e2e Test the product search and checkout flow

Agent (e2e-runner):
# E2E Test Generation: Product Search and Checkout Flow

## Test Scenario Identified

**User Journey:** Search Products → View Results → Add to Cart → Checkout

**Test Coverage:**
1. Navigate to products page
2. Perform search
3. Verify search results
4. Add product to cart
5. Navigate to checkout
6. Complete purchase

## Generated Test Code

```typescript
// tests/e2e/products/search-and-checkout.spec.ts
import { test, expect } from '@playwright/test'
import { ProductsPage } from '../../pages/ProductsPage'
import { CheckoutPage } from '../../pages/CheckoutPage'

test.describe('Product Search and Checkout Flow', () => {
  test('user can search products and complete checkout', async ({ page }) => {
    // 1. Navigate to products page
    const productsPage = new ProductsPage(page)
    await productsPage.goto()

    // Verify page loaded
    await expect(page).toHaveTitle(/Products/)
    await expect(page.locator('h1')).toContainText('Products')

    // 2. Perform search
    await productsPage.searchProducts('laptop')

    // Wait for API response
    await page.waitForResponse(resp =>
      resp.url().includes('/api/products/search') && resp.status() === 200
    )

    // 3. Verify search results
    const productCards = productsPage.productCards
    await expect(productCards.first()).toBeVisible()
    const resultCount = await productCards.count()
    expect(resultCount).toBeGreaterThan(0)

    // Take screenshot of search results
    await page.screenshot({ path: 'artifacts/search-results.png' })

    // 4. Add first product to cart
    await productCards.first().locator('[data-testid="add-to-cart"]').click()

    // Verify cart updated
    await expect(page.locator('[data-testid="cart-count"]')).toContainText('1')

    // 5. Navigate to checkout
    await page.click('[data-testid="cart-icon"]')
    await page.click('button:has-text("Checkout")')

    // 6. Complete checkout
    const checkoutPage = new CheckoutPage(page)
    await expect(checkoutPage.orderSummary).toBeVisible()

    // Take screenshot of checkout
    await page.screenshot({ path: 'artifacts/checkout.png' })
  })

  test('search with no results shows empty state', async ({ page }) => {
    const productsPage = new ProductsPage(page)
    await productsPage.goto()

    // Search for non-existent product
    await productsPage.searchProducts('xyznonexistentproduct123456')

    // Verify empty state
    await expect(page.locator('[data-testid="no-results"]')).toBeVisible()
    await expect(page.locator('[data-testid="no-results"]')).toContainText(
      /no.*results|no.*products/i
    )

    const productCount = await productsPage.productCards.count()
    expect(productCount).toBe(0)
  })

  test('can clear search and see all products again', async ({ page }) => {
    const productsPage = new ProductsPage(page)
    await productsPage.goto()

    // Initial product count
    const initialCount = await productsPage.productCards.count()

    // Perform search
    await productsPage.searchProducts('phone')
    await page.waitForLoadState('networkidle')

    // Verify filtered results
    const filteredCount = await productsPage.productCards.count()
    expect(filteredCount).toBeLessThan(initialCount)

    // Clear search
    await productsPage.searchInput.clear()
    await page.waitForLoadState('networkidle')

    // Verify all products shown again
    const finalCount = await productsPage.productCards.count()
    expect(finalCount).toBe(initialCount)
  })
})
```

## Running Tests

```bash
# Run the generated test
npx playwright test tests/e2e/products/search-and-checkout.spec.ts

Running 3 tests using 3 workers

  ✓  [chromium] › search-and-checkout.spec.ts:5:3 › user can search products and complete checkout (4.2s)
  ✓  [chromium] › search-and-checkout.spec.ts:52:3 › search with no results shows empty state (1.8s)
  ✓  [chromium] › search-and-checkout.spec.ts:67:3 › can clear search and see all products again (2.9s)

  3 passed (9.1s)

Artifacts generated:
- artifacts/search-results.png
- artifacts/checkout.png
- playwright-report/index.html
```

## Test Report

```
╔══════════════════════════════════════════════════════════════╗
║                    E2E Test Results                          ║
╠══════════════════════════════════════════════════════════════╣
║ Status:     ✅ ALL TESTS PASSED                              ║
║ Total:      3 tests                                          ║
║ Passed:     3 (100%)                                         ║
║ Failed:     0                                                ║
║ Flaky:      0                                                ║
║ Duration:   9.1s                                             ║
╚══════════════════════════════════════════════════════════════╝

Artifacts:
📸 Screenshots: 2 files
📹 Videos: 0 files (only on failure)
🔍 Traces: 0 files (only on failure)
📊 HTML Report: playwright-report/index.html

View report: npx playwright show-report
```

✅ E2E test suite ready for CI/CD integration!
```

## Test Artifacts

When tests run, the following artifacts are captured:

**On All Tests:**
- HTML Report with timeline and results
- JUnit XML for CI integration

**On Failure Only:**
- Screenshot of the failing state
- Video recording of the test
- Trace file for debugging (step-by-step replay)
- Network logs
- Console logs

## Viewing Artifacts

```bash
# View HTML report in browser
npx playwright show-report

# View specific trace file
npx playwright show-trace artifacts/trace-abc123.zip

# Screenshots are saved in artifacts/ directory
open artifacts/search-results.png
```

## Flaky Test Detection

If a test fails intermittently:

```
⚠️  FLAKY TEST DETECTED: tests/e2e/checkout/payment.spec.ts

Test passed 7/10 runs (70% pass rate)

Common failure:
"Timeout waiting for element '[data-testid="confirm-btn"]'"

Recommended fixes:
1. Add explicit wait: await page.waitForSelector('[data-testid="confirm-btn"]')
2. Increase timeout: { timeout: 10000 }
3. Check for race conditions in component
4. Verify element is not hidden by animation

Quarantine recommendation: Mark as test.fixme() until fixed
```

## Browser Configuration

Tests run on multiple browsers by default:
- ✅ Chromium (Desktop Chrome)
- ✅ Firefox (Desktop)
- ✅ WebKit (Desktop Safari)
- ✅ Mobile Chrome (optional)

Configure in `playwright.config.ts` to adjust browsers.

## CI/CD Integration

Add to your CI pipeline:

```yaml
# .github/workflows/e2e.yml
- name: Install Playwright
  run: npx playwright install --with-deps

- name: Run E2E tests
  run: npx playwright test

- name: Upload artifacts
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: playwright-report
    path: playwright-report/
```

## Best Practices

**DO:**
- ✅ Use Page Object Model for maintainability
- ✅ Use data-testid attributes for selectors
- ✅ Wait for API responses, not arbitrary timeouts
- ✅ Test critical user journeys end-to-end
- ✅ Run tests before merging to main
- ✅ Review artifacts when tests fail

**DON'T:**
- ❌ Use brittle selectors (CSS classes can change)
- ❌ Test implementation details
- ❌ Run tests against production
- ❌ Ignore flaky tests
- ❌ Skip artifact review on failures
- ❌ Test every edge case with E2E (use unit tests)

## Integration with Other Commands

- Use `/plan` to identify critical journeys to test
- Use `/tdd` for unit tests (faster, more granular)
- Use `/e2e` for integration and user journey tests
- Use `/code-review` to verify test quality

## Related Agents

This command invokes the `e2e-runner` agent located at:
`~/.claude/agents/e2e-runner.md`

## Quick Commands

```bash
# Run all E2E tests
npx playwright test

# Run specific test file
npx playwright test tests/e2e/products/search.spec.ts

# Run in headed mode (see browser)
npx playwright test --headed

# Debug test
npx playwright test --debug

# Generate test code
npx playwright codegen http://localhost:3000

# View report
npx playwright show-report
```
