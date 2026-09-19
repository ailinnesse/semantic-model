# Explore the source before you model it

Ten questions, about ten minutes, and you start building knowing what you are
building on.

Run [`explore-before-you-model.sql`](explore-before-you-model.sql) against your
warehouse. Sections 1 to 6 run as they are. Sections 7 to 10 need your own
table and column names, except the first query in section 9, which writes the
rest for you.

Written against WideWorldImportersDW — see [`../setup`](../setup) for getting
that onto your own machine — but the queries read the system catalogue, so they
work on any SQL Server warehouse once you change the schema names.

## What each question tells you

| | Question | What you do with the answer |
|---|---|---|
| 1 | What tables are there, and how big | Decides what to look at closely. Not what is a fact — see below. |
| 2 | What are the key columns, and what type | Decides what joins to what, and catches type mismatches before they cost you an hour |
| 3 | What is the primary key of each dimension | The "one" side of every relationship you are about to build |
| 4 | Which dimensions are shared between facts | **This is the model.** Everything else is mechanics |
| 5 | What relationships the database declares | Usually none, which is why auto-detect should be off |
| 6 | Which facts have dates, and how many | Finds your role-playing dates, and any fact the date dimension cannot filter |
| 7 | Does a dimension keep history | Explains oversized dimensions, and warns you not to "clean them up" |
| 8 | Do the fact dates fit inside the date dimension | Catches blank-row rows before a total looks wrong |
| 9 | Are there unknown members, and how much do they hold | Decides whether missing values read as "Unknown" or as blank, and how much of the fact table that covers |
| 10 | Do two facts describe the same events | Stops someone counting the same transactions twice |

## Question 4 is the one that matters

A key that appears in several fact tables is a conformed dimension: one table in
the model, filtering all of those facts at once. That is what lets two facts sit
on one visual under one slicer, and it is the whole reason several fact tables
work at all.

A key that appears in one fact only filters that fact. Nothing else.

Read that result and the model has designed itself. The rest is dragging lines.

## Five things this database taught me

**Row count does not tell you what is a fact.** `Dimension.City` has 116,295
rows — more than three of the six fact tables — because it keeps six versions of
every city. `Fact.[Stock Holding]` has 227, because it is a snapshot of what is
on the shelf rather than a record of things that happened.

**A dimension that keeps history must not be filtered to current rows.** The
instinct is to clean it up. Do that and every fact row pointing at an older
version loses its dimension. Count the business key, not the rows, and leave the
table alone.

**Check the date range before you build.** The date dimension here covers four
years exactly. Anything outside that window joins to nothing and lands on the
blank row, which is a confusing thing to find halfway through a demo.

**Unknown is not always missing.** Every dimension here has exactly one Unknown
row, and 37% of three separate fact tables point at it. Broken down by
transaction type, whole categories are 100% unknown — a stock receipt has no
customer and never did. That is correct data about transactions the dimension
does not apply to, not a gap in the load.

**Two facts can be the same events.** Filtering movements to stock issues gives
exactly the row count of the sales table, because one records the money and the
other records the stock. Nothing to fix, but put a measure from each on one
visual and you are counting the same transactions twice.

## Then: multiple dates on one fact

Question 6 will find fact tables with more than one date. Power BI allows one
active relationship between two tables, so the second one arrives inactive and
is quietly ignored until you deal with it.

Three ways to deal with it, and the choice is about scope rather than about
which is better:

| | When it is right |
|---|---|
| Pick one date as the active relationship and ignore the rest | Nothing ever asks by the other date |
| Year and Month columns on the fact table itself | The second date is only ever used **within that one fact**. Cheap, keeps the field list clean, works in slicers and matrix headers |
| A second date table for that role | The second date is a concept **shared across several facts** and one slicer should govern all of them |

Microsoft's guidance is to prefer active relationships, which means duplicating
the date table per role — and note that it is per *role*, not per fact table. A
delivery date used by three facts needs one extra table, not three.

The thing to know about columns on the fact table: they filter that fact and
nothing else. Put two facts on one visual, slice by a year column belonging to
one of them, and the other will ignore it.

---

Reference: [Active vs inactive relationship guidance](https://learn.microsoft.com/en-us/power-bi/guidance/relationships-active-inactive),
[Understand star schema and the importance for Power BI](https://learn.microsoft.com/en-us/power-bi/guidance/star-schema)
