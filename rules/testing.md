# Testing Guidelines

* **Tests as "Worked Examples" (No Copy-Paste Test Bloat):**
  * Apply the same human-review standards to tests as to production code. Structure tests as concise **worked examples** that demonstrate theorems, invariants, and boundary conditions.
  * Use shared test lemmas/fixtures and table-driven tests so each test case clearly highlights *what is being verified* without drowning the reviewer in hundreds of lines of repetitive setup boilerplate.
