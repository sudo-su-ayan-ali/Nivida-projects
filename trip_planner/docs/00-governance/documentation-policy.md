# Documentation Governance Policy & Quality Standards

- **Status:** Approved
- **Owner:** Technical Documentation Lead / Engineering Standards
- **Last Updated:** 2026-10-28
- **Related Documents:** [`definition-of-done.md`](definition-of-done.md), [`../../rules.md`](../../rules.md)

---

## 1. Core Policy Principles

1. **Code and Documentation are Synchronous**: Documentation is not a post-project chore. No pull request with structural, schema, or functional changes will be merged without updating the corresponding documentation in `docs/`.
2. **Identifiable Source of Truth**: Every feature, schema table, external integration, and architectural pattern must trace back to a markdown document in `docs/`.
3. **No Empty Placeholder Files**: Scaffold folders when necessary, but author documents only when their phase requires them. Every created document must have substantial, actionable engineering content.
4. **Verified Content Only**: Never document hypothetical APIs as "integrated" or test results as "passed" without executed evidence.

---

## 2. Standard Document Structure & Lifecycle

Every document in the `docs/` hierarchy must lead with a standardized metadata block:

```markdown
# [Title]

- **Status:** Draft | In Review | Approved | Superseded
- **Owner:** [Role / Lead]
- **Last Updated:** YYYY-MM-DD
- **Related Documents:** [`[link]`](path/to/doc.md)
```

### Document Status Lifecycle
```text
Draft  ───►  In Review  ───►  Approved  ───►  Superseded (with pointer to replacement)
```

---

## 3. Formatting & Linking Rules

- **Relative Links**: Always use relative markdown links (`[`file`](../04-architecture/...)`) to ensure portability across Git web interfaces and local IDEs.
- **Code Fences**: Use language-specific code fences (`dart`, `sql`, `yaml`, `json`, `bash`).
- **Visuals**: Use Mermaid diagrams for architecture, sequence flows, ERDs, and state lifecycles:
  - Supported types: `flowchart TD/LR`, `sequenceDiagram`, `stateDiagram-v2`, `erDiagram`.
- **Alerts**: Use GitHub-style blockquote alerts strategically (`> [!NOTE]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`). Do not nest them consecutively.
