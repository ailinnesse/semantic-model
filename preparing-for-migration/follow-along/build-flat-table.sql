SELECT
        RecordType          = CAST('Sale' AS varchar(10)),
        SourceKey           = s.[Sale Key],
        DocumentID          = s.[WWI Invoice ID],
        DateKey             = s.[Invoice Date Key],
        SecondaryDateKey    = s.[Delivery Date Key],
        StockItemKey        = s.[Stock Item Key],
        CustomerKey         = s.[Customer Key],
        SupplierKey         = CAST(NULL AS int),
        SalespersonKey      = s.[Salesperson Key],
        CityKey             = s.[City Key],
        Description         = s.[Description],
        Package             = s.[Package],
        Quantity            = s.[Quantity],
        UnitPrice           = s.[Unit Price],
        TaxRate             = s.[Tax Rate],
        TotalExcludingTax   = s.[Total Excluding Tax],
        TaxAmount           = s.[Tax Amount],
        TotalIncludingTax   = s.[Total Including Tax],
        Profit              = s.[Profit]
INTO    dbo.AllTransactions
FROM    Fact.Sale AS s
 
UNION ALL
 
SELECT
        RecordType          = CAST('Order' AS varchar(10)),
        SourceKey           = o.[Order Key],
        DocumentID          = o.[WWI Order ID],
        DateKey             = o.[Order Date Key],
        SecondaryDateKey    = o.[Picked Date Key],
        StockItemKey        = o.[Stock Item Key],
        CustomerKey         = o.[Customer Key],
        SupplierKey         = CAST(NULL AS int),
        SalespersonKey      = o.[Salesperson Key],
        CityKey             = o.[City Key],
        Description         = o.[Description],
        Package             = o.[Package],
        Quantity            = o.[Quantity],
        UnitPrice           = o.[Unit Price],
        TaxRate             = o.[Tax Rate],
        TotalExcludingTax   = o.[Total Excluding Tax],
        TaxAmount           = o.[Tax Amount],
        TotalIncludingTax   = o.[Total Including Tax],
        Profit              = CAST(NULL AS decimal(18,2))   -- orders have no profit
FROM    Fact.[Order] AS o
 
UNION ALL
 
SELECT
        RecordType          = CAST('Purchase' AS varchar(10)),
        SourceKey           = p.[Purchase Key],
        DocumentID          = p.[WWI Purchase Order ID],
        DateKey             = p.[Date Key],
        SecondaryDateKey    = CAST(NULL AS date),
        StockItemKey        = p.[Stock Item Key],
        CustomerKey         = CAST(NULL AS int),           -- purchases have a supplier
        SupplierKey         = p.[Supplier Key],
        SalespersonKey      = CAST(NULL AS int),
        CityKey             = CAST(NULL AS int),
        Description         = CAST(NULL AS nvarchar(100)),
        Package             = p.[Package],
        Quantity            = p.[Ordered Quantity],
        UnitPrice           = CAST(NULL AS decimal(18,2)), -- no prices on purchases
        TaxRate             = CAST(NULL AS decimal(18,3)),
        TotalExcludingTax   = CAST(NULL AS decimal(18,2)),
        TaxAmount           = CAST(NULL AS decimal(18,2)),
        TotalIncludingTax   = CAST(NULL AS decimal(18,2)),
        Profit              = CAST(NULL AS decimal(18,2))
FROM    Fact.Purchase AS p;
GO