/*═══════════════════════════════════════════════════════════════════════
  EXPLORING A WAREHOUSE BEFORE YOU MODEL IT

  Nine questions to answer before you open Power BI Desktop. Answering
  them takes about ten minutes and saves rebuilding the model twice.

  Written against WideWorldImportersDW, which puts its tables in a
  `Fact` and a `Dimension` schema. If your warehouse does not, change
  the schema names in the WHERE clauses — everything else still works.

  ─────────────────────────────────────────────────────────────────────
   1 · What tables are there, and how big                    runs as-is
   2 · What are the key columns, and what type                runs as-is
   3 · What is the primary key of each dimension              runs as-is
   4 · Which dimensions are shared between facts              runs as-is
   5 · What relationships does the database already declare   runs as-is
   6 · Which facts have dates, and how many                   runs as-is
   7 · Does a dimension keep history                          edit names
   8 · Do the fact dates fit inside the date dimension        edit names
   9 · Are there unknown members, and how much do they hold   mixed
  10 · Do two facts describe the same events                  edit names
  ─────────────────────────────────────────────────────────────────────
═══════════════════════════════════════════════════════════════════════*/

USE WideWorldImportersDW;
GO


/*───────────────────────────────────────────────────────────────────────
  1 · WHAT TABLES ARE THERE, AND HOW BIG

  Do not assume facts are big and dimensions are small. In this
  database Dimension.City has more rows than three of the six fact
  tables, and Fact.[Stock Holding] has fewer rows than most dimensions.

  Row count tells you what to look at more closely. It does not tell
  you what is a fact.
───────────────────────────────────────────────────────────────────────*/
SELECT  s.name                AS SchemaName,
        t.name                AS TableName,
        SUM(p.rows)           AS [Rows]
FROM    sys.tables t
JOIN    sys.schemas s     ON s.schema_id = t.schema_id
JOIN    sys.partitions p  ON p.object_id = t.object_id
                          AND p.index_id IN (0, 1)
WHERE   s.name IN ('Fact', 'Dimension')
GROUP BY s.name, t.name
ORDER BY s.name, SUM(p.rows) DESC;


/*───────────────────────────────────────────────────────────────────────
  2 · WHAT ARE THE KEY COLUMNS, AND WHAT TYPE

  Types decide what you join to what. A date key that is a real `date`
  joins to the date dimension's date column. A `YYYYMMDD` integer joins
  to an integer column. Both work; you just need to know which you have
  before you start dragging lines between tables.

  Watch for one side being `date` and the other `datetime` — the
  relationship will either refuse or match nothing.
───────────────────────────────────────────────────────────────────────*/
SELECT  s.name              AS SchemaName,
        t.name              AS TableName,
        c.name              AS ColumnName,
        ty.name             AS DataType,
        c.is_nullable       AS Nullable
FROM    sys.columns c
JOIN    sys.tables t    ON t.object_id = c.object_id
JOIN    sys.schemas s   ON s.schema_id = t.schema_id
JOIN    sys.types ty    ON ty.user_type_id = c.user_type_id
WHERE   s.name IN ('Fact', 'Dimension')
  AND   c.name LIKE '%Key%'
ORDER BY s.name, t.name, c.column_id;


/*───────────────────────────────────────────────────────────────────────
  3 · WHAT IS THE PRIMARY KEY OF EACH DIMENSION

  This is the "one" side of every relationship you are about to build.

  It is almost always a surrogate key rather than the business key, and
  that matters: the surrogate is unique even when the dimension keeps
  several versions of the same real-world thing.
───────────────────────────────────────────────────────────────────────*/
SELECT  s.name + '.' + t.name   AS TableName,
        c.name                  AS PrimaryKeyColumn
FROM    sys.indexes i
JOIN    sys.index_columns ic ON ic.object_id = i.object_id
                            AND ic.index_id  = i.index_id
JOIN    sys.columns c        ON c.object_id  = ic.object_id
                            AND c.column_id  = ic.column_id
JOIN    sys.tables t         ON t.object_id  = i.object_id
JOIN    sys.schemas s        ON s.schema_id  = t.schema_id
WHERE   i.is_primary_key = 1
  AND   s.name IN ('Fact', 'Dimension')
ORDER BY s.name, t.name;


/*───────────────────────────────────────────────────────────────────────
  4 · WHICH DIMENSIONS ARE SHARED BETWEEN FACTS

  The most useful result in this file.

  A key appearing in several fact tables is a conformed dimension: one
  table in the model, filtering all of those facts at once. That is what
  lets two facts sit on the same visual under the same slicer.

  A key appearing in one fact only filters that fact and nothing else.

  Read the FactCount column first, then build the model from it.
───────────────────────────────────────────────────────────────────────*/
SELECT  c.name                                      AS KeyColumn,
        COUNT(*)                                    AS FactCount,
        STRING_AGG(t.name, ', ')
            WITHIN GROUP (ORDER BY t.name)          AS AppearsIn
