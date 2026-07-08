---
name: codebase-memory-mcp
description: Codebase knowledge graph CLI for structural code discovery. Use instead of grep/glob when finding functions, tracing callers/callees, reading source by symbol, navigating architecture, or running Cypher queries.
---

You are a code intelligence analyst. Use codebase-memory-mcp CLI tools to trace code structure, discover function relationships, and navigate software architecture.

# Codebase Memory MCP (CLI Mode)

All tools use the CLI interface:
```bash
codebase-memory-mcp cli <tool_name> '<json_args>'
```

Arguments must be a **single-quoted JSON string**. Double-quote nested JSON inside single quotes.

---

## Complete Workflow (MUST follow this order)

### Step 1: Discover Project Name

**ALWAYS start here.** Every tool except `list_projects` requires `project` — you cannot skip this.

```bash
codebase-memory-mcp cli list_projects json
```

Example output:
```json
{"projects":[{"name":"foo-bar","root_path":"/foo/bar","nodes":1000}, ...]}
```

**Project naming:** path slashes become hyphens. `/home/user/my-project` → `home-user-my-project`.

> **GOTCHA:** If you don't find the current project in the list, you must index it first (Step 2).

✔ **Checkpoint:** You now have a confirmed `project` name. Use this value for every subsequent `project` parameter. If the current working directory's project was not found, proceed to Step 2.

### Step 2: Check / Create Index

**Check if the project is indexed:**
```bash
codebase-memory-mcp cli index_status '{"project":"<name>"}'
```

**Check for unindexed changes since last modification:**
```bash
codebase-memory-mcp cli detect_changes '{"project":"<name>"}'
```

**Index the repository** if not indexed or stale:
```bash
codebase-memory-mcp cli index_repository '{"repo_path":"<absolute-path>","mode":"fast"}'
```

Index modes:
- `"fast"` — minimum, no similarity/semantic edges. Use for quick diagnostics.
- `"moderate"` — filtered files + similarity/semantic edges. Good for most projects.
- `"full"` — all files + all edges. Large repos only when thorough analysis needed.
- `"cross-repo-intelligence"` — match Routes/Channels across projects.

> **GOTCHA:** Indexing can take seconds to minutes for large repos. For first-time use, warn the user it may take a moment. After code modifications, run `detect_changes` to see if re-index is needed.

✔ **Checkpoint:** `index_status` returned `ready` and `detect_changes` returned no pending changes (or you have just completed indexing). You may now query the graph.

### Step 3: Get High-Level Overview (Optional but Recommended)

Before diving into specifics, understand the project structure:
```bash
codebase-memory-mcp cli get_architecture '{"project":"<name>","aspects":["summary","clusters"]}'
```

This reveals packages, services, dependencies, and architectual clusters (Leiden community detection).

✔ **Checkpoint:** You understand the high-level package/service layout and major architectural clusters before diving into specific queries.

### Step 4: Search and Trace

**Find functions/classes/routes by name or concept:**
```bash
# Natural-language BM25 search (recommended):
codebase-memory-mcp cli search_graph '{"project":"<name>","query":"update user settings","limit":20}'

# Exact pattern matching (regex):
codebase-memory-mcp cli search_graph '{"project":"<name>","name_pattern":".*handler.*","limit":20}'

# Semantic search (requires moderate/full index mode):
codebase-memory-mcp cli search_graph '{"project":"<name>","semantic_query":["send","publish","dispatch"]}'

# Filter by label:
codebase-memory-mcp cli search_graph '{"project":"<name>","query":"auth","label":"Route","limit":20}'

# Filter by file:
codebase-memory-mcp cli search_graph '{"project":"<name>","query":"handler","file_pattern":"src/api","limit":20}'
```

> **PAGINATION:** Response includes `"total"` (full match count) and `"has_more"` (true when truncated). If `has_more` is true, re-call with `offset` increased by `limit` until `has_more` becomes false.

> **GOTCHA:** `search_graph` returns `qualified_name` like `project.package.file.function`. You MUST use this full qualified_name in `get_code_snippet` — short names alone may be ambiguous.

**Trace callers/callees (who calls this, what does it call):**
```bash
# Find callers of a function:
codebase-memory-mcp cli trace_path '{"function_name":"<short name>","project":"<name>","direction":"inbound","depth":2,"mode":"calls"}'

# Find what a function calls:
codebase-memory-mcp cli trace_path '{"function_name":"<short name>","project":"<name>","direction":"outbound","depth":2,"mode":"calls"}'

# Data flow tracing (follow value propagation through args):
codebase-memory-mcp cli trace_path '{"function_name":"<short name>","project":"<name>","direction":"both","mode":"data_flow","depth":3}'

# Cross-service tracing (through HTTP/async Routes):
codebase-memory-mcp cli trace_path '{"function_name":"<short name>","project":"<name>","mode":"cross_service","depth":3}'

# Include test files (excluded by default):
codebase-memory-mcp cli trace_path '{"function_name":"<short name>","project":"<name>","include_tests":true}'
```

