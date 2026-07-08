# Tool Quick Reference

All tools use the CLI interface:
```bash
codebase-memory-mcp cli <tool_name> '<json_args>'
```

## Tool List

| Tool | Description | Key Parameters |
|---|---|---|
| `list_projects` | List all indexed projects | (none — use `json` argument) |
| `index_repository` | Index a repository | `repo_path` (absolute path), `mode` (`"fast"`, `"moderate"`, `"full"`, `"cross-repo-intelligence"`) |
| `index_status` | Check if project index is ready | `project` |
| `detect_changes` | Find unindexed changes since last index | `project` |
| `search_graph` | Find functions/classes/routes by name or concept | `project`, `query` (BM25), `name_pattern` (regex), `semantic_query` (array), `label`, `file_pattern`, `limit`, `offset` |
| `trace_path` | Trace callers/callees or data flow | `project`, `function_name`, `direction` (`"inbound"`/`"outbound"`/`"both"`), `depth`, `mode` (`"calls"`/`"data_flow"`/`"cross_service"`), `include_tests` |
| `get_code_snippet` | Read source of a function/class | `project`, `qualified_name` (full name from search_graph) |
| `query_graph` | Run Cypher queries for complex patterns | `project`, `query` (Cypher string) |
| `get_architecture` | High-level project overview | `project`, `aspects` (array: `"summary"`, `"clusters"`) |
| `search_code` | grep + graph enrichment hybrid | `project`, `pattern`, `mode` (`"compact"`/`"full"`/`"files"`), `limit` |
| `get_graph_schema` | Show node types and edge types | `project` |
| `manage_adr` | Create/update Architecture Decision Records | `project`, ... |
| `ingest_traces` | Ingest runtime traces into the graph | `project`, ... |
| `delete_project` | Remove a project from the index | `project` |