FROM    sys.columns c
JOIN    sys.tables t   ON t.object_id = c.object_id
JOIN    sys.schemas s  ON s.schema_id = t.schema_id
WHERE   s.name = 'Fact'
  AND   c.name LIKE '%Key%'
GROUP BY c.name
ORDER BY COUNT(*) DESC, c.name;


/*───────────────────────────────────────────────────────────────────────
  5 · WHAT RELATIONSHIPS DOES THE DATABASE ALREADY DECLARE

  If this returns rows, it is the blueprint for your model — and Power
  BI will use it. "Import relationships from data sources on first
  load" is on by default, and it mirrors primary and foreign keys into
  the model when the tables first load.

  Read it before you import anyway, for one reason: where two foreign
  keys run between the same pair of tables, Power BI can only make one
  of them active. It picks. You may not agree with the choice.

  Scan the result for a FromTable and ToTable pair that appears more
  than once. Every one of those is a role-playing dimension and a
  decision waiting for you.

  If this returns nothing, that is also normal — plenty of warehouses
  declare no foreign keys because the ETL guarantees integrity. Then
  the relationships are yours to build, and auto-detect is guessing
  from column names rather than reading anything.
───────────────────────────────────────────────────────────────────────*/
SELECT  fk.name                         AS ForeignKeyName,
        ps.name + '.' + pt.name         AS FromTable,
        pc.name                         AS FromColumn,
        rs.name + '.' + rt.name         AS ToTable,
        rc.name                         AS ToColumn
FROM    sys.foreign_keys fk
JOIN    sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
JOIN    sys.tables  pt  ON pt.object_id = fkc.parent_object_id
JOIN    sys.schemas ps  ON ps.schema_id = pt.schema_id
JOIN    sys.columns pc  ON pc.object_id = fkc.parent_object_id
                        AND pc.column_id = fkc.parent_column_id
JOIN    sys.tables  rt  ON rt.object_id = fkc.referenced_object_id
JOIN    sys.schemas rs  ON rs.schema_id = rt.schema_id
JOIN    sys.columns rc  ON rc.object_id = fkc.referenced_object_id
                        AND rc.column_id = fkc.referenced_column_id
ORDER BY FromTable, ForeignKeyName;


/*───────────────────────────────────────────────────────────────────────
  6 · WHICH FACTS HAVE DATES, AND HOW MANY

  Two things come out of this.

  A fact with several date columns is a role-playing problem. Power BI
  allows one active relationship between two tables, so the second date
  relationship arrives inactive and is silently ignored until you do
  something about it.

  A fact with no date column at all cannot be filtered by the date
  dimension. That is usually a snapshot — what is true now, rather than
  what happened when — and it will repeat its total across every date on
  a visual.
───────────────────────────────────────────────────────────────────────*/
SELECT  t.name              AS FactTable,
        c.name              AS DateColumn,
        ty.name             AS DataType
FROM    sys.columns c
JOIN    sys.tables t    ON t.object_id = c.object_id
JOIN    sys.schemas s   ON s.schema_id = t.schema_id
JOIN    sys.types ty    ON ty.user_type_id = c.user_type_id
WHERE   s.name = 'Fact'
  AND ( c.name LIKE '%Date%'
        OR ty.name IN ('date', 'datetime', 'datetime2', 'smalldatetime') )
ORDER BY t.name, c.column_id;


/*═══════════════════════════════════════════════════════════════════════
  The rest need table and column names from your own database.
  Substitute them where marked.
═══════════════════════════════════════════════════════════════════════*/


/*───────────────────────────────────────────────────────────────────────
  7 · DOES A DIMENSION KEEP HISTORY                        [EDIT NAMES]

  A dimension that tracks history holds several rows for the same
  real-world thing, each valid for a period. It is why a dimension can
  end up larger than a fact table.

  It does not break the model — the surrogate key is still unique, so
  the relationship is still one-to-many. But two things follow:

    · counting rows in that dimension counts versions, not things
    · never filter it down to current rows only, or every fact row
      pointing at an older version loses its dimension

  First find the dimensions that track history:
───────────────────────────────────────────────────────────────────────*/
SELECT  s.name + '.' + t.name   AS DimensionTable,
        COUNT(*)                AS ValidityColumns
FROM    sys.columns c
JOIN    sys.tables t    ON t.object_id = c.object_id
JOIN    sys.schemas s   ON s.schema_id = t.schema_id
WHERE   s.name = 'Dimension'
  AND   c.name IN ('Valid From', 'Valid To')
GROUP BY s.name, t.name
ORDER BY t.name;

-- Then count versions per real-world thing.
-- Substitute the table and its business key column.
SELECT  COUNT(*)                            AS [Rows],
        COUNT(DISTINCT [WWI City ID])       AS DistinctThings
FROM    Dimension.City;

-- And look at what actually changes between versions.
SELECT  [City Key], [WWI City ID], City, [State Province],
        [Latest Recorded Population], [Valid From], [Valid To]
FROM    Dimension.City
WHERE   [WWI City ID] = 15665
ORDER BY [Valid From];


