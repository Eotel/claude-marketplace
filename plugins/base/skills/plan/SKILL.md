---
name: plan
description: Restate requirements, assess risks, and create step-by-step implementation plan. WAIT for user CONFIRM before touching any code.
user-invocable: true
disable-model-invocation: true
---

# Plan Command

This command invokes the **planner** agent to create a comprehensive implementation plan before writing any code.

## What This Command Does

1. **Restate Requirements** - Clarify what needs to be built
2. **Identify Risks** - Surface potential issues and blockers
3. **Create Step Plan** - Break down implementation into phases
4. **Wait for Confirmation** - MUST receive user approval before proceeding

## When to Use

Use `/plan` when:
- Starting a new feature
- Making significant architectural changes
- Working on complex refactoring
- Multiple files/components will be affected
- Requirements are unclear or ambiguous

## How It Works

The planner agent will:

1. **Analyze the request** and restate requirements in clear terms
2. **Break down into phases** with specific, actionable steps
3. **Identify dependencies** between components
4. **Assess risks** and potential blockers
5. **Estimate complexity** (High/Medium/Low)
6. **Present the plan** and WAIT for your explicit confirmation

## Example Usage

```
User: /plan I need to add a user profile page with settings

Agent (planner):
# Implementation Plan: User Profile Page with Settings

## Requirements Restatement
- Create a user profile page showing user information
- Allow users to update their profile (name, avatar, bio)
- Add notification preferences settings
- Implement account management (password change, delete account)

## Implementation Phases

### Phase 1: Database Schema
- Add user_profiles table with columns: id, user_id, display_name, avatar_url, bio, created_at
- Add user_settings table for preferences (email_notifications, theme, language)
- Create indexes on user_id for performance

### Phase 2: API Endpoints
- Create API routes in app/api/profile/
- Implement GET /api/profile (fetch profile)
- Implement PATCH /api/profile (update profile)
- Implement DELETE /api/profile (delete account)

### Phase 3: Frontend Components
- Create ProfilePage component
- Add ProfileForm for editing information
- Create SettingsPanel for preferences
- Implement avatar upload with preview

### Phase 4: Integration
- Connect to authentication system
- Add profile link in navigation header
- Implement real-time updates for profile changes

## Dependencies
- File storage (for avatar uploads)
- Authentication system
- Form validation library (zod)

## Risks
- MEDIUM: Image upload size limits
- MEDIUM: Data consistency during updates
- LOW: Cache invalidation for profile data

## Estimated Complexity: MEDIUM

**WAITING FOR CONFIRMATION**: Proceed with this plan? (yes/no/modify)
```

## Important Notes

**CRITICAL**: The planner agent will **NOT** write any code until you explicitly confirm the plan with "yes" or "proceed" or similar affirmative response.

If you want changes, respond with:
- "modify: [your changes]"
- "different approach: [alternative]"
- "skip phase 2 and do phase 3 first"

## Integration with Other Commands

After planning:
- Use `/tdd` to implement with test-driven development
- Use `/build-fix` if build errors occur
- Use `/code-review` to review completed implementation