**Read source of a specific function/class (use qualified_name from search_graph):**
```bash
codebase-memory-mcp cli get_code_snippet '{"qualified_name":"<full.qualified.name>","project":"<name>"}'
```

> **GOTCHA:** `qualified_name` MUST be the exact full name from `search_graph` results. Passing a short name returns suggestions rather than the actual source.

**Cypher queries for complex multi-hop patterns:**
```bash
codebase-memory-mcp cli query_graph '{"query":"MATCH (f:Function) WHERE f.transitive_loop_depth >= 3 RETURN f.qualified_name, f.transitive_loop_depth ORDER BY f.transitive_loop_depth DESC LIMIT 10","project":"<name>"}'
```

Common Cypher patterns:
```cypher
-- Find all routes in a service
MATCH (r:Route) WHERE r.qualified_name STARTS WITH "project.package" RETURN r

-- Hot-path detection (nested loops causing O(n²) behavior)
MATCH (f:Function) WHERE f.transitive_loop_depth >= 3 OR f.linear_scan_in_loop >= 1
RETURN f.qualified_name, f.transitive_loop_depth, f.linear_scan_in_loop

-- Find most-called functions (high fan-in)
MATCH (f:Function)<-[c:CALLS]-() RETURN f.qualified_name, count(c) AS callers ORDER BY callers DESC LIMIT 20
```

✔ **Checkpoint:** When using `search_graph`, always check `has_more` and paginate if true. When using `get_code_snippet`, always pass the full `qualified_name` from search results — never a short name. When tracing, increase `depth` if the default (3) does not reach far enough.

### Step 5: Hybrid Search (grep + graph enrichment)

When you need full-text grep plus structural context:
```bash
codebase-memory-mcp cli search_code '{"pattern":"error handling","project":"<name>","mode":"compact","limit":10}'
```

Modes: `"compact"` (signatures only), `"full"` (with source), `"files"` (file paths only).

✔ **Checkpoint:** For string literals or non-code files, fall back to `grep`/`glob` as described in the Fallback section below.

---

## Common Traps (READ BEFORE USING)

| Trap | How to Avoid |
|------|-------------|
| Forgetting to call `list_projects` first | **EVERY tool requires `project`.** Before anything else, run `list_projects`. |
| Wrong project name | Project name = path with `-` instead of `/`. Verify against `list_projects` output. |
| Querying an unindexed project | Always check `index_status` or `detect_changes` first. Empty results often mean the project isn't indexed. |
| Stale index after code changes | After editing code, check `detect_changes` and re-index if needed. |
| Using short name in `get_code_snippet` | MUST use the full `qualified_name` from `search_graph` results. |
| Missing pagination | Check `has_more` in `search_graph` response. If true, paginate with `offset`+`limit`. |
| JSON quoting errors | Outer use single quotes `'`, inner JSON uses double quotes `"`. |
| Not requesting a high enough depth | `trace_path` default depth is 3. Increase for deeper call chains. |

---

## Tool Quick Reference

See [references/tools.md](references/tools.md) for the complete tool list and parameter reference.

---

## Fallback: When to Use grep/glob Instead

Use `grep`/`glob`/`read` instead of graph tools only when:
- Searching for **string literals, error messages, or config values** (not in graph)
- Searching **non-code files** (Dockerfiles, shell scripts, configs, .github/workflows)
- Graph tools return **empty results** and the project is confirmed indexed

---

## Examples

### Example 1: Basic Search → Read Source

User asks: "find where authentication logic is implemented."

```
1. list_projects → {"projects":[{"name":"storage-test",...}]}
2. search_graph '{"project":"storage-test","query":"authentication","limit":10}'
   → {"results":[{"qualified_name":"storage-test.src.auth.login",...}],...}
3. get_code_snippet '{"qualified_name":"storage-test.src.auth.login","project":"storage-test"}'
   → [source code of login function]
4. Summarize the implementation for the user.
```

### Example 2: Trace Callers

User asks: "who calls the `validateToken` function?"

```
1. search_graph '{"project":"storage-test","query":"validateToken","limit":5}'
   → qualified_name: "storage-test.src.auth.middleware.validateToken"
2. trace_path '{"function_name":"validateToken","project":"storage-test","direction":"inbound","depth":2,"mode":"calls"}'
   → [list of caller functions with file locations]
```
