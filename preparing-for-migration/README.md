# Preparing a semantic model for migration

Three things to do before you open Power BI Desktop and start rebuilding.


None of them is modelling work. All of them decide how much modelling work you
are about to do.
=======
Neither of them is modelling work. Both of them decide how much modelling
work you are about to do.


| | | |
|---|---|---|
| 1 | [Review the reports with the business](01-review-with-the-business.md) | What is used, what is missing, what can go. Usage metrics plus a questionnaire to report owners. |
| 2 | [Remove what is not used](02-remove-what-is-not-used.md) | Tables, columns and measures still sitting in the model that the reports no longer reference. Found with Measure Killer. |
| 3 | [Verify the documentation](03-verify-the-documentation.md) | An AI draft, verified against the extract, the source systems and the people who own them. |

Do them in this order. Step 1 tells you which reports survive, so there is no
point auditing the model against reports that are about to be retired. Step 2
produces the extract used in step 3.


Related video: [Preparing an existing model for optimisation](https://www.youtube.com/watch?v=uW1LsRH9OtM)
=======
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
>>>>>>> b75698854213bea8528a60a5015189534b5ae84b
