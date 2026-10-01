# Hide the key columns in one script

Companion to the video: [Hide the Fact Side of Every Relationship in Seconds](https://youtu.be/fVo0FjO3zqY)

The model works. The field list is still a mess, because every relationship
has a key column at each end and nobody needs to see most of them. Hiding
them one at a time is a job nobody finishes.

Tabular Editor 2 does it in three lines. The only real decision is how much
to hide.

---

## This is not only tidiness

When a column exists on both ends of a relationship and both copies are
visible, a report builder can pick the wrong one. The visual still renders.
The numbers are just wrong, quietly.

It matters most when the join column is something people genuinely use —
an order number, a product code, an invoice number. Slice by the copy on the
dimension and the filter travels through the relationship to every fact.
Slice by the copy on the fact table and it filters that fact only, so any
other measure on the page ignores it.

Nobody building a report can see which copy they picked. Hiding the fact-side
column removes the choice, and with it the bug.

That is the reason to run this on a model other people will build on, even if
the field list does not bother you.

---

## Look at both lists first

Every relationship has two columns. `FromColumn` is the many side — the key
on the fact table. `ToColumn` is the one side — the key on the dimension.

Print them and read them before hiding anything:

```csharp
Model.Relationships
    .Select(r => r.FromColumn)
    .Distinct()
    .ToList()
    .Output();
```

```csharp
Model.Relationships
    .Select(r => r.ToColumn)
    .Distinct()
    .ToList()
    .Output();
```

Script: [`list-relationship-columns.cs`](list-relationship-columns.cs)

`.Output()` on a single column opens its own window, so a loop gives you one
window per relationship. Collecting them into a list first gives one grid you
can read and sort. `Distinct()` matters on the one side, where a dimension key
appears once per fact joined to it.

The first list is usually uninteresting — keys on fact tables, all of them
noise, and all of them the duplicate-column trap above.

The second list is where models differ. It might be all surrogate keys, in
which case hide the lot. Or it might contain the `Date` column of the date
dimension, an order number people filter on, or a natural key, because not
every source carries a generated one.

---

## Two ways to hide

**The fact side only.** Safe in any model.

```csharp
foreach (var r in Model.Relationships)
{
    r.FromColumn.IsHidden = true;
}
```

**Both sides.** Tidier, when the one-side columns are genuinely keys.

```csharp
foreach (var r in Model.Relationships)
{
    r.FromColumn.IsHidden = true;
    r.ToColumn.IsHidden = true;
}
```

Script: [`hide-key-columns.cs`](hide-key-columns.cs)

---

## Choosing between them

Compare the two lists and ask which is less work:

- **Hide both sides, then unhide what should not have gone.** Right when the
  one-side list is mostly surrogate keys with one or two exceptions. Two
  columns to unhide is nothing.
- **Hide the fact side, then hide the rest by hand.** Right when the one-side
  list has a lot of real attributes in it, or when you are working on
  someone else's model and would rather not surprise anyone.

In the WideWorldImporters model, the date dimension joins on the `Date`
column itself, so hiding both sides takes the date out of every date slicer.
That one is worth unhiding immediately, and it is the reason to look at the
list before running anything.

---

## What it does not catch

**Only columns used in a relationship.** That is the whole basis of the
script, and it is also its limit. A key that joins nothing is invisible to it.

WideWorldImporters is full of them: `WWI Invoice ID`, `WWI Transaction Type
ID`, `WWI Payment Method ID`, `Supplier Invoice Number`. These are degenerate
keys — identifiers carried on the fact table with no dimension behind them.

Some are worse than a visible surrogate key, because they are numeric and
default to being summed. A user drags `WWI Invoice ID` onto a visual and gets
a total of invoice numbers, which is a number that means nothing and looks
like it means something.

So after running the script, look at what is left visible on the fact tables.
Anything that is an identifier rather than a measure needs either hiding, or
`Summarize By` set to None if people need to see it. The same preview habit
as [step 3](03-generate-the-measures.md).

---

## Why loop the relationships rather than the names

The obvious version filters on the column name:

```csharp
// Works until it doesn't
foreach (var c in Model.AllColumns.Where(c => c.Name.EndsWith("Key")))
{
    c.IsHidden = true;
}
```

That catches `Customer Key` and misses `CustomerID`, `sk_product`, `FK_City`
and whatever the last developer called them. Most models have at least one.

WideWorldImporters is unusually disciplined — every key really is called
something Key — which is exactly why a name-based rule looks fine here and
falls over on the first real model you meet.

The relationships do not depend on a convention. Every relationship has a
column on each end, and those columns are keys by definition.

Same principle as the measure scripts in
[step 3](03-generate-the-measures.md): read what the model knows instead of
guessing from names.

---

## Things worth knowing

**Hidden columns still filter.** Hiding a key changes the report field list
and nothing else. The relationship works exactly as before, and every measure
that depends on it is unaffected.

**Nothing reaches Power BI until you save.** Ctrl+S in Tabular Editor, then
the field list updates in Desktop.

**Inactive relationships are included.** The loop covers every relationship in
the model, active or not, so the second date key from
[step 4](04-role-playing-dimensions.md) gets hidden along with the first.

**Unhiding is one property.** Select the column in Tabular Editor, set
`IsHidden` back to false, save. That is why hiding too much is a smaller
mistake than it sounds.
