---
date: {{YYYY-MM-DD}}
platform: {{ios | android}}
app: {{app name}}
bundle_id: {{bundle id / package (blank if unknown)}}
version: {{1.0 (10)}}
submission_id: {{Submission ID / Play case number}}
guidelines:
  - {{"1.2 Safety - User-Generated Content"}}
review_device: {{iPad Air 11-inch (M3), iPhone 17 Pro Max}}
status: {{open | resolved}}
resolved_on: {{YYYY-MM-DD or blank}}
checklist_ids: [{{UGC-01, UGC-02, …}}]
---

# {{YYYY-MM-DD}} {{platform}} {{guideline}} — {{app}}

Body in the user's language. Keep the original email verbatim.

## Original message

```
{{full rejection text; secrets (demo passwords etc.) → <REDACTED>}}
```

## Requirements (extracted)

- [ ] {{requirement 1}} → {{checklist ID}}
- [ ] {{requirement 2}} → {{checklist ID}}
- [ ] Evidence: {{recording / demo account / document}}

## Root cause

{{Which feature triggered it and why. With a scanned project cite file:line; otherwise mark "assumed".}}

## Hidden risks (likely co-rejections on resubmission)

- {{ID}}: {{why}}

## Actions

| Requirement | Implementation | Files | Status |
|---|---|---|---|
| {{terms consent}} | {{required checkbox on sign-up + clause}} | `{{…}}` | {{planned / done}} |

## Evidence

- Recording: {{link or file name — shoot per templates/evidence-recording.md}}
- Demo account: in the review notes (IDs only here, never passwords)

## Reply

{{summary of the reply sent (full text per templates/reply.md)}}

## Lessons → checklist

- {{checklists/xxx.md ID}}: {{what was added/changed}}
- scan.sh: {{signal added, or "no change"}}
