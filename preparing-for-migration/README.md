# Preparing a semantic model for migration

Two things to do before you open Power BI Desktop and start rebuilding.

Neither of them is modelling work. Both of them decide how much modelling
work you are about to do.

| | | |
|---|---|---|
| 1 | [Review the reports with the business](01-review-with-the-business.md) | What is used, what is missing, what can go. Usage metrics plus a questionnaire to report owners. |
| 2 | [Remove what is not used](02-remove-what-is-not-used.md) | Tables, columns and measures still sitting in the model that no report touches. Found with Measure Killer. |

Do them in that order. Step 1 tells you which reports survive. There is no
point auditing a model against reports that are about to be retired.

The same Measure Killer analysis in step 2 gives you a second thing: a list of
every table, column and measure the reports actually use. Exported to Excel,
that is the base of your migration documentation. It tells you what the new
model has to support.

## Follow along

The model, the reports and the exports from the video are in
[`follow-along`](follow-along), so you can run the same analysis yourself.

## Videos

- [Prepare a Power BI Semantic Model for Migration with Measure Killer](https://youtu.be/4AV4RcsLBN4)
- [Using Measure Killer to find unused tables, columns and measures across all connected reports](https://youtu.be/uW1LsRH9OtM)
