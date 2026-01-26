# Specifications Directory

Place your project requirements here. The Ralph Loop will read these specs to understand what to build.

## Recommended Structure

```
specs/
├── README.md           # This file
├── requirements.md     # High-level requirements
├── features/           # Feature specifications
│   ├── feature-1.md
│   └── feature-2.md
└── technical/          # Technical specifications
    ├── architecture.md
    └── api.md
```

## Example Requirement Format

```markdown
# Feature: User Authentication

## Overview
Brief description of what this feature does.

## User Stories
- As a user, I want to log in so that I can access my account
- As a user, I want to reset my password if I forget it

## Acceptance Criteria
- [ ] Login form accepts email and password
- [ ] Invalid credentials show error message
- [ ] Successful login redirects to dashboard

## Technical Notes
- Use JWT for session management
- Passwords must be hashed with bcrypt
```

## Tips

- Be specific about acceptance criteria
- Include testable requirements
- Break large features into smaller specs
- The more detail you provide, the better Claude can implement