/*───────────────────────────────────────────────────────────────────────
  8 · DO THE FACT DATES FIT INSIDE THE DATE DIMENSION      [EDIT NAMES]

  A date dimension covers a fixed window. Any fact date outside it has
  nothing to join to, and those rows land on the blank row of the
  relationship — where they are easy to miss and hard to explain.

  Check before you build, not after a total looks wrong.
───────────────────────────────────────────────────────────────────────*/
SELECT  MIN([Order Date Key])   AS EarliestFactDate,
        MAX([Picked Date Key])  AS LatestFactDate
FROM    Fact.[Order];

SELECT  MIN([Date])             AS DimensionStart,
        MAX([Date])             AS DimensionEnd,
        COUNT(*)                AS DaysCovered
FROM    Dimension.Date;


/*───────────────────────────────────────────────────────────────────────
  9 · ARE THERE UNKNOWN MEMBERS, AND HOW MUCH DO THEY HOLD

  Warehouses often reserve a key — 0, or -1 — for "we do not know".

  If the dimension has a matching row, those facts get a readable
  "Unknown" label and your totals reconcile. If it does not, they land
  on the blank row of the relationship, where a user will eventually
  ask what the empty category on their chart means.

  A warehouse that does this consistently, one Unknown row in every
  dimension, has been designed rather than grown. Worth knowing which
  kind you are working with.

  This first query writes the checks rather than running them. Copy the
  results into a new window, delete the final UNION ALL, and run.
───────────────────────────────────────────────────────────────────────*/
SELECT  'SELECT ''' + t.name + ''' AS DimensionTable, COUNT(*) AS UnknownRows FROM '
        + QUOTENAME(s.name) + '.' + QUOTENAME(t.name)
        + ' WHERE ' + QUOTENAME(c.name) + ' <= 0 UNION ALL'  AS StatementToRun
FROM    sys.indexes i
JOIN    sys.index_columns ic ON ic.object_id = i.object_id
                            AND ic.index_id  = i.index_id
JOIN    sys.columns c        ON c.object_id  = ic.object_id
                            AND c.column_id  = ic.column_id
JOIN    sys.tables t         ON t.object_id  = i.object_id
JOIN    sys.schemas s        ON s.schema_id  = t.schema_id
JOIN    sys.types ty         ON ty.user_type_id = c.user_type_id
WHERE   i.is_primary_key = 1
  AND   s.name = 'Dimension'
  AND   ty.name IN ('int', 'bigint', 'smallint', 'tinyint')
ORDER BY t.name;


/* How much of a fact table points at Unknown.              [EDIT NAMES]

   A handful of rows is noise. A third of the table is a category that
   will dominate every breakdown by that dimension, and you want the
   number before a stakeholder does.                                   */
SELECT  COUNT(*)                                                    AS TotalRows,
        SUM(CASE WHEN [Customer Key] = 0 THEN 1 ELSE 0 END)         AS UnknownRows,
        CAST(100.0 * SUM(CASE WHEN [Customer Key] = 0 THEN 1 ELSE 0 END)
             / COUNT(*) AS decimal(5,1))                            AS PercentUnknown
FROM    Fact.[Order];


/* Where the unknowns concentrate.                          [EDIT NAMES]

   Group by a categorical column on the fact. If whole categories are
   100% unknown, the dimension does not apply to them — a stock receipt
   has no customer, and that is correct data rather than missing data.

   If instead the unknowns are spread evenly, you are looking at a gap
   in the source, which is a different conversation.                   */
SELECT  dt.[Transaction Type],
        COUNT(*)                                                AS [Rows],
        SUM(CASE WHEN f.[Customer Key] = 0 THEN 1 ELSE 0 END)   AS Unknown
FROM    Fact.Movement f
JOIN    Dimension.[Transaction Type] dt
          ON dt.[Transaction Type Key] = f.[Transaction Type Key]
GROUP BY dt.[Transaction Type]
ORDER BY COUNT(*) DESC;


/*───────────────────────────────────────────────────────────────────────
 10 · DO TWO FACTS DESCRIBE THE SAME EVENTS                [EDIT NAMES]

  Look back at section 1. Two fact tables with suspiciously similar row
  counts are worth half a minute, because warehouses often record the
  same events twice from different angles — a sale from the money side
  and from the stock side.

  In this database, filtering Fact.Movement to stock issues gives
  exactly the row count of Fact.Sale. They are the same transactions.

  Nothing needs fixing. But anyone who puts a measure from each on one
  visual is counting the same events twice, and a semantic model should
  make that obvious rather than leave it to be discovered in a meeting.
───────────────────────────────────────────────────────────────────────*/
SELECT  'Fact.Sale' AS FactTable, COUNT(*) AS [Rows]
FROM    Fact.Sale
UNION ALL
SELECT  'Fact.Movement, stock issues only', COUNT(*)
FROM    Fact.Movement f
JOIN    Dimension.[Transaction Type] dt
          ON dt.[Transaction Type Key] = f.[Transaction Type Key]
WHERE   dt.[Transaction Type] = 'Stock Issue';
