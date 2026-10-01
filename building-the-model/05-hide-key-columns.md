# Hide the key columns in one script

Companion to the video: [TITLE](VIDEO-LINK-HERE)

The model works. The field list is still a mess, because every fact table is
carrying its foreign keys and nobody needs to see them. Hiding them one at a
time is a job nobody finishes.

Three lines in Tabular Editor 2 hide all of them at once.

```csharp
foreach (var r in Model.Relationships)
{
    r.FromColumn.IsHidden = true;
}
```

Script: [`hide-key-columns.cs`](hide-key-columns.cs)

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

The relationships do not depend on a convention. Every relationship has a
column on each end, and the one on the many side is a key by definition.

Same principle as the measure scripts in
[step 3](03-generate-the-measures.md): read what the model knows instead of
guessing from names.

---

## It hides the fact side only, on purpose

`FromColumn` is the many side — the foreign key on the fact table. Nobody
needs to see those.

`ToColumn` is the one side, and that column is **not** always a surrogate key.
It is often:

- the `Date` column of the date dimension
- an order number or invoice number people filter on
- a natural key, in any model where not every source carries a generated one

Hiding those automatically would take the date out of every date slicer in
the report.

So list them first and decide by hand:

```csharp
foreach (var r in Model.Relationships)
{
    r.ToColumn.Output();
}
```

Script: [`list-dimension-side-keys.cs`](list-dimension-side-keys.cs)

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

**If a report genuinely needs a key visible** — a drillthrough target, or
something you are debugging — unhide that one column afterwards. One
exception is cheaper than skipping the script.
