# Changelog

All notable changes to Re:VIEW are documented in this file.

---

## [Unreleased]

### Added

- **`review-lint`** — a new command-line linter for Re:VIEW `.re` source files.
  - Checks for 10 common formatting issues across error, warning, and info severity levels.
  - Reports problems with the exact file name, line number, and column for fast fixing.
  - Supports `--ignore`, `--only`, `--stats`, `--list-rules`, and `--no-color` options.
  - Returns exit code `1` on errors, making it suitable for use in CI pipelines.
  - See `doc/review-lint.md` for full documentation.

---

## Rules introduced in this release

| ID     | Severity | Description                                      |
|--------|----------|--------------------------------------------------|
| RV001  | Error    | Unknown or misspelled block tag                  |
| RV002  | Error    | Unclosed block tag                               |
| RV003  | Error    | Malformed inline tag (missing closing brace)     |
| RV004  | Warning  | Trailing whitespace                              |
| RV005  | Info     | Line longer than 120 characters                  |
| RV006  | Error    | Empty heading marker                             |
| RV007  | Warning  | Skipped heading level                            |
| RV008  | Warning  | `//list` or `//image` block missing an ID        |
| RV009  | Warning  | Windows-style CRLF line endings                  |
| RV010  | Info     | TODO or FIXME comment left in source             |
