# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (Playwright)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)

## Tests Over Documentation

Tests are more resistant to rot than documentation. A document stating "this feature works like X" will decay silently, but a test verifying "this feature works like X" turns red when it breaks. **Express specifications, expected behavior, and constraints as tests whenever possible.**

## Agent-Aware Testing

Per Mitchell Hashimoto's insight: agents are goal-oriented and will break things outside the current task scope to achieve their immediate objective. Test coverage that was sufficient for human-only development is **insufficient** for agent-assisted development.

Rules:
1. **Add a test for every agent mistake** - When an agent causes a failure, add a test that prevents recurrence. Once added, that test applies to all future agent sessions.
2. **Regression test mandate** - After a failure → fix → verification cycle guided by user instructions, you MUST add regression tests before considering the task complete. This is non-negotiable.
3. **Propose skill for reusable operations** - When a fix or operation pattern is likely to recur across sessions, propose creating a skill to codify it.

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first
- **e2e-runner** - Playwright E2E testing specialist
