# RULES.md - Project Guidelines

## Code Style and Constraints

* Every Swift source file must stay under 200 lines of code.
* Single responsibility principle per module.
* Zero third-party dependencies. Use standard macOS system SDKs only.
* Never use semicolons or em dashes in documentation and comments.
* Always build and verify binaries using the terminal build script.
* Maintain clean teardown hooks so virtual displays and event taps release reliably on quit or reset.
