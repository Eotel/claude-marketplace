# Base Plugin

A collection of generic, reusable agents for common software development tasks. This plugin provides foundational agents that work with any project type.

## Quick Start

1. Install the plugin in your Claude Code project
2. Customize agents by adding project-specific rules to your `CLAUDE.md`
3. Agents will automatically reference your customizations

## Agents

### planner

**Expert planning specialist for complex features and refactoring.**

Use proactively when users request feature implementation, architectural changes, or complex refactoring. Creates comprehensive, actionable implementation plans with step-by-step guidance.

- Analyzes requirements and creates detailed plans
- Breaks down complex features into manageable steps
- Identifies dependencies and potential risks

### build-error-resolver

**Build and TypeScript error resolution specialist.**

Use proactively when builds fail or type errors occur. Fixes build/type errors with minimal diffs, focusing on getting the build green quickly.

- Fixes TypeScript, compilation, and build errors
- Resolves dependency issues and import errors
- Makes smallest possible changes to fix errors

### code-reviewer

**Expert code review specialist.**

Use immediately after writing or modifying code. Reviews code for quality, security, and maintainability.

- Checks for security vulnerabilities (OWASP Top 10)
- Reviews code quality and best practices
- Identifies performance issues and improvements

### tdd-guide

**Test-Driven Development specialist.**

Use proactively when writing new features, fixing bugs, or refactoring code. Enforces write-tests-first methodology.

- Guides through TDD Red-Green-Refactor cycle
- Ensures comprehensive test coverage (80%+)
- Writes unit, integration, and E2E tests

### security-reviewer

**Security vulnerability detection and remediation specialist.**

Use proactively after writing code that handles user input, authentication, API endpoints, or sensitive data.

- Flags secrets, SSRF, injection, unsafe crypto
- Detects OWASP Top 10 vulnerabilities
- Provides secure code examples

### refactor-cleaner

**Dead code cleanup and consolidation specialist.**

Use proactively for removing unused code, duplicates, and refactoring. Runs analysis tools to identify dead code.

- Finds unused files, exports, and dependencies
- Consolidates duplicate code
- Documents all deletions in DELETION_LOG.md

### architect

**Software architecture specialist.**

Use proactively when planning new features, refactoring large systems, or making architectural decisions.

- Designs system architecture
- Evaluates technical trade-offs
- Creates Architecture Decision Records (ADRs)

### e2e-runner

**End-to-end testing specialist using Playwright.**

Use proactively for generating, maintaining, and running E2E tests. Manages test journeys and artifacts.

- Creates Playwright tests for user flows
- Handles flaky test management
- Uploads screenshots, videos, and traces

### doc-updater

**Documentation and codemap specialist.**

Use proactively for updating codemaps and documentation. Generates architectural maps from codebase structure.

- Creates architectural maps from code
- Updates READMEs and guides
- Tracks dependency relationships

## Customization

All agents support project-specific customization through your `CLAUDE.md` file. Each agent will automatically reference rules defined there.

### Example CLAUDE.md Customizations

```markdown
## Code Review Guidelines

### Architecture Rules
- Follow MANY SMALL FILES principle (200-400 lines)
- Use immutability patterns

### Security Requirements
- Verify database access controls on all queries
- Rate limit all public endpoints

## E2E Test Scenarios

### Critical User Journeys
1. User Registration Flow
   - Steps: Navigate to signup, fill form, verify email
   - Priority: HIGH

2. Checkout Flow
   - Steps: Add to cart, enter payment, confirm order
   - Priority: HIGH

## Refactoring Rules

### CRITICAL - Never Remove
- Authentication middleware
- Database migration files

### SAFE TO REMOVE
- Deprecated utility functions
- Test files for deleted features
```

## Contents

- `agents/` - Agent definitions (markdown files with frontmatter)
- `.claude-plugin/plugin.json` - Plugin manifest

## License

MIT
