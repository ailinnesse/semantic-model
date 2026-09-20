// ======================================================================
// Generate time intelligence measures
//
// Reads two annotations written by the base measure script:
//   Additive     Yes / No   - can this be summed across time
//   GeneratedTI  Yes        - written here, so re-runs skip its own output
//
// No keyword matching on measure names anywhere.
// ======================================================================

string DateColumn = "'Dimension Date'[Date]";

// Snapshot. Prevents processing measures created during this run.
var BaseMeasures = Model.AllMeasures.ToList();

foreach (var m in BaseMeasures)
{
    // Skip anything this script created on a previous run.
    if (m.GetAnnotation("GeneratedTI") == "Yes")
        continue;

    // Only measures the base script generated carry this annotation.
    // Hand-written measures have none and are left alone.
    string additive = m.GetAnnotation("Additive");
    if (string.IsNullOrEmpty(additive))
        continue;

    string measureName = m.Name;
    string folder      = m.DisplayFolder;
    string baseRef     = "[" + measureName + "]";

    string mtdName       = measureName + " MTD";
    string ytdName       = measureName + " YTD";
    string pmtdName      = measureName + " PMTD";
    string lyMtdName     = measureName + " LY MTD";
    string lyYtdName     = measureName + " LY YTD";
    string yoyMtdPctName = measureName + " YoY MTD %";
    string yoyYtdPctName = measureName + " YoY YTD %";
    string momMtdPctName = measureName + " MoM MTD %";
    string rolling12Name = measureName + " Rolling 12M Average";

    // ==================================================================
    // MTD
    // ==================================================================
    if (!Model.AllMeasures.Any(x => x.Name.Equals(mtdName, StringComparison.OrdinalIgnoreCase)))
    {
        var nm = m.Table.AddMeasure(
            mtdName,
            "CALCULATE(\n" +
            "    " + baseRef + ",\n" +
            "    DATESMTD(" + DateColumn + ")\n" +
            ")"
        );

        nm.DisplayFolder = folder;
        nm.FormatString  = m.FormatString;
        nm.Description   = "Month-to-date calculation for [" + measureName + "].";
        nm.SetAnnotation("GeneratedTI", "Yes");
    }

    // ==================================================================
    // YTD
    // ==================================================================
    if (!Model.AllMeasures.Any(x => x.Name.Equals(ytdName, StringComparison.OrdinalIgnoreCase)))
    {
        var nm = m.Table.AddMeasure(
            ytdName,
            "CALCULATE(\n" +
            "    " + baseRef + ",\n" +
            "    DATESYTD(" + DateColumn + ")\n" +
            ")"
        );

        nm.DisplayFolder = folder;
        nm.FormatString  = m.FormatString;
        nm.Description   = "Year-to-date calculation for [" + measureName + "].";
        nm.SetAnnotation("GeneratedTI", "Yes");
    }

    // ==================================================================
    // PMTD - previous month to date
    // ==================================================================
    if (!Model.AllMeasures.Any(x => x.Name.Equals(pmtdName, StringComparison.OrdinalIgnoreCase)))
    {
        var nm = m.Table.AddMeasure(
            pmtdName,
            "CALCULATE(\n" +
            "    " + baseRef + ",\n" +
            "    DATESMTD(\n" +
            "        DATEADD(\n" +
            "            " + DateColumn + ",\n" +
            "            -1,\n" +
            "            MONTH\n" +
            "        )\n" +
            "    )\n" +
            ")"
        );

        nm.DisplayFolder = folder;
        nm.FormatString  = m.FormatString;
        nm.Description   = "Previous month to date calculation for [" + measureName + "].";
        nm.SetAnnotation("GeneratedTI", "Yes");
    }

    // ==================================================================
    // LY MTD
    // ==================================================================
    if (!Model.AllMeasures.Any(x => x.Name.Equals(lyMtdName, StringComparison.OrdinalIgnoreCase)))
    {
        var nm = m.Table.AddMeasure(
            lyMtdName,
            "CALCULATE(\n" +
            "    [" + mtdName + "],\n" +
            "    SAMEPERIODLASTYEAR(" + DateColumn + ")\n" +
            ")"
        );

        nm.DisplayFolder = folder;
        nm.FormatString  = m.FormatString;
        nm.Description   = "Prior year month to date calculation for [" + measureName + "].";
        nm.SetAnnotation("GeneratedTI", "Yes");
    }

    // ==================================================================
    // LY YTD
    // ==================================================================
    if (!Model.AllMeasures.Any(x => x.Name.Equals(lyYtdName, StringComparison.OrdinalIgnoreCase)))
    {
        var nm = m.Table.AddMeasure(
            lyYtdName,
            "CALCULATE(\n" +
            "    [" + ytdName + "],\n" +
            "    SAMEPERIODLASTYEAR(" + DateColumn + ")\n" +
            ")"
        );

        nm.DisplayFolder = folder;
        nm.FormatString  = m.FormatString;
        nm.Description   = "Prior year year to date calculation for [" + measureName + "].";
        nm.SetAnnotation("GeneratedTI", "Yes");
    }

    // ==================================================================
    // YoY MTD %
    // ==================================================================
    if (!Model.AllMeasures.Any(x => x.Name.Equals(yoyMtdPctName, StringComparison.OrdinalIgnoreCase)))
    {
        var nm = m.Table.AddMeasure(
            yoyMtdPctName,
            "DIVIDE(\n" +
            "    [" + mtdName + "] - [" + lyMtdName + "],\n" +
            "    [" + lyMtdName + "]\n" +
            ")"
        );

        nm.DisplayFolder = folder;
        nm.FormatString  = "0.00%;-0.00%;0.00%";
        nm.Description   = "Year-over-year MTD percentage change for [" + measureName + "].";
        nm.SetAnnotation("GeneratedTI", "Yes");
    }

    // ==================================================================
    // YoY YTD %
    // ==================================================================
    if (!Model.AllMeasures.Any(x => x.Name.Equals(yoyYtdPctName, StringComparison.OrdinalIgnoreCase)))
    {
        var nm = m.Table.AddMeasure(
            yoyYtdPctName,
            "DIVIDE(\n" +
            "    [" + ytdName + "] - [" + lyYtdName + "],\n" +
            "    [" + lyYtdName + "]\n" +
            ")"
        );

        nm.DisplayFolder = folder;
        nm.FormatString  = "0.00%;-0.00%;0.00%";
        nm.Description   = "Year-over-year YTD percentage change for [" + measureName + "].";
        nm.SetAnnotation("GeneratedTI", "Yes");
    }

    // ==================================================================
    // MoM MTD %
    // ==================================================================
    if (!Model.AllMeasures.Any(x => x.Name.Equals(momMtdPctName, StringComparison.OrdinalIgnoreCase)))
    {
        var nm = m.Table.AddMeasure(
            momMtdPctName,
            "DIVIDE(\n" +
            "    [" + mtdName + "] - [" + pmtdName + "],\n" +
            "    [" + pmtdName + "]\n" +
            ")"
        );

        nm.DisplayFolder = folder;
        nm.FormatString  = "0.00%;-0.00%;0.00%";
        nm.Description   = "Month-over-month MTD percentage change for [" + measureName + "].";
        nm.SetAnnotation("GeneratedTI", "Yes");
    }

    // ==================================================================
    // Rolling 12 month average
    //
    // Only for additive measures. Averaging an average, or a distinct
    // count, and dividing by 12 gives a number that means nothing.
    // ==================================================================
    if (additive == "Yes" &&
        !Model.AllMeasures.Any(x => x.Name.Equals(rolling12Name, StringComparison.OrdinalIgnoreCase)))
    {
        var nm = m.Table.AddMeasure(
            rolling12Name,
            "VAR se = EOMONTH(MAX(" + DateColumn + "),0)\n" +
            "VAR _12m = DATE(YEAR(se)-1,MONTH(se)+1,1)\n" +
            "RETURN\n" +
            "CALCULATE(\n" +
            "    " + baseRef + ",\n" +
            "    DATESBETWEEN(\n" +
            "        " + DateColumn + ",\n" +
            "        _12m,\n" +
            "        se\n" +
            "    )\n" +
            ")/12"
        );

        nm.DisplayFolder = folder;
        nm.FormatString  = m.FormatString;
        nm.Description   = "Twelve month rolling average for [" + measureName +
                           "]. Always divides by 12, so the first eleven months of " +
                           "data read low.";
        nm.SetAnnotation("GeneratedTI", "Yes");
    }
}
