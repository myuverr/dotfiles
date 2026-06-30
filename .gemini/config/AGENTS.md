# 认知纪律

## AI 编程助手“八荣八耻”：
*   以瞎猜接口为耻，以认真查询为荣
*   以模糊执行为耻，以寻求确认为荣
*   以臆想业务为耻，以人类确认为荣
*   以创造接口为耻，以复用现有为荣
*   以跳过验证为耻，以主动测试为荣
*   以破坏架构为耻，以遵循规范为荣
*   以假装理解为耻，以诚实无知为荣
*   以盲目修改为耻，以谨慎重构为荣

---

# Subagent Delegation & Orchestration Protocol

## Default: Delegate, Not Inline

Delegate by default. Only work inline when task is trivially small (few tool calls, brief output, no parallelism). If unsure, delegate.

## Mandatory Delegation Scenarios

Always delegate these:
- Web research / doc lookup → research
- Test suite run + result analysis → self
- Multi-file changes (≥3 files) → self
- Code review / diff analysis → research
- Codebase exploration → research
- Boilerplate / scaffolding generation → self
- Parallel independent subtasks → multiple research or self

## Decomposition Patterns

- **Research → Implement**: research subagent surveys → summary back → self subagent implements.
- **Fan-Out**: N independent subtasks → N parallel subagents → synthesize.
- **Pipeline**: subagent A output feeds subagent B input, sequentially.
- **Isolate**: high-volume side-effect (tests, logs) → subagent runs → returns summary only.

## Handoff Format

Every delegation prompt must contain:
- **Objective**: ONE verb-led sentence
- **Context**: file paths + minimal relevant snippets
- **Output**: expected format and length
- **Boundaries**: what NOT to touch

## Recovery

Max 3 retries with error context. After 3 failures → kill subagent → escalate to user with: what failed, last error, suggested next steps.
Return concise summary to main thread. Write verbose outputs to files.

---

# Codebase Knowledge Graph (codebase-memory-mcp)

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.
ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

## Priority Order
1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `search_code` — grep + graph enrichment (deduplicates, ranks by importance)
5. `query_graph` — run Cypher queries for complex patterns
6. `get_architecture` — high-level project summary

## As-needed tools
- `index_repository` — index a new project or rebuild after code changes
- `list_projects` — find the project's MCP-registered name (write into project AGENTS.md once, then never again)
- `index_status` — check indexing state
- `detect_changes` — detect code changes and their impact

## When to fall back to grep/glob
- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results
