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

**ALWAYS prefer graph tools** over grep/glob/file-search for code discovery.
See `/skill:codebase-memory-mcp` for the full workflow, CLI syntax, and common pitfalls.

Fall back to grep/glob only when:
- Searching for string literals, error messages, or config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- Graph tools return insufficient or empty results despite the project being indexed
