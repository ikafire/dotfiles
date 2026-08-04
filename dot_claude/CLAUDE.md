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

## Dev Flow

- **When reviewing an MR/PR, don't re-run what CI already covers.** Read the pipeline result instead (`list_merge_request_pipelines` → job status). Re-running the lint + test suite locally duplicates CI and produces no new information. Only run code locally when it answers a question CI cannot: a throwaway probe that confirms or refutes a specific review finding (a missing guard, a silent no-op, two configs colliding). Those probes are scratch files — never commit them.
- **When fixing bugs, always reproduce the failure first.** Before writing any fix, write or run a test that demonstrates the bug and confirm it fails. Only after seeing the failure should you implement the fix, then re-run the test to verify it passes. This ensures you've identified the actual root cause rather than guessing.
- **Use `uv` to create a venv when running temporary Python scripts.** If a script needs dependencies not available globally, use `uv venv` and `uv pip install` to set up an isolated environment before running it.
- **Never run `dotnet build` / `dotnet test` locally in WSL** — the machine runs out of memory and crashes. For .NET projects, always commit and push, and let CI do the build/test. Read the pipeline result instead of building locally.
