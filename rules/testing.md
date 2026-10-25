# Testing Guidelines

## 1. Philosophy: Tests as First-Class Code (Combating Reviewer Fatigue)
* **Uphold Strict Quality Where Humans Are Most Fatigued:**
  * Human reviewers typically spend most of their cognitive energy auditing production code and are mentally drained by the time they reach test files—often skimming or ignoring tests if CI is green.
  * Left unchecked, this blind spot turns the test suite into a dumping ground of technical debt. As an agent, you must hold test code to the **exact same architectural and readability standards** as production code.
* **All Code Structure & Documentation Rules Apply to Tests:**
  * Test files and test helpers must follow all rules in `code-structure.md` and `documentation.md`: decompose test logic into high-level **test cases** (entry points) and **pure test helpers** (setup/assertion helpers $\le 25$ lines of logic; declarative table-driven test data arrays may exceed 25 lines when cohesive), organize code in `Definitions → Helpers → Test Cases` order (documenting non-trivial testing strategies in the top-of-file outline per Section 2, rather than listing test case names), use narrow types, and enforce the **400 / 800 / 1,200-line** module size thresholds.

## 2. Documented Testing Strategy
* **Establish & Document a Testing Strategy per Component:**
  * Do not add reactive, ad-hoc test cases without a coherent plan. Every component or test suite must have a well-thought-out testing strategy.
  * When a test file has non-trivial setup or verifies multiple invariants, document its testing strategy in a top-of-file outline comment (and in `docs/*.md` when the strategy spans multiple modules or integration boundaries):
    * **Target invariants & contracts:** Explain what domain invariants, guarantees, and edge/boundary conditions the suite verifies.
    * **Test organization & scope:** Explain how tests are structured (e.g., pure unit tests, table-driven cases, fake-backed integration tests) and what is tested elsewhere.
  * **Natural prose, no artificial rule banners:** Explain the strategy naturally without emitting artificial labels (`Testing Strategy`, `Target Invariants & Contracts`, `Module Outline`) as literal section headers. If a small test file's scope is already self-evident from its test names, do not write a redundant top-of-file outline.
  * Keep the documented testing strategy in sync whenever new behaviors or invariants are added.

## 3. Test Invariants & Contracts, Not Implementation (No Status-Quo Lock-In)
* **Avoid Overspecification ("Change-Detector" Tests):**
  * Never write tests that lock in incidental implementation details—such as internal helper call sequences, private data structures, arbitrary ordering, or brittle mock interaction counts.
  * **The Refactoring Litmus Test:** Ask yourself: *"If we completely rewrote this component's internal algorithm or data structures while preserving its public contract, would these tests still pass unmodified?"* If not, the test is overspecified and must be redesigned around public contracts and observable behavior.
* **Tests as Concise "Worked Examples" of Invariants:**
  * Structure each test so a human reader can immediately see **what invariant is being established** without wading through noise.
  * Only specify the inputs and state fields that are causally relevant to the invariant under test; hide irrelevant boilerplate behind sensible defaults or shared builders.
  * Use table-driven tests and descriptive test helpers so each case reads like a self-contained verification of a specific boundary condition or invariant.

## 4. Shared Test Infrastructure as High-Priority Architecture
* **No Ad-Hoc, Throwaway Test Plumbing:**
  * Never scatter quick, one-off test harnesses, copy-pasted setup blocks, or inline mock wiring across individual test files. Simple, file-local setup helpers may live in that test file's helper functions section, whereas reusable or non-trivial infrastructure must be shared.
* **Treat Test Infrastructure as High-Priority Production Code:**
  * When testing requires fixtures, domain builders, in-memory fakes, simulators, or custom assertion DSLs reused across test files (or involving non-trivial logic), build them as **shared, reusable infrastructure** in dedicated modules (e.g., `testutil/`, `testing/`, `fixtures/`).
  * Apply strict design, typing, and documentation standards to shared test infrastructure—it is a high-leverage architectural foundation of the repository.
* **Prefer Composable Fakes & Builders Over Brittle Mocks:**
  * Favor high-fidelity, reusable in-memory fakes and fluent test data builders over per-test mock expectation chains that couple tests to internal implementation mechanics.
