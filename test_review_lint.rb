# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

LINT_BIN = File.expand_path('../bin/review-lint', __dir__)

def run_lint(*args, content: nil, filename: 'test.re')
  Dir.mktmpdir do |dir|
    path = File.join(dir, filename)
    File.write(path, content) if content
    cmd = "ruby #{LINT_BIN} --no-color #{args.join(' ')} #{content ? path : ''}"
    stdout = `#{cmd} 2>&1`
    status = $?.exitstatus
    [stdout.strip, status]
  end
end

# ---------------------------------------------------------------------------
# Test suite
# ---------------------------------------------------------------------------

class TestReviewLint < Minitest::Test

  # -------------------------------------------------------------------------
  # RV001 – Unknown block tag
  # -------------------------------------------------------------------------

  def test_rv001_unknown_block_tag
    out, status = run_lint(content: "//badtag{\nsome content\n//}\n")
    assert_includes out, 'RV001'
    assert_equal 1, status
  end

  def test_rv001_known_block_tag_no_error
    out, status = run_lint(content: "//list[hello][caption]{\nputs 'hi'\n//}\n")
    refute_includes out, 'RV001'
  end

  # -------------------------------------------------------------------------
  # RV002 – Unclosed block
  # -------------------------------------------------------------------------

  def test_rv002_unclosed_block
    out, status = run_lint(content: "//list[sample][caption]{\nputs 'hello'\n")
    assert_includes out, 'RV002'
    assert_equal 1, status
  end

  def test_rv002_properly_closed_block
    out, status = run_lint(content: "//list[sample][caption]{\nputs 'hello'\n//}\n")
    refute_includes out, 'RV002'
  end

  # -------------------------------------------------------------------------
  # RV003 – Malformed inline tag
  # -------------------------------------------------------------------------

  def test_rv003_inline_tag_not_closed
    out, status = run_lint(content: "This is @<b>{bold text without closing\n")
    assert_includes out, 'RV003'
    assert_equal 1, status
  end

  def test_rv003_inline_tag_properly_closed
    out, status = run_lint(content: "This is @<b>{bold text} here.\n")
    refute_includes out, 'RV003'
  end

  # -------------------------------------------------------------------------
  # RV004 – Trailing whitespace
  # -------------------------------------------------------------------------

  def test_rv004_trailing_whitespace
    out, status = run_lint(content: "Some text   \nMore text\n")
    assert_includes out, 'RV004'
  end

  def test_rv004_no_trailing_whitespace
    out, _status = run_lint(content: "Some text\nMore text\n")
    refute_includes out, 'RV004'
  end

  # -------------------------------------------------------------------------
  # RV005 – Line too long
  # -------------------------------------------------------------------------

  def test_rv005_line_too_long
    long_line = 'a' * 121 + "\n"
    out, _status = run_lint(content: long_line)
    assert_includes out, 'RV005'
  end

  def test_rv005_line_within_limit
    ok_line = 'a' * 120 + "\n"
    out, _status = run_lint(content: ok_line)
    refute_includes out, 'RV005'
  end

  # -------------------------------------------------------------------------
  # RV006 – Empty heading
  # -------------------------------------------------------------------------

  def test_rv006_empty_heading
    out, status = run_lint(content: "= \n== \n")
    assert_includes out, 'RV006'
    assert_equal 1, status
  end

  def test_rv006_heading_with_text
    out, _status = run_lint(content: "= Introduction\n")
    refute_includes out, 'RV006'
  end

  # -------------------------------------------------------------------------
  # RV007 – Skipped heading level
  # -------------------------------------------------------------------------

  def test_rv007_skipped_heading_level
    out, _status = run_lint(content: "= Chapter\n=== Section\n")
    assert_includes out, 'RV007'
  end

  def test_rv007_sequential_heading_levels
    out, _status = run_lint(content: "= Chapter\n== Section\n=== Subsection\n")
    refute_includes out, 'RV007'
  end

  # -------------------------------------------------------------------------
  # RV008 – //list or //image missing ID
  # -------------------------------------------------------------------------

  def test_rv008_list_missing_id
    out, _status = run_lint(content: "//list[][]{\ncode\n//}\n")
    assert_includes out, 'RV008'
  end

  def test_rv008_list_with_id
    out, _status = run_lint(content: "//list[mylist][caption]{\ncode\n//}\n")
    refute_includes out, 'RV008'
  end

  # -------------------------------------------------------------------------
  # RV009 – CRLF line endings
  # -------------------------------------------------------------------------

  def test_rv009_crlf_endings
    out, _status = run_lint(content: "= Chapter\r\nSome text\r\n")
    assert_includes out, 'RV009'
  end

  def test_rv009_lf_endings_ok
    out, _status = run_lint(content: "= Chapter\nSome text\n")
    refute_includes out, 'RV009'
  end

  # -------------------------------------------------------------------------
  # RV010 – TODO / FIXME
  # -------------------------------------------------------------------------

  def test_rv010_todo_comment
    out, _status = run_lint(content: "Some text\n# TODO: finish this\n")
    assert_includes out, 'RV010'
  end

  def test_rv010_fixme_comment
    out, _status = run_lint(content: "Some text\n# FIXME: broken\n")
    assert_includes out, 'RV010'
  end

  def test_rv010_no_todo
    out, _status = run_lint(content: "= Clean Chapter\nAll good here.\n")
    refute_includes out, 'RV010'
  end

  # -------------------------------------------------------------------------
  # CLI options
  # -------------------------------------------------------------------------

  def test_list_rules_flag
    out, status = run_lint('--list-rules')
    assert_includes out, 'RV001'
    assert_includes out, 'RV010'
    assert_equal 0, status
  end

  def test_ignore_flag
    out, _status = run_lint('--ignore RV004', content: "trailing spaces   \n")
    refute_includes out, 'RV004'
  end

  def test_only_error_flag
    # File has both a warning (RV004) and an error (RV006)
    content = "=   \ntrailing   \n"
    out, _status = run_lint('--only error', content: content)
    assert_includes out, 'RV006'
    refute_includes out, 'RV004'
  end

  def test_version_flag
    out, status = run_lint('--version')
    assert_match(/\d+\.\d+\.\d+/, out)
    assert_equal 0, status
  end

  def test_clean_file_exits_zero
    out, status = run_lint(content: "= Introduction\n\nThis is clean text.\n")
    assert_equal 0, status
  end

  def test_missing_file_exits_nonzero
    out, status = run_lint('nonexistent_file.re')
    assert_equal 1, status
  end
end
