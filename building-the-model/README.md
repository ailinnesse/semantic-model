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
Video: [How to Connect Multiple Fact Tables in Power BI](VIDEO-URL)

More to follow — generating measures, and working with the model as text.

---

Before this: [Before you migrate](../preparing-for-migration)
