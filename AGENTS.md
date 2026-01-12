# AGENTS.md

Agent-specific instructions for ComplyTime codebases.

---

## Quick Reference

**Critical Rules:**
- Use latest stable versions, pin when possible (no alpha/beta/rc)
- Centralize constants (no magic strings/numbers)
- Ask design questions BEFORE implementing features
- Ask lifecycle/retention questions BEFORE creating data storage
- Suggest production best practices for cloud resources

---

## Setup Commands

**Dependency Management:**
- Use latest stable versions (no alpha/beta/rc)
- Pin exact versions when possible (prefer `1.2.3` over `^1.2.3`)
- Use semantic versioning ranges (`^` or `~`) only when pinning is impractical

**Project Structure:**
- All repos must include: `README.md`, `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `.github/`
- Use Makefile for code-specific commands
- Configure pre-commit hooks via [pre-commit](https://pre-commit.com/)

---

## Code Style

**General:**
- Empty line at end of file (POSIX standard)
- Line length: 99 characters max (exceptions for readability)
- Write tests with descriptive names and edge cases

**Go:**
- File names: lowercase with underscores (`my_file.go`)
- Package names: short, lowercase, no underscores
- Always check and return errors
- Format with `goimports` and `go fmt`
- License header: `// SPDX-License-Identifier: Apache-2.0`
- Run `.golangci.yml` checks locally before PR

**Python:**
- Use type hints
- Format with `black` and `isort`
- Lint with `flake8`
- Type check with `mypy`
- License header: `# SPDX-License-Identifier: Apache-2.0`
- Non-Python files: use [Megalinter](https://github.com/oxsecurity/megalinter)

---

## Design Patterns

**Before Implementing Features:**
1. Ask: "Who is the specific User Persona for this feature?"
2. Ask: "What is the primary problem this solves for them?"
3. Ask: "Would you like to see a mock-up or non-functional prototype first?"
4. Do NOT output full implementation code until design intent is confirmed

**Before Creating Data Storage:**
1. Ask: "What is the retention policy for this data? (When do we delete it?)"
2. Ask: "Are there compliance requirements regarding immutability or encryption?"
3. Suggest default resource lifecycle policies in generated code

**Cloud Resources:**
- Do NOT provide minimal resources only
- ALWAYS append comment section listing "Production Best Practices" (e.g., Object Lock for S3, encryption at rest, public access blocking)
- Ask user if they want to enable these features

---

## Core Principles

**Single Source of Truth:**
- Centralize constants in dedicated files (`internal/consts/consts.go`, `settings.py`)
- No magic strings/numbers inline
- One change updates all references automatically

**Simplicity & Isolation:**
- Keep functions small and focused (Single Responsibility)
- Easier to test and maintain

**Readability:**
- Code is read 10x more than written
- Explicit naming (`days_until_expiration` not `d`)
- Avoid clever code
- Comments explain *why*, not *what*

**Efficiency:**
- Research existing solutions first
- Suggest dependencies based on risk assessment (adoption rate, governance model, maintenance frequency, community health)
- Vet dependencies before recommending

**Architecture:**
- Composability: tools should work together (JSON/YAML streams)
- Convention over configuration: sensible defaults

**Design Documentation:**
- Document design decisions in available location (check for `adr/`, `docs/design/`, or similar directories)
- If no standard location exists, use inline comments with clear references
- Include rationale, alternatives considered, and trade-offs

---

## Testing Instructions

- Write tests for all code changes
- Use descriptive test function names
- Include edge cases
- Run tests locally before committing
- Fix all test and type errors before PR

---

## PR Workflow

**Branching:**
- Create feature branches from `main`
- Keep PRs atomic (reviewable in one sitting)

**PR Requirements:**
- Title format: `<type>: <description>` (e.g., `feat: implement oscal validation logic`)
- Requires review from at least two Maintainers
- Must pass CI/CD checks (linting, testing, build)
- Exceptions: maintainers can discuss exceptions for external/transient failures

**Commits:**
- Follow [Conventional Commits](https://www.conventionalcommits.org/)

---

## Writing Guidelines

**Style:**
- Zero filler: eliminate introductory phrases
- Active voice only (never passive)
- Ruthless deletion: remove hedge words (*actually, basically, virtually, really, clearly*)

**Structure:**
- Bottom Line Up Front (BLUF): first sentence states status/critical action
- Tables: lean headers (1-2 words), cells are fragments not sentences
- Signposting: use bold headers for navigation

---

## Incremental Improvement

When working on a bug/feature:
- If you identify improvements (refactoring, formatting, naming), consider opening a **separate PR or Issue**
- Keep aesthetic changes separate from logic fixes
- Ensures PRs remain atomic and reviewable

---
