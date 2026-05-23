# review-lint — Re:VIEW Source File Linter

`review-lint` is a command-line tool that checks Re:VIEW `.re` source files for common formatting problems before you compile or publish. Think of it as a spell-checker for your Re:VIEW markup.

---

## Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Options](#options)
- [Rules Reference](#rules-reference)
- [Exit Codes](#exit-codes)
- [Using in CI](#using-in-ci)
- [Examples](#examples)

---

## Installation

Copy the `review-lint` script into Re:VIEW's `bin/` directory and make it executable:

```bash
cp review-lint /path/to/review/bin/review-lint
chmod +x /path/to/review/bin/review-lint
```

No additional gems are required.

---

## Basic Usage

Run `review-lint` from inside your Re:VIEW project directory:

```bash
# Check all *.re files in the current directory
review-lint

# Check specific files
review-lint preface.re chapter01.re chapter02.re
```

Each issue is printed in this format:

```
[E] chapter01.re:14:1  RV002  Block opened with '//list{' is never closed
[W] chapter01.re:27:5  RV004  Trailing whitespace
[I] chapter02.re:91:1  RV005  Line is 132 characters (limit: 120)
```

- `[E]` = Error — must be fixed
- `[W]` = Warning — should be fixed
- `[I]` = Info — nice to fix

---

## Options

### `--ignore RULES`

Skip one or more rules by ID. Use a comma-separated list:

```bash
review-lint --ignore RV004,RV005
```

### `--only SEVERITY`

Show only issues of a given severity level (`error`, `warning`, or `info`):

```bash
review-lint --only error
```

### `--stats`

Print a summary of total issues found after the list:

```bash
review-lint --stats
```

Output example:

```
Files checked : 4
Total issues  : 7  (errors: 2, warnings: 3, info: 2)
```

### `--list-rules`

Print all available rules and exit:

```bash
review-lint --list-rules
```

### `--[no-]color`

Force color output on or off. By default, color is enabled when writing to a terminal:

```bash
review-lint --no-color   # disable color
review-lint --color      # force color even when piping
```

### `-v, --version`

Show the version number and exit.

### `-h, --help`

Show usage information and exit.

---

## Rules Reference

### RV001 — Unknown block tag (Error)

Fires when a `//tag` name is not part of Re:VIEW's known block vocabulary.

```
//badtag{         ← triggers RV001
content
//}
```

### RV002 — Unclosed block (Error)

Fires when a `//tag{` is opened but no matching `//}` is found.

```
//list[sample][My list]{
puts 'hello'
              ← missing //}  → triggers RV002
```

### RV003 — Malformed inline tag (Error)

Fires when an `@<tag>{` inline tag is not closed on the same line.

```
This is @<b>{bold text    ← missing closing }  → triggers RV003
```

### RV004 — Trailing whitespace (Warning)

Fires when a line ends with one or more space or tab characters.

```
Some text    ← spaces here  → triggers RV004
```

### RV005 — Line too long (Info)

Fires when a line exceeds 120 characters.

### RV006 — Empty heading (Error)

Fires when a heading marker (`=`, `==`, etc.) has no title text.

```
=          ← no title  → triggers RV006
```

### RV007 — Skipped heading level (Warning)

Fires when a heading jumps more than one level at a time.

```
= Chapter One
=== Section   ← skipped ==  → triggers RV007
```

### RV008 — Missing block ID (Warning)

Fires when a `//list` or `//image` block appears to have no identifier label.

```
//list[][]{ ← empty ID  → triggers RV008
```

### RV009 — CRLF line endings (Warning)

Fires when Windows-style `\r\n` line endings are detected. Re:VIEW expects Unix `\n` endings.

### RV010 — TODO / FIXME comment (Info)

Fires when a `TODO` or `FIXME` annotation is found in the source, reminding you to resolve it before publishing.

```
#@# TODO: rewrite this section   ← triggers RV010
```

---

## Exit Codes

| Code | Meaning                          |
|------|----------------------------------|
| `0`  | No issues found                  |
| `1`  | One or more issues found         |
| `2`  | Usage or argument error          |

---

## Using in CI

Because `review-lint` exits with code `1` when errors are found, you can gate your build on it:

```bash
# Only build EPUB if there are no lint errors
review-lint --only error && rake epub
```

Or in a GitHub Actions workflow:

```yaml
- name: Lint Re:VIEW source files
  run: review-lint --only error --stats
```

---

## Examples

```bash
# Lint everything, show stats
review-lint --stats

# Errors only, no color (good for logs)
review-lint --only error --no-color

# Ignore trailing whitespace and long lines
review-lint --ignore RV004,RV005

# Check a single chapter
review-lint chapter03.re

# See all rules
review-lint --list-rules
```
