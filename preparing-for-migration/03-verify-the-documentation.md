# Verify the documentation

Before you can rebuild a semantic model, you need to know what the old one
actually does. Writing that down by hand is slow, and an AI model will draft it
from your source material in minutes.

The draft is worth having. It is not worth trusting.

## What went in

- The Python scripts from the old system, holding most of the transformation
  logic
- The semantic model extract from Measure Killer, from
  [step 2](02-remove-what-is-not-used.md#export-what-is-in-use) — the tables,
  columns and measures the reports reference

Both inputs were correct. The documentation that came back still was not.

## What came back wrong

| What was wrong | Why it happens |
|---|---|
| Tables and columns missing altogether, including some that were in the extract | Giving an AI the source material does not guarantee all of it reaches the output |
| Table and column names that did not match the source systems | Names get normalised, abbreviated or guessed at |
| Only some joins extracted, and a few of those wrong | Join logic is spread across scripts and easy to reconstruct incorrectly |
| No filters at all | They were never asked for |

The last one is the one to remember. A complete-looking answer is still only an
answer to the question that was asked.

## The checklist

1. **Compare the draft against the extract, in both directions.** Everything on
   the extract should appear in the documentation. Everything in the
   documentation that is not on the extract needs explaining.
2. **Check names against the source systems**, not against the draft's own
   internal logic. A draft can be perfectly self-consistent and still wrong.
3. **Verify each join against the actual source keys.** A join that looks
   plausible is the hardest of these errors to notice later, because nothing
   breaks — the numbers are just wrong.
4. **Ask again for what you did not ask for the first time** — filters,
   defaults, business rules, anything applied before the data reached the
   model.
5. **Take the remainder to the people who own the source systems.** They will
   answer in minutes what would otherwise take an afternoon of guessing.

Step 1 catches the most and is the easiest to skip, because the extract went in
as an input and it feels redundant to check the output against it. It is not.

## What a mismatch actually means

Something in the documentation that is not on the extract is not automatically
wrong. There are three possibilities, and they need different responses:

| | What to do |
|---|---|
| It is part of the underlying transformation logic, upstream of the model | Keep it. The extract only covers what the reports reference. |
| It exists but nothing uses it any more | Note it and leave it out of the new model. |
| The AI introduced it incorrectly | Remove it, and check whether anything near it is wrong too. |

## Notes

- The extract covers what the **reports** reference. Transformation logic that
  happens before the model will never appear on it, so absence from the extract
  is a question, not a verdict.
- Check what you are allowed to send to an AI service before you send it.
  Source code and schema details from a production system are usually covered
  by a policy, and the policy is not always the same as what the tool's terms
  say.
- If your environment allows it, the better input is the TMDL of the cleaned
  model alongside the source scripts. More structure going in means less
  reconstruction, and less reconstruction means fewer invented names.

---

Previous step: [Remove what is not used](02-remove-what-is-not-used.md)
