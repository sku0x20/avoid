# Project Instructions

## Commits
- Commit after every discrete change. Use a short, descriptive message focused on the "why".
- Stage specific files by name. Avoid `git add -A` or `git add .`.
- Skip `git diff` / `git log` / `git status` before committing — derive the message from the change you just made.

## Advisor
- Call `advisor()` whenever clarity is needed on approach, trade-offs, or correctness.
- Advisor is backed by Opus — use it freely for non-obvious decisions.

## Subagents
- Always pass `model: "haiku"` when spawning via the `Agent` tool.

## Planning
- For any complicated or multi-step task, lay out a plan and get confirmation before making changes.
- Use the Plan tool or outline steps inline; do not start implementing until the plan is agreed.

## Token efficiency
- Do not re-read files you have already read in this session unless the content may have changed.
- Do not run `git diff`, `git log`, or `git status` speculatively — only when the output is directly needed.
- Avoid heavy commands (builds, installs, long-running processes) that the user can run themselves. Suggest the command instead.
- Prefer targeted reads (specific line ranges) over reading entire files when only a section is needed.
