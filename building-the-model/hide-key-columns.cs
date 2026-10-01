// ======================================================================
// Hide the key columns on every fact table
//
// Loops the model's relationships and hides the column on the many side
// of each one. That is the foreign key on the fact table, and no report
// user needs to see it.
//
// Why relationships rather than names: a filter on "Key" misses
// CustomerID, sk_product, FK_City and every other local convention.
// The relationships always know which columns are keys.
//
// The one side is left alone on purpose — it is sometimes the Date
// column, or an order number people filter on. Use
// list-dimension-side-keys.cs to review those and hide by hand.
//
// Hidden columns still filter. Relationships are unaffected.
// Nothing reaches Power BI until you save (Ctrl+S) in Tabular Editor.
//
// Tabular Editor 2 (free), External Tools in Power BI Desktop.
// ======================================================================

foreach (var r in Model.Relationships)
{
    r.FromColumn.IsHidden = true;
}
