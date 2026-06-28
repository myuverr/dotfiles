# 认知纪律 (全项目通用)

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

# Codebase Knowledge Graph (codebase-memory-mcp)

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.
ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

## Priority Order
1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `query_graph` — run Cypher queries for complex patterns
5. `get_architecture` — high-level project summary

## When to fall back to grep/glob
- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results
