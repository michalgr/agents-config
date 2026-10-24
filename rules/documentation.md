# Commentary & Documentation Guidelines

## 1. In-Code Commentary & Human-Review Scaffolding
* **Three Levels of Commentary:**
  * Provide **module comments**, **class comments**, and **function comments**.
* **Separation of Docstrings and Implementation Comments:**
  * **Docstrings** document the *abstraction*: its purpose and how to use it (if not trivial).
  * **Non-docstring comments** (`#`, `//`, `/* */`) document *implementation details*, architectural context, and verification notes that help human readers quickly understand and audit the code.
* **The Math Textbook Principle (Master Plan & Context):**
  * Even when functions are small and well-named, human reviewers quickly get tired and lose context of *why* a particular function or class is needed.
  * **Module Master Plan:** Like a good math textbook, at the beginning of every module (chapter), write a comment explaining the **Master Plan** for the organization of the code—the key concepts, stages, and how the pieces fit together.
  * **Contextualizing Classes & Functions:** Leave **non-docstring comments** on each class and function contextualizing that code within the module's Master Plan (explaining why it exists and which step of the plan it fulfills). Do not put this Master Plan scaffolding inside docstrings.
  * **Keep the Master Plan in Sync (Anti-Drift):** Treat the Module Master Plan and contextualizing comments as first-class code. Whenever you add, remove, or refactor functions or classes in an existing module, update the Master Plan commentary as part of the change so it never becomes stale.
* **Non-Trivial Details & Avoided Edge Cases:**
  * Never write comments that merely restate what the syntax already says.
  * Always document non-trivial implementation details, invariants/assumptions, and **edge cases that we are actively avoiding or guarding against** (including why a seemingly simpler approach would fail).

## 2. Architectural & Design Documentation (`docs/*.md`)
* **When to Author `docs/*.md` (Beyond a Single Module):**
  * While a **Module Master Plan** explains the internals of a *single* file, any knowledge that spans multiple modules, describes system-wide behavior, or would bloat source files belongs in topic-focused Markdown files under `docs/` (e.g., `docs/architecture.md`, `docs/<subsystem>.md`, `docs/<protocol>.md`).
  * Do not let valuable architectural context vanish in chat history or PR descriptions—persist it in `docs/*.md`.
* **What Belongs in `docs/*.md`:**
  * **System & Data-Flow Diagrams:** Visualize cross-module component interactions, state machines, and request/data pipelines using **Mermaid diagrams** (`flowchart`, `sequenceDiagram`, `stateDiagram-v2`, `classDiagram`) and concise tables.
  * **Key Decisions & Trade-Offs (Design Rationale):** Document *why* a design, algorithm, or dependency was chosen, **which alternatives were considered and rejected**, and the constraints or invariants behind the decision. This prevents future reviewers and agents from re-litigating or accidentally breaking deliberate trade-offs.
  * **External Protocols, Schemas & Domain Contracts:** Document third-party APIs, wire formats, configuration matrices, and domain rules that the codebase integrates with.
  * **Learning Materials & External Sources:** Link to relevant external references—such as official specifications, RFCs, papers, upstream documentation, or technical articles—that provide domain background or explain the concepts/algorithms used.
* **Bidirectional Linking & High-Signal Content:**
  * **Link Code $\leftrightarrow$ Docs:** Reference the relevant `docs/<topic>.md` file from the participating modules' Master Plan comments (and `README.md`), and link back from `docs/<topic>.md` to the concrete entry-point source files.
  * **Explain Mental Models, Not Line-by-Line Code:** Focus `docs/*.md` on invariants, flows, schemas, and trade-offs rather than copy-pasting volatile code blocks that will quickly rot.
* **Keep `docs/` in Sync (Anti-Drift):**
  * Always check `docs/` when researching a codebase prior to making changes.
  * Treat `docs/*.md` as first-class deliverables: whenever a change alters system architecture, protocols, or design trade-offs, update the corresponding `docs/*.md` files in the same changeset.
