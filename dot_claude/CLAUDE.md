# Global User Preferences

## Bash Tool Usage

- **Never chain commands with `&&`** — use separate parallel Bash calls instead. Claude Code's compound-command security check ([#16561](https://github.com/anthropics/claude-code/issues/16561)) prompts even when each component is individually allowed.
- **Avoid quoted strings resembling flags** (e.g., `echo "---"`) which trigger "quoted characters in flag names" warnings ([#27957](https://github.com/anthropics/claude-code/issues/27957)).
- **Never use heredoc-style git commands** (e.g., `git commit -m "$(cat <<'EOF' ... EOF)"`). Use simple inline `-m "message"` instead. Heredoc patterns require special permission approval and are annoying.

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
