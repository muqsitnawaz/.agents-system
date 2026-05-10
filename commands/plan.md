---
description: Plan with grounded design - research, read code, create artifacts, optionally get early review
---

You are planning: $ARGUMENTS

## CRITICAL: Ground the Plan in Reality

Plans fail when they're based on assumptions instead of evidence. Before proposing anything:
1. Research current best practices and APIs
2. Read the actual code that will change
3. Create concrete artifacts (mockups, diagrams)
4. Optionally get early review from a small team

## Step 1: Understand the Request

Before reading any code, clarify:

1. **What is the user asking for?** — Restate in your own words. If ambiguous, use `AskUserQuestion` with 2-3 interpretations.
2. **What is the goal?** — What problem does this solve? Who benefits?
3. **What is the scope?** — New feature, refactor, bug fix, or integration?
4. **What are the constraints?** — Time, dependencies, backwards compatibility?

## Step 2: Research Current State-of-the-Art

**Do NOT skip this.** Your training data is stale. Before designing, web search for:

- Current best practices for this type of feature (anchor with current year)
- API documentation for any libraries or services involved
- Common pitfalls or anti-patterns others have hit
- Recent changes to frameworks or APIs the code uses

Examples:
- "Next.js 15 app router authentication patterns 2026"
- "Stripe subscription API best practices 2026"
- "React Server Components data fetching 2026"

Extract 2-3 key insights that should inform the design. If an API has changed or a better approach exists, the plan should reflect that.

## Step 3: Audit the Codebase

Now find what's relevant. Target your search — do NOT read everything.

**Search strategy:**
- Keywords in filenames: `fd auth`, `fd login`
- Keywords in content: `grep -r "authentication" src/`
- Project structure: `ls src/` or `ls app/`
- Similar features: How do existing features work?

**Identify and READ:**
- **Entry points** — Routes, controllers, handlers
- **Data layer** — Models, schemas, types
- **UI layer** — Components, screens (if applicable)
- **Shared logic** — Utilities, hooks, services
- **Tests** — Existing test patterns

**Output the relevant paths:**
```
Relevant paths identified:
- src/features/auth/login.tsx:1-85 (UI entry point)
- src/lib/auth.ts:20-60 (auth logic)
- src/types/auth.d.ts (types)
```

## Step 4: Read the Code

Read EVERY file identified above. For each:
1. Note file path and line numbers
2. Quote the relevant code
3. Understand how it connects to other files

**Do NOT guess. Do NOT speculate. Read code, then speak.**

The plan must be grounded in what the code actually does, not what you assume it does.

## Step 5: Inventory Existing Primitives

**Before designing anything new, catalog what already exists:**

- **UI Components** — buttons, modals, forms, layouts, cards already in the codebase
- **Design tokens** — colors, spacing, typography from tailwind config or design system
- **Utilities** — helpers, hooks, services that solve similar problems
- **Patterns** — how do similar features handle state, errors, loading, validation?

```
Existing primitives to reuse:
- components/ui/Button.tsx — primary, secondary, destructive variants
- components/ui/Modal.tsx — standard modal with close behavior
- hooks/useForm.ts — form state + validation
- lib/api.ts:fetchWithAuth() — authenticated API calls
```

**The default is REUSE, not invent.** If a component, pattern, or utility exists that does 80% of what you need, extend it — don't create a parallel implementation.

**Before proposing ANY new primitive** (component, hook, utility, pattern), use `AskUserQuestion`:
- "This feature needs X. I found similar primitive Y in the codebase. Should I: (1) Extend Y to support this case, (2) Create new primitive X, (3) Let me look for other options?"

Only create new primitives when:
1. Nothing similar exists, AND
2. The user explicitly approves

## Step 6: Create Artifacts

After reading code, create concrete artifacts. **No discussion without artifacts.**

### For UI Changes — User Flow + Mockups REQUIRED

