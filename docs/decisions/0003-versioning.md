# 0003. Versioning and releases

Date: 2026-11-27. Status: accepted.

## Context

Uber's iOS libraries, one repository each with semver tags, ended in apps chasing version bumps; eff-erp's shared core
released after every merge (0.7.6 to 0.7.25 in days) and its apps wrote the pin in two or three manifests.

## Decision

- release-please cuts `vX.Y.Z` tags from Conventional Commits. Before 1.0 a breaking change moves the minor version.
- The release pull request is merged when a batch is worth shipping, not on every merge.
- Each app writes the dependency once, in `project.yml`, as `minorVersion`, and takes new minors through a dependency bot's
  pull request.
- Monorepo or not is revisited if more than half of AppleKit's changes need same-day changes in every app.

## Consequences

An app moves when it chooses to. A breaking change is visible in the version an app has to accept.
