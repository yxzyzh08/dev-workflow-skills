# Test Engineer Coverage And Setup Rules

Use this file when mapping acceptance into E2E work.

## Coverage

- every formal acceptance item maps to at least one E2E case
- case IDs or titles should cite the requirement / acceptance ID they cover
- main flows come first; non-normal paths enter only when the acceptance baseline explicitly includes them

## Setup automation

Automate at least these areas when needed:

- browser or runtime dependencies
- environment variables or services
- test accounts or credentials
- seed data and cleanup
- reset steps between runs

## Black-box guard

Do not inspect production implementation to decide assertions or flows.
