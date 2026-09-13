# Before you migrate: reviewing the reports you already have

The first step in rebuilding a semantic model is not technical. Before you
open Power BI Desktop, you need to know what the business actually uses, what
it needs, and what is wrong with what it has now.

Skip this and you will faithfully rebuild everything, including the things
nobody has opened in two years.

This is how we did it on a real reporting estate that had grown too large.

---

## The problem you are probably looking at

Our reports were bloated with things nobody read, and still missing things
people actually needed. Both were true at the same time.

Too many reports. Too much duplication. No single person responsible for any
of it.

Report bloat is not a data problem. It is an ownership problem.

---

## 1. Give every report an owner

Senior leadership assigned a business person, or sometimes a few, to every
report in the app. No orphan reports.

This one step does more than it looks like it does. The moment every report
has a name against it, the clutter has someone to answer for it.

---

## 2. Get the usage data first

Before asking anyone anything, pull the numbers. For each report:

• report views
• page views
• number of users
• frequency of use
• pages nobody opens

This gives the review context. Without it, the whole exercise becomes
opinion-based, and the loudest person in the room wins.

Low usage is not automatically a reason to delete. Sometimes it means the
report is hard to find, badly designed, or only useful at particular times of
year. Usage data tells you where to ask questions, not what to conclude.

---

## 3. Send a questionnaire to every report owner

One email per person, listing all the reports assigned to them. Each report
reviewed separately.

The questions:

• Why do we have this report?
• What is it used for?
• What matters most?
• What decision should it support?
• How often should people use it?
• What is missing?
• What can be removed?
• Any other recommendations?

Instead of asking "do we still need this?", ask **"what decision does this
report support?"**. That one question changes the conversation. It moves
people off habit and on to purpose, and it exposes the reports that exist only
because somebody built them once.

**Usage data shows what people actually use. The questionnaire shows what the
business actually needs. You need both before you cut or rebuild anything.**

---

## 4. Get everyone in one room

A full day, around fifteen leaders, every report in the app on the table.

Prepare a deck first, built from:

• usage metrics for each report
• page-level usage
• feedback from each report owner
• the major gaps
• suggested removals
• examples of possible updates

Make it a decision-making deck, not a specification. The goal is for everyone
in the room to see what is used, what is valued, what is missing, what can go,
and where reports overlap.

### Structure the day by value, not by report size

1. **Most used and most valued reports first.** These get the most attention,
   while everyone still has energy. Short break after each major report.
2. **Middle-priority reports in the middle of the day**, with lunch in the
   middle. Still discussed, but not in the same depth.
3. **Least-used reports together at the end.** Here the main question is
   simply whether the report is still needed. Often the better answer is to
   move a few useful pages into the right report and retire the rest.

The discussion will not be linear. People jump between reports, find
duplicated pages, and remember related problems halfway through something
else. That is normal and often useful. Let it happen, then bring the room back
to the report currently under review.

### The question that produced the most value

Alongside "should we keep this report?", ask "**how can this page help someone
understand what needs attention?**"

A page full of numbers is not always useful. Sometimes what it needs is:

• better highlighting
• clearer exceptions
• conditional formatting
• simpler visuals
• better titles
• fewer unnecessary metrics
• a clear callout for what changed
• focus on the decision the user has to make

This is what moves a page from "this has data" to "this helps someone act".

### What the session must produce

Clear decisions, per report: keep, cut, fix, merge, or move.

---

## 5. Rebuild, then send it back

Update based on the session, then send everything back to the owners to sign
off. The review is not finished until the person responsible has agreed to the
result.

---

## 6. Handing over is where most rebuilds fail

Not in the build. In the handover.

You can fix every calculation and clean every page, but if people do not
understand what changed, they will not trust it. If they do not trust it, they
quietly go back to their old spreadsheet.

**Write down every change.** A few changes can go on the relevant page. More
than that, add a "Key changes" page inside the report. It helps twice: when
stakeholders test, and later when users ask what is different.

**Use no technical language.** If you fixed a calculation, do not paste the
formula.

Instead of:

> Changed Average Cost from Total Cost divided by Row Count to Total Cost
> divided by Total Quantity.

Write:

> After reviewing with the report owner, we found Average Cost per item was
> wrong. It was dividing Total Cost by the number of rows. It now divides
> Total Cost by the total number of items.

Same change. Only one version gets checked by the person who cares.

**Make new features findable.** A feature nobody knows about does not exist.
Do not write "drill through available". Add a subtitle to the visual: "Right
click any product column, then Drill through, then Item Details." Name the
real page, say exactly where to click.

**Give testing a deadline and a task.** "Please have a look when you get a
chance" rarely works. Tell people exactly what to test, give them the date you
need feedback by, and ask them to check the numbers against a source they
trust. That last point matters most. Layout feedback is easy to give. Checking
the numbers is what catches real problems.

**Split the feedback before publishing.** People always come back with more
than you asked for, which is a good sign. But if you try to fix everything you
will never publish.

• Fix now: wrong numbers, broken logic, missing critical information
• Fix later: nice-to-have ideas, small polish

You are not saying no. You are saying not yet.

**Choose your publish day.** Not during month-end close. Not on a Friday
afternoon. Publish when users have time to look and you have time to answer.

**Tell everyone, not just the testers.** When it goes live, message all users:
what changed, why, and where to find the Key changes page. Your testers
already know. Everyone else does not.

---

## 7. Lock in the governance

No change ships without its owner's approval. That is what stops the bloat
from creeping back.

And keep an open mind. I published one report to production and had a change
request almost immediately. That is not a failure, that is the job. Reports
are not finished objects, they evolve with the business.

Evolving does not only mean adding more. Every time something goes in, ask
what can come out.

---

## Then, and only then, open the model

Once you know which reports survive and what they are for, you know what the
new semantic model has to support. That is the point at which the technical
work starts, and it is the subject of the rest of this series.
