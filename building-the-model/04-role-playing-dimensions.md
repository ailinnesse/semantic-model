# Two dates, one fact table

Companion to the video:
[Two Dates in One Table: USERELATIONSHIP in Power BI](VIDEO-LINK-HERE)

`Fact Sale` has an invoice date and a delivery date. Both are dates. Both
should be able to use the same date dimension. Only one of them can.

This page covers the three ways to deal with that, what each one actually
changes, and how to choose.

---

## Why Power BI makes the second one inactive

Import both foreign keys and Power BI creates both relationships — then makes
one of them inactive, shown as a dotted line in the model view.

It has no choice. If both were active, a filter on `Dimension Date` would have
two paths to `Fact Sale` and no rule for picking one. The engine refuses
ambiguity rather than guessing, so it keeps one path and disables the other.

The inactive relationship is not broken. It is there, it is valid, and nothing
uses it until you ask for it by name.

**This is not only about dates.** In this model `Dimension Employee` plays two
roles on `Fact Order` — the salesperson and the picker — and
`Dimension Customer` plays two on `Fact Sale`, the customer and the bill-to
customer. Everything below applies to those the same way.

---

## The three approaches

### 1. Date parts on the fact table

Add the year and month of the second date as columns on the fact itself, in
Power Query. This is what
[the previous page](02-several-fact-tables.md) built:

```m
AddYear    = Table.AddColumn(Sale, "Delivery Year",
                each Date.Year([Delivery Date Key]), Int64.Type),
AddMonthNo = Table.AddColumn(AddYear, "Delivery Month Number",
                each Date.Month([Delivery Date Key]), Int64.Type),
AddMonthID = Table.AddColumn(AddMonthNo, "Delivery Month ID",
                each Date.Year([Delivery Date Key]) * 100
                   + Date.Month([Delivery Date Key]), Int64.Type),
// This one does NOT fold
AddMonth   = Table.AddColumn(AddMonthID, "Delivery Month",
                each Date.ToText([Delivery Date Key], "MMM", "en-GB"), type text)
```

No DAX, no measures, no extra tables. Drag `Delivery Year` onto an axis and
every measure in the model groups by it.

### 2. The inactive relationship, with USERELATIONSHIP

Leave the relationship inactive and switch it on for one calculation:

```dax
Sale Profit by Delivery Date =
CALCULATE (
    [Sale Profit],
    USERELATIONSHIP ( 'Dimension Date'[Date], 'Fact Sale'[Delivery Date Key] )
)
```

`USERELATIONSHIP` only works inside `CALCULATE` or `CALCULATETABLE`, and only
for the duration of that evaluation. The relationship it names has to already
exist in the model — it activates a relationship, it does not create one.

### 3. A duplicate dimension per role

Load the date dimension a second time as `Dimension Delivery Date`, with an
active relationship to `Delivery Date Key`. Two tables, two sets of columns,
two slicers, both active.

**Duplicate per role, not per fact table.** One `Dimension Delivery Date`
serves every fact with a delivery date. Duplicating per fact gives you four
date tables that mean the same thing and a field list nobody can navigate.

---

## What actually differs

This is the part the video spends most of its time on, and it is the reason
the first two approaches are not interchangeable.

**Date part columns change what you group by.**
**The relationship changes what you filter by.**

Put a date slicer on `Dimension Date` and build two charts, both with delivery
month on the axis:

| Chart | Filtered by | Grouped by |
|---|---|---|
| `[Sale Profit]` with `Delivery Year` / `Delivery Month` on the axis | invoice date, through the active relationship | delivery month |
| `[Sale Profit by Delivery Date]` with `Dimension Date` on the axis | **delivery date**, through the redirected relationship | delivery month |

The first chart answers "of the sales invoiced in this window, when were they
delivered". The second answers "what was delivered in this window". Those are
different questions, and only the second is what most people mean.

Through the middle of a wide date range the two charts look nearly identical,
because most rows are invoiced and delivered in the same month. **They come
apart at the edges of the range.** In this model, with the slicer set to
26 July 2014 – 14 July 2015, the final month differs by roughly ten per cent
while the middle months agree to within a rounding error.

That is what makes this worth a video. A chart that is right in the middle and
wrong at the ends is the kind of thing that survives review and then produces
a number nobody can explain in a meeting.

---

## Choosing

| | Date parts on the fact | USERELATIONSHIP | Duplicate dimension |
|---|---|---|---|
| Slice or group by the second date | Yes | No — measures only | Yes |
| Existing measures work unchanged | Yes | No — one measure per calculation | Yes |
| Filters the fact by the second date | **No** | Yes | Yes |
| Time intelligence on the second date | No | Yes | Yes |
| Holidays, fiscal periods, week numbers | No | Yes | Yes |
| Both dates on one visual at once | Yes | Awkward | Yes |
| Cost | Columns on the fact table | A measure per calculation | A second table |

**Use the columns** when people need to slice or group by the second date and
the numbers themselves stay on the primary date. Cheapest option by far, and
for a delivery month breakdown it is often all that is wanted.

**Use USERELATIONSHIP** when you need the same figure calculated on the second
date — profit by delivery date, with year-to-date and last year alongside it.
This is the only one of the three that gives you the full date dimension
without adding a table.

**Duplicate the dimension** when users will work with both roles at the same
time, in the same report, sliced independently. Two slicers on one page, one
for invoice date and one for delivery date, is not something the other two do
comfortably. This is usually the right answer for non-date roles —
salesperson and picker, customer and bill-to customer — because people want to
filter by both at once.

---

## Things that catch people out

**USERELATIONSHIP is not free at report level.** It works per measure. If the
users want ten figures by delivery date, that is ten measures. There is no way
to tell a whole visual "use the other relationship".

**Date part columns cannot do time intelligence.** `DATESYTD` and friends need
a real date column in a table marked as a date table. A `Delivery Month ID`
integer is not one.

**Sort your month column.** `Delivery Month` as text sorts April, August,
December unless you set Sort by Column to `Delivery Month Number`. The
`Delivery Month ID` column exists for sorting across year boundaries.

**`Date.ToText` does not fold.** Everything before it in the query above does.
If query folding matters on a large fact table, build the month name in the
source or in DAX instead.

**Check the format on a new measure.** A measure written by hand does not
inherit the format string from anything. `[Sale Profit]` shows pounds;
`[Sale Profit by Delivery Date]` shows a bare number until you set it.

**Name the measure for the question, not the mechanism.**
`Sale Profit by Delivery Date` tells a report user what they are getting.
`Sale Profit USERELATIONSHIP` tells them how it was built, which is not their
problem.

**Worth checking against current documentation:** `USERELATIONSHIP` has
restrictions in some configurations, including row-level security and
DirectQuery. If the model uses either, confirm the behaviour before relying on
it rather than taking this page's word for it.

---

## What is in the model

- `Fact Sale` → `Dimension Date`, active on the invoice date
- `Fact Sale` → `Dimension Date`, inactive on `Delivery Date Key`
- `Delivery Year`, `Delivery Month Number`, `Delivery Month ID`,
  `Delivery Month` on `Fact Sale`
- `[Sale Profit by Delivery Date]`, using `USERELATIONSHIP`

Both approaches are left in the model deliberately, so the comparison in the
video can be reproduced.

---

Video: [Two Dates in One Table: USERELATIONSHIP in Power BI](VIDEO-LINK-HERE)

Before this: [Generating measures with Tabular Editor](03-generate-the-measures.md)
