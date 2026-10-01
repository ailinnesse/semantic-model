// ======================================================================
// List the columns at both ends of every relationship
//
// Run this before hiding anything, and read both lists.
//
// The many side (FromColumn) is the key on the fact table. Usually all
// noise, and the side a report builder can pick by mistake.
//
// The one side (ToColumn) is the key on the dimension. Sometimes all
// surrogate keys, sometimes it includes the Date column, an order number
// or a natural key that belongs in slicers and visuals.
//
// Compare the two lists and decide which is less work: hide both sides
// and unhide the exceptions, or hide the fact side and do the rest by
// hand.
//
// Distinct() matters on the one side - a dimension key appears in as
// many relationships as there are facts joined to it.
//
// Run one block at a time. The output window shows the last result.
// ======================================================================


// ----- The many side: keys on the fact tables -------------------------

Model.Relationships
    .Select(r => r.FromColumn)
    .Distinct()
    .ToList()
    .Output();


// ----- The one side: keys on the dimensions ---------------------------

// Model.Relationships
//     .Select(r => r.ToColumn)
//     .Distinct()
//     .ToList()
//     .Output();
