# Generating measures with Tabular Editor

Writing base measures by hand is slow and boring. Six fact tables with five
numeric columns each is thirty measures before you have written a single
interesting one, and then eight time intelligence variants on top of that.

Tabular Editor can write them for you. This page is the whole process, with
what each script does and what you need to change before running it on your
own model.

**Everything here uses Tabular Editor 2, which is free.**

Companion to the video
[Automate Power BI Measures with Tabular Editor](https://youtu.be/1B10t3dQX5M).

---

## The idea behind it

Most generator scripts guess. They look at a measure called `Total Revenue`,
see the word "Revenue", and decide it is currency. That works until someone
names a column `Revenue Count`, and it breaks quietly.

These scripts do not guess. They read two properties that already exist on
every column in your model:

| Property | What it decides |
|---|---|
| **Summarize By** | Whether a measure is created, which DAX function it uses, what it is called, and whether time intelligence applies |
| **Format String** | How the measure displays |

So the work splits into two halves. First you tell the model what its columns
mean, once. Then the scripts read that and do the typing.

If you remember one thing from this page: **the column carries the decision,
the script carries it out.**

---

## Before you start

- The model open in Power BI Desktop
- Tabular Editor 2 installed — it appears in the **External Tools** ribbon
- Fifteen minutes

---

## Step 1 · Create a table to hold the measures

In **Power BI Desktop**: Home → Enter Data. Leave the single default column
alone, name the table `_Measures`, and click Load.

The underscore puts it at the top of the field list, above your tables.

**Then** open Tabular Editor from External Tools.

> **In that order.** If Tabular Editor is already open when you create the
> table, it will not see it, and the generator in step 5 will stop with an
> error. Close and reopen it if that happens.

---

## Step 2 · Tell the model what its columns mean

Paste this into Tabular Editor's **C# Script** tab and run it.

```csharp
// Dimension columns are for slicing, not summing.
// Nobody wants a measure called "Total Calendar Year".
foreach(var c in Model.AllColumns.Where(c => c.Table.Name.StartsWith("Dimension")))
{
    c.SummarizeBy = AggregateFunction.None;
}

// Keys are plumbing. No measures, and hide them from report users.
foreach(var c in Model.AllColumns.Where(c => c.Name.EndsWith("Key")))
{
    c.SummarizeBy = AggregateFunction.None;
    c.IsHidden = true;
}

// Prices average. Adding up unit prices gives a meaningless number.
foreach(var c in Model.AllColumns.Where(c => c.Name.Contains("Price")))
{
    c.SummarizeBy = AggregateFunction.Average;
}

// Tax Rate gets no measure at all. An average tax rate should be weighted
// by the amount it applies to, and an unweighted one would mislead.
foreach(var c in Model.AllColumns.Where(c => c.Name.Contains("Rate")))
{
    c.SummarizeBy = AggregateFunction.None;
}
```

### What just happened

Four passes over every column in the model. Each one sets **Summarize By**,
which is the property Power BI uses to decide what happens when someone drags
a raw column onto a visual — and which the generator in step 5 reads.

Nothing has been created yet. This only writes settings.

### Change these for your model

| In the script | Change it to |
|---|---|
| `StartsWith("Dimension")` | Whatever your dimension tables are called — `Dim`, `D_`, or delete this loop if your tables are not named by type |
| `EndsWith("Key")` | Your key convention — `ID`, `_SK`, `Id` |
| `Contains("Price")` | Whatever your model calls things that should average — rates, unit costs, percentages |
| `Contains("Rate")` | Same. Or delete this loop if a rate measure is useful to you |

If your tables are not named in a pattern at all, skip the first loop and set
those columns by hand — Tabular Editor lets you Ctrl+click several columns in
the tree and change Summarize By for all of them at once.

---

## Step 3 · Check what is left

```csharp
Model.AllColumns
    .Where(c => c.SummarizeBy != AggregateFunction.None
             && c.SummarizeBy != AggregateFunction.Default
             && !c.IsHidden)
    .Output();
```

### What just happened

Nothing was changed. This opens a grid listing every column that will get a
measure in step 5 — it uses the exact same condition the generator does, so
what you see is what you will get.

The grid is editable. You can fix Summarize By and Format String there,
without going back to the tree.

Read the list. Fix what is wrong. Run it again. Two or three rounds.

**Keep this script.** You will run it again after step 4, once the formats
have been set, and it will show a different set of problems.

### What it found on this model

The preview is not a formality. On WideWorldImporters it caught five things,
and four of them would have produced measures that were confidently wrong:

| What | Why it matters |
|---|---|
| Every `WWI ... ID` column set to `Count` | These are the business keys. `Count of WWI Invoice ID` counts invoice lines. `Distinct Count` counts invoices, which is the number anyone actually wants |
| `Delivery Year`, `Delivery Month Number` set to `Sum` | The date-part columns from the previous video. Summing a year |
| `Reorder Level`, `Target Stock Level` set to `Sum` | Per-product thresholds. Adding them across products produces nothing meaningful |
| `Total Chiller Items`, `Total Dry Items` formatted as currency | Counts of items, caught by the word "Total" in step 4 |
| `Outstanding Balance` with no format | Money, but its name matches none of the currency words |

The first three are fixable with more passes:

```csharp
// Business IDs: how many invoices, not how many rows
foreach(var c in Model.AllColumns.Where(c => c.Name.EndsWith("ID")))
{
    c.SummarizeBy = AggregateFunction.DistinctCount;
}

// Date parts are for slicing, whatever table they live on
foreach(var c in Model.AllColumns.Where(c =>
    c.Name.EndsWith("Year") || c.Name.EndsWith("Month Number")))
{
    c.SummarizeBy = AggregateFunction.None;
}

// Thresholds are per product. Summing them means nothing
foreach(var c in Model.AllColumns.Where(c => c.Name.Contains("Level")))
{
    c.SummarizeBy = AggregateFunction.None;
}
```

The last two are handled in step 4.

### One thing it cannot tell you

A column whose Summarize By is `Default` — meaning nobody has ever set it — is
skipped silently, by this preview and by the generator.

So also look for anything you **expected** to see and did not. That is the only
way to catch a `Default`.

### Nothing to change

This script has no model-specific names in it. It works anywhere.

---

## Step 4 · Set the formats on the columns

```csharp
foreach(var c in Model.AllColumns.Where(c =>
    c.Name.Contains("Amount") || c.Name.Contains("Total") ||
    c.Name.Contains("Price")  || c.Name.Contains("Profit")))
{
    c.FormatString = @"""£""#,0.00;(""£""#,0.00);""£""#,0.00";
}
```

### What just happened

Every column whose name suggests money now displays as currency.

This matters more than it looks, because **a measure does not inherit its
column's format automatically**. The generator in step 5 copies it across
deliberately. So the format has to be right on the column *before* you
generate, or every measure comes out unformatted.

### Change these for your model

| In the script | Change it to |
|---|---|
| `£` in the format string, three times | `$`, `€`, or whatever you use. The doubled quotes are C# escaping — keep them |
| `Amount`, `Total`, `Price`, `Profit` | The words your model actually uses for money |

### Fix what a word list cannot get right

Matching on words produces two kinds of mistake, and this model has both.

**Caught something it should not have.** `Total Chiller Items` and
`Total Dry Items` are counts of items. They contain the word "Total", so they
now display as pounds:

```csharp
foreach(var c in Model.AllColumns.Where(c => c.Name.EndsWith("Items")))
{
    c.FormatString = "#,0";
}
```

**Missed something it should have caught.** `Outstanding Balance` is money and
matches none of the four words. No pattern will find it without also catching
things you do not want, so set it by hand — select the column and edit Format
String in the properties pane.

### Then run the preview from step 3 again

Now the format column has something in it, and both kinds of mistake are
visible in one list.

That is the honest part of this whole process. Not every column falls into a
pattern, and pretending otherwise is how you end up with a model that is 90%
right and quietly wrong in the other 10%. The preview is what stops the other
10% from being invisible.

---

## Step 5 · Generate the base measures

**Select one fact table in the tree first.** The script works on the selected
table, and does nothing without a selection.

Then run [`base-measures.cs`](base-measures.cs).

### What just happened

For every visible column on the selected table that has a Summarize By set,
you now have a measure in `_Measures` with:

- the right DAX function — `SUM`, `AVERAGE`, `MIN`, `MAX`, `COUNT` or
  `DISTINCTCOUNT`, taken from Summarize By
- a name that matches — `Sale Quantity` for a sum,
  `Sale Average Unit Price` for an average
- the column's format, copied across
- a description, which shows as a tooltip in Power BI
- two hidden annotations (see below)

Repeat for each fact table.

### About those annotations

An annotation is a hidden label you can attach to anything in the model. It
does not appear in Power BI, it does not affect any calculation, and it travels
with the model.

Each measure gets `Additive: Yes` or `Additive: No`, depending on its
aggregation. A sum is additive — sales in January plus sales in February is a
real number. An average is not.

The time intelligence script in step 6 reads that label instead of trying to
work it out from the measure's name. That is the whole trick, and it is why
there is no list of keywords anywhere in these scripts.

### Change these for your model

| In the script | Change it to |
|---|---|
| `Model.Tables["_Measures"]` | Your measures table's name, if you called it something else |
| `.Replace("Fact ", "")` | Whatever prefix your fact tables carry, so it is stripped from measure names |
| `.Replace("Dimension ", "")` | Same for dimensions |

---

## Step 6 · Generate the time intelligence

Run [`time-intelligence.cs`](time-intelligence.cs).

### What just happened

For every generated base measure, you now have up to eight more:

| | |
|---|---|
| `MTD` | Month to date |
| `YTD` | Year to date |
| `PMTD` | Previous month to date |
| `LY MTD` | Same month to date, last year |
| `LY YTD` | Year to date, last year |
| `YoY MTD %` | Change against last year, month to date |
| `YoY YTD %` | Change against last year, year to date |
| `MoM MTD %` | Change against last month |
| `Rolling 12M Average` | Twelve month average — **additive measures only** |

That last one is why the annotations exist. A twelve-month rolling average is
calculated as "the total over twelve months, divided by twelve". Do that to an
average, or to a distinct count, and the answer means nothing. So the script
creates it for sums and counts, and skips it for everything else.

### Change these for your model

| In the script | Change it to |
|---|---|
| `string DateColumn = "'Dimension Date'[Date]";` | **The most important line.** Your date table and column, exactly as named in your model. Get this wrong and nothing works |
| The eight blocks | Delete any variant you do not want. They are independent — removing one does not affect the others |

### Two things to know about the DAX

**The rolling average always divides by twelve**, whether or not twelve months
of data exist. The first eleven months of any dataset will read low. The
description on the measure says so, so nobody has to guess.

**It is safe to run twice.** Each generated measure is labelled
`GeneratedTI: Yes`, and the script skips anything carrying that label. Without
it, a second run would generate `Sales Quantity Rolling 12M Average YTD` and
other nonsense.

---

## Step 7 · Delete what should not exist

The scripts do the typing. They cannot do the thinking, and some of what they
produced is wrong for this model:

**A fact table with no date.** `Fact Stock Holding` is a snapshot of what is on
the shelf now. It has no date relationship, so every time intelligence measure
on it is meaningless. Delete them all.

**A balance.** `Outstanding Balance` is a position, not a flow. A rolling
average of it answers no question anyone is asking.

Go through the list and take out what does not belong. It takes two minutes,
and skipping it is how generated models get their reputation.

---

## Step 8 · Save

**Ctrl+S in Tabular Editor.**

Nothing reaches Power BI until you do this. If the field list has not changed,
this is why.

---

## Step 9 · Check it in Power BI

Drag one of the new measures onto a visual.

- It should be formatted correctly with no work from you
- Hover the measure name in the field list and the description appears

That tooltip is worth the whole exercise. It is the difference between a model
full of generated measures and a model that is documented, and it costs one
line of script.

---

## Everything you need to change, in one place

If you are copying these scripts to your own model, this is the list.

| Script | Line | What to put there |
|---|---|---|
| Step 2 | `StartsWith("Dimension")` | Your dimension table naming |
| Step 2 | `EndsWith("Key")` | Your key column naming |
| Step 2 | `Contains("Price")`, `Contains("Rate")` | Your words for things that average, or should have no measure |
| Step 4 | `£` (three times) | Your currency symbol |
| Step 4 | `Amount`, `Total`, `Price`, `Profit` | Your words for money |
| Step 5 | `Model.Tables["_Measures"]` | Your measures table name |
| Step 5 | `.Replace("Fact ", "")` | Your fact table prefix |
| Step 6 | `'Dimension Date'[Date]` | Your date table and column |

Everything else works unchanged.

---

## Afterwards: removing what nobody used

The obvious objection to all of this is that you have just created several
hundred measures, and nobody is going to use most of them.

That is true, and it is the point. Generating them costs seconds. Working out
in advance which ones the business will ask for costs weeks, and you will
guess wrong anyway. So generate everything, build the reports, and find out.

Then, once the reports exist and have settled down, remove what nothing
touches — with the same tool from
[earlier in this series](../preparing-for-migration/02-remove-what-is-not-used.md).
Measure Killer analyses the model and its reports together and tells you which
measures are actually referenced.

Two things worth knowing before you do it:

**It follows the chain.** `YoY MTD %` depends on `MTD` and `LY MTD`, which
depend on the base measure. If a report uses the percentage, Measure Killer
keeps everything underneath it. You will not break a measure by deleting
something it needs.

**Wait until the reports are finished.** Do this after the first report and
you will delete measures the second report was going to want. The whole
approach only works if the cleanup comes last.

Which is a reasonable shape for a model's life: generous at the start, when
generating is free and you do not yet know what matters. Tidy at the end, when
you do.

---

## What is not in this video

`USERELATIONSHIP`, and the inactive-relationship approach to role-playing
dimensions from the last video. It needs measures, which is why it could not go
there — and it is worth its own video rather than a corner of this one.

---

Video: [Automate Power BI Measures with Tabular Editor](https://youtu.be/1B10t3dQX5M)

Previous step: [Several fact tables, one set of shared dimensions](02-several-fact-tables.md)
