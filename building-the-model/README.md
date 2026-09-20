# Building the model

The preparation is done — you know which reports survive, what the old model
actually uses, and what the documentation says. Now you build the new one.

**1. [Explore the source before you model it](01-explore-the-source.md)**
Ten questions to ask the warehouse before you open Power BI Desktop. Which
dimensions are shared, which facts have several dates, what the database
already declares for you.
Script: [`explore-before-you-model.sql`](explore-before-you-model.sql)

**2. [Several fact tables, one set of shared dimensions](02-several-fact-tables.md)**
Building a model on six fact tables. What makes it work, what Power BI builds
for you, and what happens when one fact points at the same dimension twice.
Video: [How to Connect Multiple Fact Tables in Power BI](https://youtu.be/ZUIOyV-Kluo)

**3. [Generating measures with Tabular Editor](03-generate-the-measures.md)**
Base measures and time intelligence, written by script rather than by hand —
by setting up the columns once and letting the scripts read the model instead
of guessing from names. Includes what to change if you copy the scripts.
Scripts: [`base-measures.cs`](base-measures.cs) ·
[`time-intelligence.cs`](time-intelligence.cs)
Video: [Generate Power BI Measures with Tabular Editor](VIDEO-URL)

More to follow — working with the model as text, in TMDL and VS Code.

---

Before this: [Before you migrate](../preparing-for-migration)
