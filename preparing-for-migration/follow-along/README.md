# Follow along

The files from the video, so you can run the same analysis yourself instead of
watching me do it.

Everything here is the **before** state: a semantic model built on a single
table with all the facts appended into it, plus the reports built on top of it.
That is the model that gets analysed in the video.

## What is here

| File | What it is |
|---|---|
| [`old-model.pbix`](old-model.pbix)| The model before anything was removed. Start here. |
| [`old model pbip`](old model pbip)| The before model again, in PBIP format. Text files, so you can read the TMDL and see what changed in git rather than in a dialog. |
| [`old model after Measure Killer.pbix`](old model after Measure Killer.pbix)| The same model after the Measure Killer TMDL export was applied. The end state, if you want to compare. |
| [`order report.pbix`](order report.pbix)| Report built on the model |
| [`purchase report.pbix`](purchase report.pbix)| Report built on the model |
| [`sale report.pbix`](sale report.pbix)| Report built on the model |
| [`smt.pbix`](smt.pbix)| Report built on the model, combining several record types rather than only one|
| [`model.xlsx`](model.xlsx)| The Measure Killer export: every table, column and measure the reports actually use. The base of the migration documentation. |


## Before you start

You do not need a database to look at these. The models have their data
imported, so they open and work on their own.

You only need SQL Server if you want to refresh them. If you do:

1. Follow [`../../setup`](../../setup) to get SQL Server and the sample
   databases in place
2. Run [`build-flat-table.sql`](build-flat-table.sql) to create the
   appended table the model reads from

## Pointing it at your own server

The model has two Power Query parameters:

| Parameter | Default |
|---|---|
| `Server` | `localhost` |
| `Database` | `WideWorldImportersDW` |

Change those two values rather than editing the queries. Home → Transform data
→ Manage parameters.

## Using these with Measure Killer

Measure Killer analyses the model and its reports together, so **keep the
model and all the report files in the same folder**. If you move the reports
somewhere else, the analysis will show far more as unused than really is.

Then: open the model in Power BI Desktop, External Tools → Measure Killer,
choose the option for a model with multiple reports, add the reports, and
Analyze.

## What the video does with them

1. Runs the analysis across the model and all three reports
2. Exports clean TMDL, pastes it into the model's TMDL view and runs it
3. Exports the list of tables, columns and measures that are in use, as the
   base for the migration documentation

The cleaned `.pbix` is the result of step 2, if you want to check your own
against it.

---

Video: [Prepare a Power BI Semantic Model for Migration with Measure Killer](https://youtu.be/4AV4RcsLBN4)
