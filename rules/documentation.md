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
