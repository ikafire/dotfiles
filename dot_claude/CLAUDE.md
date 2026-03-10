# Global User Preferences

## Bash Tool Usage

- **Never chain commands with `&&`** — use separate parallel Bash calls instead. Claude Code's compound-command security check ([#16561](https://github.com/anthropics/claude-code/issues/16561)) prompts even when each component is individually allowed.
- **Avoid quoted strings resembling flags** (e.g., `echo "---"`) which trigger "quoted characters in flag names" warnings ([#27957](https://github.com/anthropics/claude-code/issues/27957)).
- **For multi-line git commits**, use multiple `-m` flags (each becomes a separate paragraph). Never use heredoc, `$(...)`, or `$'\n'` — they all trigger permission prompts.
  ```bash
  git commit -m "feat: summary" -m "Details here" -m "Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
  ```
- **For PR bodies**, use `--body-file` with a temp file created via the Write tool. Never use `--body` with `$()` or heredoc.

## Web Fetching Tool Selection

When fetching web content, choose the tool with the best token-efficiency for the task:

| Use case | Best tool | Why |
|---|---|---|
| Quick fact lookup | **WebSearch** | Least tokens, correct answer, no URL needed |
| Code examples | **WebSearch** | Synthesized runnable code that fits in context |
| Deep reference / full page | **WebFetch** with targeted prompt | Only when exhaustive detail is needed |
| General browsing / gist | **Crawl4AI** (`mcp__crawl4ai__crawl_url`) | Token-efficient but avoid pages with tables or code |
| Don't know the URL | **WebSearch** | Only option that doesn't require a URL |

**Default to WebSearch** for most tasks — it has the lowest token cost, highest signal-to-noise ratio, and AI-synthesized answers with source links. Only fall back to WebFetch or Crawl4AI when you need the full original page content.
