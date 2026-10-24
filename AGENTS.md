# Agent Rules & Guidelines

These global rules apply to all AI agents across all projects and workspaces.

## 1. Git Commit Policy
* **Never commit changes on your own.** You must not execute `git commit` or any automated commit commands autonomously.
* **Always ask for explicit approval.** Before any commit is made, you must present the proposed commit to the user.
* **Present clear commit metadata.** You must show:
  * A clear and descriptive commit **Title**.
  * A detailed commit **Description** explaining *what* changed and *why*.
  * The exact command or changes you wish to pass to git.
* Wait for the user to explicitly approve or accept the commit before running it.

## 2. Design & Implementation Philosophy
* **Prefer proper fixes over short-term hacks.** Do not resort to quick workarounds, copy-paste hacks, or temporary fixes that add technical debt. Focus on writing robust, correct, and clean solutions.
* **Understand the Agentic Era Economy:**
  * The economy of code writing and maintenance is different when working with AI agents. Because writing, refactoring, and maintaining clean code is highly accessible, we can afford to spend the effort to "do the right thing" from the start.
  * **AI writes code fast; humans are the bottleneck when reviewing and verifying it.** Always optimize code structure, types, tests, and commentary to minimize cognitive load and help human readers quickly understand and verify correctness.
  * Always prioritize the long-term maintainability, clean design, and structural correctness of the codebase.

## 3. Code Structure: Theorems, Lemmas, Types, and Modules
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
    2. **Theorems:** Main public functions and high-level entry points.
    3. **Lemmas:** Helper functions ordered to follow the flow of the theorems they support.
* **Multi-Module Organization & Size Thresholds:**
  * Do not hesitate to group functions and classes across multiple cohesive modules ("chapters")—avoid single source files that grow into thousands of lines.
  * Treat **400, 800, and 1,200 lines** as escalating levels of "this module is getting too big":
    * **~400 lines (Checkpoint):** Pause and evaluate whether distinct sub-problems, secondary types, or lemma families should be extracted into their own module.
    * **~800 lines (Warning — Too Big):** Actively split the file into multiple focused modules unless there is a strong, explicit reason why the code cannot be separated.
    * **~1,200 lines (Critical Ceiling):** Unacceptable monolith. Must be decomposed into smaller modules immediately.
  * **Subsystem Table of Contents:** When a feature or subsystem spans multiple modules, include a **Table of Contents** comment in the package entry point (`__init__.py`, `mod.rs`, `index.ts`, or primary coordinator module) explaining the role of each module and the recommended reading order.
* **Tests as "Worked Examples" (No Copy-Paste Test Bloat):**
  * Apply the same human-review standards to tests. Structure tests as concise **worked examples** that demonstrate theorems, invariants, and boundary conditions.
  * Use shared test lemmas/fixtures and table-driven tests so each test case clearly highlights *what is being verified* without drowning the reviewer in hundreds of lines of repetitive setup boilerplate.

## 4. Documentation & Human-Review Commentary
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

## 5. Language Standards
* **Write code and comments in English.** Always author code, comments, docstrings, documentation, and commit messages in English—even if the user communicates in another language—unless a project has explicitly established conventions to the contrary.
