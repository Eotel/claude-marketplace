---
description: Enforce test-driven development workflow. Scaffold interfaces, generate tests FIRST, then implement minimal code to pass. Ensure 80%+ coverage.
---

# TDD Command

This command invokes the **tdd-guide** agent to enforce test-driven development methodology.

## What This Command Does

1. **Scaffold Interfaces** - Define types/interfaces first
2. **Generate Tests First** - Write failing tests (RED)
3. **Implement Minimal Code** - Write just enough to pass (GREEN)
4. **Refactor** - Improve code while keeping tests green (REFACTOR)
5. **Verify Coverage** - Ensure 80%+ test coverage

## When to Use

Use `/tdd` when:
- Implementing new features
- Adding new functions/components
- Fixing bugs (write test that reproduces bug first)
- Refactoring existing code
- Building critical business logic

## How It Works

The tdd-guide agent will:

1. **Define interfaces** for inputs/outputs
2. **Write tests that will FAIL** (because code doesn't exist yet)
3. **Run tests** and verify they fail for the right reason
4. **Write minimal implementation** to make tests pass
5. **Run tests** and verify they pass
6. **Refactor** code while keeping tests green
7. **Check coverage** and add more tests if below 80%

## TDD Cycle

```
RED → GREEN → REFACTOR → REPEAT

RED:      Write a failing test
GREEN:    Write minimal code to pass
REFACTOR: Improve code, keep tests passing
REPEAT:   Next feature/scenario
```

## Example Usage

```
User: /tdd I need a function to calculate user discount based on membership tier

Agent (tdd-guide):
# TDD Session: User Discount Calculator

## Step 1: Define Interface (SCAFFOLD)

```typescript
// lib/discount.ts
export interface User {
  membershipTier: 'free' | 'basic' | 'premium' | 'enterprise'
  totalPurchases: number
  accountAgeMonths: number
}

export function calculateDiscount(user: User, orderTotal: number): number {
  // TODO: Implementation
  throw new Error('Not implemented')
}
```

## Step 2: Write Failing Test (RED)

```typescript
// lib/discount.test.ts
import { calculateDiscount } from './discount'

describe('calculateDiscount', () => {
  it('should return high discount for enterprise user', () => {
    const user = {
      membershipTier: 'enterprise' as const,
      totalPurchases: 10000,
      accountAgeMonths: 24
    }

    const discount = calculateDiscount(user, 100)

    expect(discount).toBeGreaterThan(20)
    expect(discount).toBeLessThanOrEqual(50)
  })

  it('should return low discount for free tier user', () => {
    const user = {
      membershipTier: 'free' as const,
      totalPurchases: 50,
      accountAgeMonths: 1
    }

    const discount = calculateDiscount(user, 100)

    expect(discount).toBeLessThan(10)
    expect(discount).toBeGreaterThanOrEqual(0)
  })

  it('should handle edge case: zero order total', () => {
    const user = {
      membershipTier: 'premium' as const,
      totalPurchases: 500,
      accountAgeMonths: 12
    }

    const discount = calculateDiscount(user, 0)

    expect(discount).toBe(0)
  })
})
```

## Step 3: Run Tests - Verify FAIL

```bash
npm test lib/discount.test.ts

FAIL lib/discount.test.ts
  ✕ should return high discount for enterprise user (2 ms)
    Error: Not implemented

1 test failed, 0 passed
```

✅ Tests fail as expected. Ready to implement.

## Step 4: Implement Minimal Code (GREEN)

```typescript
// lib/discount.ts
export function calculateDiscount(user: User, orderTotal: number): number {
  // Handle zero order total edge case
  if (orderTotal === 0) {
    return 0
  }

  // Base discount by tier (percentage)
  const tierDiscounts = {
    free: 0,
    basic: 5,
    premium: 15,
    enterprise: 25
  }
  const tierDiscount = tierDiscounts[user.membershipTier]

  // Loyalty bonus (up to 10%)
  const loyaltyBonus = Math.min(user.accountAgeMonths * 0.5, 10)

  // Purchase volume bonus (up to 15%)
  const volumeBonus = Math.min(user.totalPurchases / 1000, 15)

  // Total discount (capped at 50%)
  const totalDiscount = tierDiscount + loyaltyBonus + volumeBonus

  return Math.min(Math.max(totalDiscount, 0), 50)
}
```

## Step 5: Run Tests - Verify PASS

```bash
npm test lib/discount.test.ts

PASS lib/discount.test.ts
  ✓ should return high discount for enterprise user (3 ms)
  ✓ should return low discount for free tier user (2 ms)
  ✓ should handle edge case: zero order total (1 ms)

3 tests passed
```

✅ All tests passing!

## Step 6: Refactor (IMPROVE)

```typescript
// lib/discount.ts - Refactored with constants and better readability
const TIER_DISCOUNTS = {
  free: 0,
  basic: 5,
  premium: 15,
  enterprise: 25,
} as const

const LIMITS = {
  MAX_LOYALTY_BONUS: 10,
  MAX_VOLUME_BONUS: 15,
  MAX_TOTAL_DISCOUNT: 50,
  LOYALTY_RATE: 0.5,
  VOLUME_DIVISOR: 1000,
} as const

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max)
}

