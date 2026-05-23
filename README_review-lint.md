# review-lint

A linter for [Re:VIEW](https://github.com/kmuto/review) format source files.

`review-lint` scans your `.re` files and reports formatting problems — like a spell-checker, but for Re:VIEW markup. It tells you exactly which file and line has the issue so you can fix it fast.

---

## Installation

Place `review-lint` in Re:VIEW's `bin/` directory and make it executable:

```bash
cp review-lint /path/to/review/bin/review-lint
chmod +x /path/to/review/bin/review-lint
```

No extra gems required — it uses only Ruby's standard library.

---

## Usage

```bash
# Lint all *.re files in the current directory
review-lint

# Lint specific files
review-lint chapter1.re chapter2.re

# Show errors only
review-lint --only error

# Ignore specific rules
review-lint --ignore RV004,RV005

# Show all available rules
review-lint --list-rules

# Show a summary at the end
review-lint --stats

# Disable color output
review-lint --no-color
```

---

## Output

Each issue is printed in the format:

```
[E] chapter1.re:12:1  RV002  Block opened with '//list{' is never closed
[W] chapter1.re:34:5  RV004  Trailing whitespace
[I] chapter2.re:88:1  RV005  Line is 135 characters (limit: 120)
```

- `[E]` = Error (must fix)
- `[W]` = Warning (should fix)
- `[I]` = Info (nice to fix)

---

## Rules

| ID     | Severity | Description                                      |
|--------|----------|--------------------------------------------------|
| RV001  | Error    | Unknown or misspelled block tag (`//badtag`)     |
| RV002  | Error    | Unclosed block (`//tag{` with no `//}`)          |
| RV003  | Error    | Malformed inline tag (missing closing `}`)       |
| RV004  | Warning  | Trailing whitespace                              |
| RV005  | Info     | Line longer than 120 characters                  |
| RV006  | Error    | Empty heading (`=` with no title text)           |
| RV007  | Warning  | Skipped heading level (e.g. `=` then `===`)      |
| RV008  | Warning  | `//list` or `//image` block missing an ID        |
| RV009  | Warning  | Windows-style CRLF line endings detected         |
| RV010  | Info     | TODO or FIXME comment left in source             |

---

## Exit Codes

| Code | Meaning                        |
|------|--------------------------------|
| `0`  | No issues found                |
| `1`  | One or more issues found       |
| `2`  | Usage or argument error        |

This makes `review-lint` easy to use in CI pipelines:

```bash
review-lint --only error && rake epub
```

---

## Options

| Option            | Description                                         |
|-------------------|-----------------------------------------------------|
| `--ignore RULES`  | Comma-separated rule IDs to skip (e.g. `RV004,RV005`) |
| `--only SEVERITY` | Show only `error`, `warning`, or `info`             |
| `--[no-]color`    | Force enable or disable color output                |
| `--list-rules`    | Print all rules and exit                            |
| `--stats`         | Print a summary count at the end                    |
| `-v, --version`   | Show version                                        |
| `-h, --help`      | Show help                                           |

---

## Contributing

1. Fork the Re:VIEW repository.
2. Add or improve rules in `review-lint` following the existing rule format.
3. Add tests for any new rule.
4. Send a pull request — topic branches welcome!

---

## License

Same as Re:VIEW: GNU Lesser General Public License (LGPL).  
See the [COPYING](https://github.com/kmuto/review/blob/master/COPYING) file.
