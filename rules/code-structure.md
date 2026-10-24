# Code Design & Structure Guidelines

## 1. Design & Implementation Philosophy
* **Prefer proper fixes over short-term hacks.** Do not resort to quick workarounds, copy-paste hacks, or temporary fixes that add technical debt. Focus on writing robust, correct, and clean solutions.
* **Understand the Agentic Era Economy:**
  * The economy of code writing and maintenance is different when working with AI agents. Because writing, refactoring, and maintaining clean code is highly accessible, we can afford to spend the effort to "do the right thing" from the start.
  * **AI writes code fast; humans are the bottleneck when reviewing and verifying it.** Always optimize code structure, types, tests, and commentary to minimize cognitive load and help human readers quickly understand and verify correctness.
  * Always prioritize the long-term maintainability, clean design, and structural correctness of the codebase.
* **Repository Precedence & Task Scope Discipline:**
  * Explicit repository-local conventions (`AGENTS.md`, `CONTRIBUTING.md`) take precedence over these global defaults when they conflict.
  * Apply structural and module-size refactoring to code within the scope of your task—do not perform unrelated mass-refactoring of untouched legacy files during a targeted bug fix.

## 2. Code Structure: Theorems, Lemmas, Types, and Modules
* **Functions as Theorems and Lemmas:**
  * Think of high-level functions as **theorems** that are broken down into **lemmas** (helper functions) which clearly communicate their meaning via descriptive names and clear signatures.
  * A theorem should read like a high-level proof outline composed of lemmas, allowing a human to verify the high-level logic before inspecting individual lemma implementations.
* **Pure Lemmas & Explicit Side Effects:**
  * Keep lemmas **pure** (deterministic data transformations and checks) whenever possible.
  * Push I/O and state mutations up to the orchestrating **theorem** layer—or make mutation unmistakable in a lemma's name and signature—so a reviewer can understand all side effects by reading the top-level theorem alone.
* **Proof by Type & Assertion (Types as Documentation):**
  * In mathematics, theorems explicitly state their hypotheses and conclusions. In code, encode preconditions, postconditions, and invariants using **narrow, expressive types** wherever possible.
  * Prefer specific domain types, structs/dataclasses, enums, and descriptive type aliases over raw primitives (`str`, `int`, untyped `dict`/tuples) so that signatures serve as machine-checked documentation.
  * Where the type system cannot express an invariant, enforce it explicitly at function boundaries with guard clauses or assertions so human reviewers do not have to trace callers to verify assumptions.
* **Function Size ($\le 25$ lines) & Logical Cohesion:**
  * Keep functions (both theorems and lemmas) up to **25 lines of code** (excluding docstrings and comments).
  * **Cohesion comes first:** Lemmas must make logical sense as self-contained conceptual steps—do not slice code arbitrarily just to satisfy a line count. It is fine to occasionally exceed 25 lines when splitting would harm clarity, such as in long `match`/`switch` statements or exhaustive pattern matching.
* **Reading Order (`Definitions → Theorems → Lemmas`):**
  * Provided the language allows it, organize code within a module in top-down order:
    1. **Definitions:** Core types, data structures, and constants (establishing the vocabulary and invariants first).
    2. **Theorems (Entry Points / Public API):** Main public functions and high-level orchestrators.
    3. **Lemmas (Helpers):** Helper functions ordered to follow the flow of the entry points they support.
  * **Mental Model Only (No Math Jargon in Code/Docs):** "Theorems" and "lemmas" are a mental model for structuring code—never write math terminology (`Theorem`, `Lemma`, `Proof`, `Corollary`) in code comments, section headers, identifiers, docstrings, or documentation. Use standard engineering terms (e.g., `Entry Points`, `Public API`, `Helper Functions`).
* **Multi-Module Organization & Size Thresholds:**
  * Do not hesitate to group functions and classes across multiple cohesive modules ("chapters")—avoid single source files that grow into thousands of lines.
  * Treat **400, 800, and 1,200 lines** as escalating levels of "this module is getting too big":
    * **~400 lines (Checkpoint):** Pause and evaluate whether distinct sub-problems, secondary types, or lemma families should be extracted into their own module.
    * **~800 lines (Warning — Too Big):** Actively split the file into multiple focused modules unless there is a strong, explicit reason why the code cannot be separated.
    * **~1,200 lines (Critical Ceiling):** Unacceptable monolith. Must be decomposed into smaller modules immediately.
  * **Subsystem Table of Contents:** When a feature or subsystem spans multiple modules, include a **Table of Contents** comment in the package entry point (`__init__.py`, `mod.rs`, `index.ts`, or primary coordinator module) explaining the role of each module and the recommended reading order.

## 3. Language & Commit Metadata Standards
* **Write code and comments in English.** Always author code, comments, docstrings, documentation, and commit messages in English—even if the user communicates in another language—unless a project has explicitly established conventions to the contrary.
* **Descriptive Commit & PR Metadata:** Always provide a clear, descriptive commit/PR **Title** and a detailed **Description** explaining *what* changed and *why*.
