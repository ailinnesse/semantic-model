# Remove what is not used

One thing that shows up surprisingly often is tables and columns that stay in
the model long after anything stopped using them. Nobody removes them, because
nobody is certain they are safe to remove.

Tracking them down by hand is difficult, particularly when several reports are
built on the same semantic model. You would have to open every report, every
page and every visual, and still check calculations and relationships
afterwards.

## Use Measure Killer

Measure Killer is an external tool that analyses a model and its reports
together, and tells you which tables, columns and measures are actually used.

The reason to use it rather than checking manually is not only speed. It looks
at usage across calculations, relationships, filters and visuals, so you are
much less likely to remove something that is still needed somewhere you did
not think to look.

Measure Killer has a free version and a paid one. Check which of the features
you need are in the free tier before you plan around it, since the workspace
level analysis is not all free.

## Things to keep in mind

- Check Lineage View first, to see which reports are connected to the model
- Paginated reports are not analysed by Measure Killer and have to be checked separately
- Columns used in relationships are marked as used, even when the table itself may not actually be needed
- It is an external tool, so it has to be downloaded and installed before it appears in Power BI Desktop

That third point is worth repeating. A column being marked as used because a
relationship depends on it does not mean the relationship, or the table behind
it, earns its place. Read the result, do not just follow it.

## The workflow

1. Open **Lineage View** in the workspace to see what is connected to the
   semantic model
2. Download the model and every connected report, and put them in the same
   folder
3. Open the model in Power BI Desktop
4. Go to **External Tools**, then **Measure Killer**
5. Choose either a single report, or a model with multiple reports
6. Add the reports to the analysis
7. Click **Analyze**
8. Review the list of used and unused tables, columns and measures
9. Remove the unnecessary ones from the model

## Afterwards

Write down what you removed. If something turns out to have been needed, you
want to know exactly what went, rather than working backwards from a broken
visual.

Refresh and open each report again before you publish anything. The analysis
is reliable, but a five minute check costs less than a broken report in front
of a stakeholder.

In many cases this step alone reveals more unused data than expected, and
clearing it out makes everything that follows easier: a smaller model, faster
refreshes, and a field list people can actually navigate.

---

Related video: [Preparing an existing model for optimisation](https://www.youtube.com/watch?v=uW1LsRH9OtM)
