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

## 2. Code Structure: Orchestrators, Helpers, Types, and Modules
* **Entry Points (Orchestrators) and Helpers:**
  * Decompose high-level **entry points** (or **orchestrators**) into small, single-purpose **helper functions** that clearly communicate their meaning via descriptive names and precise signatures.
  * An entry point should read like a high-level workflow outline composed of helpers, allowing a human to verify the overall logic before inspecting individual helper implementations.
* **Pure Helpers & Explicit Side Effects (Functional Core, Imperative Shell):**
  * Keep helpers **pure** (deterministic data transformations, calculations, and validations) whenever possible.
  * Push I/O and state mutations up to the top-level **orchestrator** layer—or make mutation unmistakable in a helper's name and signature—so a reviewer can understand all side effects by reading the entry point alone.
* **Narrow Types & Boundary Assertions (Types as Documentation):**
  * Encode preconditions, postconditions, and domain invariants using **narrow, expressive types** wherever possible so invalid states are unrepresentable.
  * Prefer specific domain types, structs/dataclasses, enums, and descriptive type aliases over raw primitives (`str`, `int`, untyped `dict`/tuples) so that signatures serve as machine-checked documentation.
  * Where the type system cannot express an invariant, enforce it explicitly at function boundaries with guard clauses or assertions so human reviewers do not have to trace callers to verify assumptions.
* **Function Size ($\le 25$ lines) & Logical Cohesion:**
  * Keep functions (both entry points and helpers) up to **25 lines of code** (excluding docstrings and comments).
  * **Cohesion comes first:** Each helper must represent a coherent, self-contained conceptual step—do not slice code arbitrarily just to satisfy a line count. It is fine to occasionally exceed 25 lines when splitting would harm clarity, such as in long `match`/`switch` statements or exhaustive pattern matching.
* **Bottom-Up Code Order (`Definitions → Helpers → Entry Points`):**
  * Organize code within a module so that helper building blocks precede the entry points that use them, while keeping the top-down conceptual reasoning (`Definitions → Entry Points → Helpers`) in the module's top-of-file **outline** comment (when the module is complex enough to warrant one):
    1. **Definitions:** Core types, data structures, and constants (establishing the vocabulary and invariants first).
    2. **Helpers:** Internal helper functions ordered to build up toward the entry points they support.
    3. **Entry Points (Public API / Orchestrators):** Main public functions and high-level orchestrators that compose the helpers above.
* **Multi-Module Organization & Size Thresholds:**
  * Do not hesitate to group functions and classes across multiple cohesive modules ("chapters")—avoid single source files that grow into thousands of lines.
  * Treat **400, 800, and 1,200 lines** as escalating levels of "this module is getting too big":
    * **~400 lines (Checkpoint):** Pause and evaluate whether distinct sub-problems, secondary types, or helper groups should be extracted into their own module.
    * **~800 lines (Warning — Too Big):** Actively split the file into multiple focused modules unless there is a strong, explicit reason why the code cannot be separated.
    * **~1,200 lines (Critical Ceiling):** Unacceptable monolith. Must be decomposed into smaller modules immediately.
  * **Subsystem Table of Contents:** When a feature or subsystem spans multiple modules, include a **Table of Contents** comment in the package entry point (`__init__.py`, `mod.rs`, `index.ts`, or primary coordinator module) explaining the role of each module and the recommended reading order.

## 3. Language & Commit Metadata Standards
* **Write code and comments in English.** Always author code, comments, docstrings, documentation, and commit messages in English—even if the user communicates in another language—unless a project has explicitly established conventions to the contrary.
* **Descriptive Commit & PR Metadata:** Always provide a clear, descriptive commit/PR **Title** and a detailed **Description** explaining *what* changed and *why*.
