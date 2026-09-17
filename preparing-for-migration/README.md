# Before you migrate

Three things to do before you open Power BI Desktop and start rebuilding.

None of them is modelling work. All of them decide how much modelling work you
are about to do.

**1. [Review the reports with the business](01-review-with-the-business.md)**
What is used, what is missing, what can go. Usage metrics plus a questionnaire
to report owners.

**2. [Remove what is not used](02-remove-what-is-not-used.md)**
Tables, columns and measures still sitting in the model that the reports no
longer reference. Found with Measure Killer, which also exports the list of
what *is* used — the base of the migration documentation.
Video: [Prepare a Power BI Semantic Model for Migration with Measure Killer](https://www.youtube.com/watch?v=4AV4RcsLBN4)

**3. [Verify the documentation](03-verify-the-documentation.md)**
An AI draft, verified against the extract, the source systems and the people
who own them.

Do them in this order. Step 1 tells you which reports survive, so there is no
point auditing the model against reports that are about to be retired. Step 2
produces the extract used in step 3.

## Following along

[`follow-along/`](follow-along/) has the model, the reports and the SQL from
the video, so you can run the analysis yourself rather than watch me do it.
