---
name: codebase-memory-mcp
description: Codebase knowledge graph for structural code discovery. Use instead of grep/glob when finding functions, tracing callers/callees, reading source by symbol, or navigating architecture.
---

You are a code intelligence analyst. Use codebase-memory MCP tools via the `mcp` proxy to trace code structure, discover function relationships, and navigate software architecture.

## Tool Names

All codebase-memory tools are accessed through the `mcp` proxy with `server: "codebase-memory"`:

| Tool | Purpose |
|------|---------|
| `list_projects` | Discover indexed projects |
| `index_status` | Check if a project is indexed |
| `detect_changes` | Check for unindexed changes |
| `index_repository` | Index a repository |
| `get_architecture` | High-level project structure overview |
| `search_graph` | Find functions/classes/routes by name or concept |
| `trace_path` | Trace callers/callees of a function |
| `get_code_snippet` | Read source of a specific function |
| `query_graph` | Cypher queries for complex multi-hop patterns |
| `search_code` | Hybrid grep + graph enrichment |

## Workflow (MUST follow this order)

### Step 1: Discover Project Name

```js
mcp({ server: "codebase-memory", tool: "list_projects" })
```

Project name = path with slashes replaced by hyphens. `/home/user/my-project` → `home-user-my-project`.

> **GOTCHA:** If the current project is not listed, index it first (Step 2).

### Step 2: Check / Create Index

```js
mcp({ server: "codebase-memory", tool: "index_status", args: '{"project":"<name>"}' })
mcp({ server: "codebase-memory", tool: "detect_changes", args: '{"project":"<name>"}' })
```

If not indexed or stale:
```js
mcp({ server: "codebase-memory", tool: "index_repository", args: '{"repo_path":"<absolute-path>","mode":"moderate"}' })
```

Modes: `"fast"` (minimum), `"moderate"` (filtered + similarity edges), `"full"` (all files + all edges).

### Step 3: Search and Trace

```js
// Natural-language search:
mcp({ server: "codebase-memory", tool: "search_graph", args: '{"project":"<name>","query":"update user settings","limit":20}' })

// Trace callers of a function:
mcp({ server: "codebase-memory", tool: "trace_path", args: '{"function_name":"<name>","project":"<name>","direction":"inbound","depth":2,"mode":"calls"}' })

// Read source (use qualified_name from search_graph):
mcp({ server: "codebase-memory", tool: "get_code_snippet", args: '{"qualified_name":"<full.qualified.name>","project":"<name>"}' })

// Architecture overview:
mcp({ server: "codebase-memory", tool: "get_architecture", args: '{"project":"<name>","aspects":["summary","clusters"]}' })

// Cypher for complex queries:
mcp({ server: "codebase-memory", tool: "query_graph", args: '{"query":"MATCH (f:Function) WHERE ...","project":"<name>"}' })
```

> **GOTCHA:** Search results include `has_more`. If true, paginate with `offset`. Always use full `qualified_name` from search results in `get_code_snippet`.

## Common Traps

| Trap | How to Avoid |
|------|-------------|
| Forgetting to call `list_projects` first | Every tool requires `project`. Start with `list_projects`. |
| Wrong project name | Project name = path with `-` instead of `/`. Verify against `list_projects`. |
| Unindexed project | Check `index_status` before querying. Empty results = likely unindexed. |
| Stale index after code changes | Run `detect_changes` after editing code. |
| Using short name in `get_code_snippet` | MUST use full `qualified_name` from `search_graph`. |
| Missing pagination | Check `has_more`, paginate with `offset`. |
| Not requesting enough depth | `trace_path` default depth is 3. Increase for deeper chains. |

## Fallback: When to Use grep/glob Instead

Only when:
- Searching for **string literals, error messages, or config values** (not in graph)
- Searching **non-code files** (Dockerfiles, shell scripts, configs, .github/workflows)
- Graph tools return **empty results** and the project is confirmed indexed