export function calculateDiscount(user: User, orderTotal: number): number {
  if (orderTotal === 0) return 0

  const tierDiscount = TIER_DISCOUNTS[user.membershipTier]
  const loyaltyBonus = Math.min(user.accountAgeMonths * LIMITS.LOYALTY_RATE, LIMITS.MAX_LOYALTY_BONUS)
  const volumeBonus = Math.min(user.totalPurchases / LIMITS.VOLUME_DIVISOR, LIMITS.MAX_VOLUME_BONUS)

  const totalDiscount = tierDiscount + loyaltyBonus + volumeBonus

  return clamp(totalDiscount, 0, LIMITS.MAX_TOTAL_DISCOUNT)
}
```

## Step 7: Verify Tests Still Pass

```bash
npm test lib/discount.test.ts

PASS lib/discount.test.ts
  ✓ should return high discount for enterprise user (3 ms)
  ✓ should return low discount for free tier user (2 ms)
  ✓ should handle edge case: zero order total (1 ms)

3 tests passed
```

✅ Refactoring complete, tests still passing!

## Step 8: Check Coverage

```bash
npm test -- --coverage lib/discount.test.ts

File           | % Stmts | % Branch | % Funcs | % Lines
---------------|---------|----------|---------|--------
discount.ts    |   100   |   100    |   100   |   100

Coverage: 100% ✅ (Target: 80%)
```

✅ TDD session complete!
```

## TDD Best Practices

**DO:**
- ✅ Write the test FIRST, before any implementation
- ✅ Run tests and verify they FAIL before implementing
- ✅ Write minimal code to make tests pass
- ✅ Refactor only after tests are green
- ✅ Add edge cases and error scenarios
- ✅ Aim for 80%+ coverage (100% for critical code)

**DON'T:**
- ❌ Write implementation before tests
- ❌ Skip running tests after each change
- ❌ Write too much code at once
- ❌ Ignore failing tests
- ❌ Test implementation details (test behavior)
- ❌ Mock everything (prefer integration tests)

## Test Types to Include

**Unit Tests** (Function-level):
- Happy path scenarios
- Edge cases (empty, null, max values)
- Error conditions
- Boundary values

**Integration Tests** (Component-level):
- API endpoints
- Database operations
- External service calls
- React components with hooks

**E2E Tests** (use `/e2e` command):
- Critical user flows
- Multi-step processes
- Full stack integration

## Coverage Requirements

- **80% minimum** for all code
- **100% required** for:
  - Financial calculations
  - Authentication logic
  - Security-critical code
  - Core business logic

## Important Notes

**MANDATORY**: Tests must be written BEFORE implementation. The TDD cycle is:

1. **RED** - Write failing test
2. **GREEN** - Implement to pass
3. **REFACTOR** - Improve code

Never skip the RED phase. Never write code before tests.

## Integration with Other Commands

- Use `/plan` first to understand what to build
- Use `/tdd` to implement with tests
- Use `/build-and-fix` if build errors occur
- Use `/code-review` to review implementation
- Use `/test-coverage` to verify coverage

## Related Agents

This command invokes the `tdd-guide` agent located at:
`~/.claude/agents/tdd-guide.md`

And can reference the `tdd-workflow` skill at:
`~/.claude/skills/tdd-workflow/`
