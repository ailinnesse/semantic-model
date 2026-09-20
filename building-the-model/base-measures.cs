// ======================================================================
// Generate base measures from the column's own settings
//
// Nothing here guesses from measure names. Two properties on the column
// decide everything:
//
//   SummarizeBy   -> which DAX function, what the measure is called,
//                    and whether time intelligence applies
//   FormatString  -> how the measure displays
//
// Set those on the columns once, and every script downstream reads them
// instead of matching on words.
// ======================================================================

if(!Model.Tables.Contains("_Measures"))
{
    Error("No _Measures table. Create one before running this.");
    return;
}

var measureTable = Model.Tables["_Measures"];

string tableName = Selected.Table.Name
    .Replace("Fact ", "")
    .Replace("Dimension ", "");

foreach(var c in Selected.Table.Columns.Where(c => !c.IsHidden))
{
    string dax;          // DAX aggregation function
    string namePrefix;   // what the measure is called
    bool   isAdditive;   // can it be summed across time

    switch(c.SummarizeBy)
    {
        case AggregateFunction.Sum:
            dax = "SUM";           namePrefix = "";                   isAdditive = true;  break;

        case AggregateFunction.Average:
            dax = "AVERAGE";       namePrefix = "Average ";           isAdditive = false; break;

        case AggregateFunction.Min:
            dax = "MIN";           namePrefix = "Min ";               isAdditive = false; break;

        case AggregateFunction.Max:
            dax = "MAX";           namePrefix = "Max ";               isAdditive = false; break;

        case AggregateFunction.Count:
            dax = "COUNT";         namePrefix = "Count of ";          isAdditive = true;  break;

        case AggregateFunction.DistinctCount:
            dax = "DISTINCTCOUNT"; namePrefix = "Distinct Count of "; isAdditive = false; break;

        // None, and Default, produce nothing.
        // Default is the one to watch: it means nobody has decided,
        // and the column is silently skipped.
        default:
            continue;
    }

    string measureName = tableName + " " + namePrefix + c.Name;

    if(Model.AllMeasures.Any(meas =>
        meas.Name.Equals(measureName, StringComparison.OrdinalIgnoreCase)))
        continue;

    // ------------------------------------------------------------------
    // Format: the column carries the decision. Measures do not inherit
    // it automatically, so copy it deliberately.
    //
    // If an average comes out with the wrong number of decimals, fix the
    // column's format rather than adding a rule here.
    // ------------------------------------------------------------------
    string format = c.FormatString;

    if(string.IsNullOrEmpty(format))
        format = (c.DataType == DataType.Int64) ? "#,0" : "#,0.00";

    // The one exception. A count is a whole number whatever the column is.
    if(dax == "COUNT" || dax == "DISTINCTCOUNT")
        format = "#,0";

    // ------------------------------------------------------------------

    var measure = measureTable.AddMeasure(
        measureName,
        dax + "(" + c.DaxObjectFullName + ")"
    );

    measure.DisplayFolder = tableName;
    measure.FormatString  = format;

    measure.Description = namePrefix.Length > 0
        ? namePrefix.Trim() + " of " + c.Name + " from " + Selected.Table.Name
        : "Total " + c.Name + " from " + Selected.Table.Name;

    // Recorded so the time intelligence script does not have to guess
    // from the measure's name.
    measure.SetAnnotation("Aggregation", dax);
    measure.SetAnnotation("Additive", isAdditive ? "Yes" : "No");
}
