# Several fact tables, one set of shared dimensions

Most models end up with everything appended into one wide table, because
several fact tables feel harder to get right. They are not harder. They need
one rule, and the work is in what you do where that rule does not quite fit.

Built on WideWorldImportersDW — six fact tables, eight dimensions. See
[`../setup`](../setup) to get that database onto your own machine.

## The rule

- A fact table never connects to another fact table
- Facts connect to dimensions
- A dimension used by more than one fact filters all of them at once

That last line is the whole thing. Two facts appear together on one visual
because a dimension they share is filtering both, not because they are
connected to each other.

A dimension used by several facts is a **conformed dimension**. Section 4 of
[the exploration script](explore-before-you-model.sql) tells you which of yours
are conformed, and that result is effectively the model design.

## Before you import

Three settings, and two of them are on by default when they should not be.

| Setting | Where | What to do |
|---|---|---|
| Import relationships from data sources on first load | Options → Data Load | **Leave on.** If the warehouse declares foreign keys, Power BI mirrors them and builds most of the model for you |
| Autodetect new relationships after data is loaded | Options → Data Load | **Turn off.** This one guesses from column names |
| Auto date/time | Options → Data Load, current file | **Turn off.** It builds a hidden date table behind every date column, and a model like this has a lot of date columns |

Then mark your date dimension as a date table, and do not import the ETL
columns — `Lineage Key` here — that mean nothing to a report user.

## What Power BI can and cannot work out

With foreign keys declared, most relationships arrive built and correct.

What the database cannot tell it is which relationship to make **active**,
because only one can be. Where two foreign keys run between the same pair of
tables, Power BI picks one and quietly marks the other inactive. You may not
agree with the choice, and nothing warns you.

In this database that happens four times:

| Fact | Dimension | The two roles |
|---|---|---|
| Order | Date | Order date, picked date |
| Sale | Date | Invoice date, delivery date |
| Order | Employee | Picker, salesperson |
| Sale | Customer | Customer, bill-to |

## Role-playing dimensions

That is what those four are called. One dimension doing more than one job for
the same fact table.

Worth noticing that only two of the four are dates. Every tutorial on this
subject uses dates as the example, which leaves people thinking it is a date
problem. Employee playing picker and salesperson is the same problem, and so
is Customer playing customer and bill-to.

The symptom is quiet. Nothing errors. A measure asked for by picked date
answers by order date instead, and the number is simply wrong.

### Three ways to handle it

**1. Keep one relationship active, leave the rest inactive**, and switch to the
one you need inside a measure with `USERELATIONSHIP()`. One dimension table, no
duplicated columns, nothing extra in the field list. It needs measures, so it
is not in this video.

**2. Duplicate the dimension**, so the second role gets its own table and its
own active relationship.

**3. Put the attributes on the fact table itself** — Year, Month, Month ID
columns derived from the second date.

The choice is about scope rather than about which is better:

| | When it is right |
|---|---|
| 1 | The second role is needed in measures, not in slicers |
| 2 | The role is **shared across several facts** and one slicer should govern all of them |
| 3 | The role is **local to one fact** and only needs slicing and grouping |

Microsoft's own guidance prefers option 2, because inactive relationships do
not propagate row-level security and behave poorly in Q&A. That is worth
knowing before you choose option 1 on a model that will have RLS.

One thing that stops option 2 sounding unmanageable: **you duplicate per role,
not per fact table.** A delivery date used by three fact tables needs one extra
table, not three.

### Doing it: duplicating the dimension

Reference the dimension into a second query, name it for the role rather than
the source — `Bill To Customer`, not `Customer 2` — and prefix every column:
`Bill To Customer Name`, not `Customer Name`.

The prefix is the part people skip and the part that decides whether the model
is usable. If both tables have a column called `Customer Name`, users will drag
the wrong one and never know.

### Doing it: columns on the fact table

Efficiency here means query folding — letting SQL Server compute the columns
during refresh instead of Power Query doing it row by row.

```m
// These three fold to SQL Server
AddYear    = Table.AddColumn(Sale, "Delivery Year",
                each Date.Year([Delivery Date Key]), Int64.Type),

AddMonthNo = Table.AddColumn(AddYear, "Delivery Month Number",
                each Date.Month([Delivery Date Key]), Int64.Type),

AddMonthID = Table.AddColumn(AddMonthNo, "Delivery Month ID",
                each Date.Year([Delivery Date Key]) * 100
                   + Date.Month([Delivery Date Key]), Int64.Type),

// This one does NOT fold — month names are computed locally
AddMonth   = Table.AddColumn(AddMonthID, "Delivery Month",
                each Date.ToText([Delivery Date Key], "MMM", "en-GB"), type text)
```

Right-click each step and look for **View Native Query**. It is available on
the first three and greyed out on the last. If the local computation bothers
you, produce the month name in the source instead, with `DATENAME(month, ...)`.

Then in the model: `Delivery Month` → Column tools → Sort by Column →
`Delivery Month Number`, or May sorts after March.

Prefix these with the role as well. `Delivery Year`, not `Year`.

### Where option 3 catches people out

A column on a fact table filters **that fact table and nothing else**.

Put two facts on one visual, slice by a year column belonging to one of them,
and the other ignores the slicer completely — it shows its grand total against
every row. Nothing is broken and nothing warns you.

The same is true of any dimension that is not conformed. `Supplier` here
reaches Purchase and Movement and nothing else, so a supplier slicer leaves
Sale and Order showing totals.

That is the failure mode of the whole pattern. It is invisible unless you look,
and it is why the exploration in step 1 is worth ten minutes.

---

Video: [How to Connect Multiple Fact Tables in Power BI](https://youtu.be/ZUIOyV-Kluo)

Previous step: [Explore the source before you model it](01-explore-the-source.md)
