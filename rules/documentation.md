# Commentary & Documentation Guidelines

## 1. In-Code Commentary & Human-Review Scaffolding
* **Three Levels of Commentary:**
  * Provide **module comments**, **class comments**, and **function comments**.
* **Separation of Docstrings and Implementation Comments:**
  * **Docstrings** document the *abstraction*: its purpose and how to use it (if not trivial).
  * **Non-docstring comments** (`#`, `//`, `/* */`) document *implementation details*, architectural context, and verification notes that help human readers quickly understand and audit the code.
* **The Math Textbook Principle (Module Outline & Context):**
  * Because code places helper functions before entry points (`Definitions → Lemmas → Theorems`), human reviewers reading from top to bottom can easily lose context of *why* a particular helper function or class is needed before reaching the entry point.
  * **Module Outline (`Definitions → Theorems → Lemmas`):** If an outline would only list the contents of the module, **do not write one**. Write a top-of-file outline when there are non-trivial reasons why the module is complex and requires multiple helpers (lemmas): follow top-down conceptual order (`Definitions → Theorems → Lemmas`) to discuss *why* that complexity exists, map those reasons to the high-level entry points (theorems), and create a conceptual anchor for each helper (lemma) so the reader understands its role before encountering it in the code.
  * **Contextualizing Classes & Functions:** Leave **non-docstring comments** on non-trivial classes and functions (or logical groups of helpers) tying them back to their anchor in the module's outline (explaining why the helper exists and which step of the reasoning it fulfills) when this is not already self-evident from their name and signature. Do not put this structural scaffolding inside docstrings, and in languages where doc comments use `//` or `///` (such as Go or Rust), place it above logical section boundaries or cleanly integrated so `godoc`/`rustdoc` attachment is never broken.
  * **No Rule or Math Jargon in Code or Documentation:** While these guidelines use "theorems", "lemmas", and "module outline" as an internal mental model for code decomposition, **never** emit math jargon (`Theorem`, `Lemma`, `Proof`, `Corollary`) or artificial rule labels (`Master Plan`, `Module Outline`) in code comments, section headers, docstrings, commit messages, or `docs/*.md`—it is surprising to engineers. Write natural prose or use standard software engineering terminology (e.g., `Overview`, `Definitions`, `Helper Functions`, `Public API` / `Entry Points`).
  * **Keep the Module Outline in Sync (Anti-Drift):** Treat the top-of-file module outline and contextualizing comments as first-class code. Whenever you add, remove, or refactor functions or classes in an existing module, update the commentary as part of the change so it never becomes stale.
* **Non-Trivial Details & Avoided Edge Cases:**
  * Never write comments that merely restate what the syntax already says.
  * Always document non-trivial implementation details, invariants/assumptions, and **edge cases that we are actively avoiding or guarding against** (including why a seemingly simpler approach would fail).

## 2. Architectural & Design Documentation (`docs/*.md`)
* **When to Author `docs/*.md` (Beyond a Single Module):**
  * While a **Module Outline** explains the internals of a *single* file, substantial knowledge that spans multiple modules, describes system-wide behavior, or would bloat source files belongs in topic-focused Markdown files under `docs/` (e.g., `docs/architecture.md`, `docs/<subsystem>.md`, `docs/<protocol>.md`).
  * Do not let valuable architectural context vanish in chat history or PR descriptions—persist it in `docs/*.md`. Conversely, do not create boilerplate `docs/*.md` files for routine localized bug fixes or minor changes.
* **What Belongs in `docs/*.md`:**
  * **System & Data-Flow Diagrams:** Visualize cross-module component interactions, state machines, and request/data pipelines using **Mermaid diagrams** (`flowchart`, `sequenceDiagram`, `stateDiagram-v2`, `classDiagram`) and concise tables.
  * **Key Decisions & Trade-Offs (Design Rationale):** Document *why* a design, algorithm, or dependency was chosen, **which alternatives were considered and rejected**, and the constraints or invariants behind the decision. This prevents future reviewers and agents from re-litigating or accidentally breaking deliberate trade-offs.
  * **External Protocols, Schemas & Domain Contracts:** Document third-party APIs, wire formats, configuration matrices, and domain rules that the codebase integrates with.
  * **Learning Materials & External Sources:** Link to relevant external references—such as official specifications, RFCs, papers, upstream documentation, or technical articles—that provide domain background or explain the concepts/algorithms used.
* **Bidirectional Linking & High-Signal Content:**
  * **Link Code $\leftrightarrow$ Docs:** Reference the relevant `docs/<topic>.md` file from the participating modules' top-of-file outline comments (and `README.md`), and link back from `docs/<topic>.md` to the concrete entry-point source files.
  * **Explain Mental Models, Not Line-by-Line Code:** Focus `docs/*.md` on invariants, flows, schemas, and trade-offs rather than copy-pasting volatile code blocks that will quickly rot.
* **Keep `docs/` in Sync (Anti-Drift):**
  * Always check `docs/` when researching a codebase prior to making changes.
  * Treat `docs/*.md` as first-class deliverables: whenever a change alters system architecture, protocols, or design trade-offs, update the corresponding `docs/*.md` files in the same changeset.