First, show the user flow:
```
[Landing] --click "Sign Up"--> [Registration Form] --submit--> [Email Verification]
                                      |                              |
                                      v                              v
                               [Validation Error]            [Welcome Screen]
```

Then, ASCII mockup for each screen:
```
+----------------------------------+
| Logo                    [Login]  |
+----------------------------------+
|                                  |
|     Create your account          |
|                                  |
|  Email:    [                  ]  |
|  Password: [                  ]  |
|                                  |
|        [Create Account]          |
|                                  |
|  Already have an account? Login  |
+----------------------------------+
```

Annotate:
- What each element does
- Validation rules
- Error states
- Loading states

### For API Changes — Request/Response REQUIRED

```
POST /api/v1/auth/register
Request:  { "email": "user@example.com", "password": "..." }
Response: { "id": "...", "email": "...", "token": "..." }
Errors:
  400: { "error": "email_taken", "message": "Email already registered" }
  400: { "error": "weak_password", "message": "Password must be 8+ chars" }
```

### For State Changes — State Diagram REQUIRED

```
[Guest] --register--> [Unverified] --verify_email--> [Active]
                           |                            |
                           v                            v
                    [Expired Link]               [Suspended]
```

### For Data Flow — Sequence Diagram REQUIRED

```
User -> Frontend: click submit
Frontend -> API: POST /register
API -> DB: insert user
API -> Email: send verification
API -> Frontend: 201 Created
Frontend -> User: show success
```

### For Multiple Scenarios — Table REQUIRED

| Scenario | Input | Result |
|----------|-------|--------|
| Valid registration | valid email + password | 201, user created |
| Email taken | existing email | 400, email_taken |
| Weak password | "123" | 400, weak_password |

## Step 7: Early Design Review (Recommended for Medium+ Features)

Before finalizing, get independent review from 1-2 agents:

```bash
agents teams create plan-review-<topic>
agents teams add plan-review-<topic> claude "Review this feature design independently. 
Context: [paste the goal and constraints]
Files to read: [list the key files]
Do NOT look at my proposed approach. Create your own design with artifacts.
Return file:line quotes for every claim." --name reviewer1 --mode plan

agents teams add plan-review-<topic> codex "Same task, independent review..." --name reviewer2 --mode plan

agents teams start plan-review-<topic> --watch
```

After they complete:
- Compare their designs with yours
- Incorporate edge cases you missed
- Adopt simpler approaches if found
- Note disagreements as design questions

**Skip for:** Small, well-understood changes with clear patterns.
**Use for:** New features, architectural changes, unfamiliar areas.

## Step 8: Design Questions

Only AFTER creating artifacts, list genuine uncertainties. Each must:
- Reference which artifact it affects
- Explain what changes based on the answer
- Offer 2-3 concrete options via `AskUserQuestion`

## Output Format

### Research
What you learned from web search. Key insights that inform the design.

### Codebase Audit
Files read with line numbers. How they connect.

### Existing Primitives
Components, hooks, utilities, patterns to reuse. What each provides.

### Feature: [Name]

**Code Read:** file:line quotes of relevant code

**User Flow:** (for UI features)
[Flow diagram showing screens and transitions]

**Artifacts:**
[Mockups, API specs, state diagrams — MANDATORY]

**Implementation:**
- File: path/to/file.ts
  - Function: existingFunction() — modify to add X
  - New function: newFunction() — does Y

**Design Questions:** (only if genuinely ambiguous)

### Review Findings (if team was spawned)
What reviewers found. What was incorporated.

### Summary

| Feature | Files Modified | New Functions | Complexity |
|---------|----------------|---------------|------------|
| ... | ... | ... | Low/Med/Hi |

## Constraints

- No time estimates
- No "nice to have" additions
- No abstract discussion without artifacts
- Every UI feature needs user flow + mockups
- Use AskUserQuestion for ambiguous decisions
- Web search before designing — your training is stale
- **Reuse over invent** — extend existing primitives, don't create parallel ones
- **Ask before creating new primitives** — new components/hooks/utils need user approval
