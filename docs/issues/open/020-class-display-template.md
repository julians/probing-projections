# 020 `ClassDisplayTemplate` is undefined

Phase: bug

## Why
`SelectionListDisplay` has a method that calls `ClassDisplayTemplate(…)`, which is never imported
or defined (found by `no-undef` linting). Looks like dead code, but it would throw if reached.

## Tasks
- [ ] Find out whether the method is reachable; delete it or fix it

## Notes
Present since the first commit.

## Done
