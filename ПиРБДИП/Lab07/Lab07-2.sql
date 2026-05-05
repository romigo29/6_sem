SELECT *
FROM (
    SELECT 
        p.Product_ID,
        p.Name AS Product_Name,
        l.Purchase_Date,
        l.Unit_Price
    FROM Licenses l
    JOIN Products p ON p.Product_ID = l.Product_ID
) t
MATCH_RECOGNIZE (
    PARTITION BY Product_ID
    ORDER BY Purchase_Date
    MEASURES
        FIRST(START_ROW.Purchase_Date) AS start_date,
        FIRST(START_ROW.Unit_Price) AS start_price,
        LAST(UP1.Purchase_Date) AS growth_date,
        LAST(UP1.Unit_Price) AS growth_price,
        LAST(DOWN.Purchase_Date) AS fall_date,
        LAST(DOWN.Unit_Price) AS fall_price,
        LAST(UP2.Purchase_Date) AS end_date,
        LAST(UP2.Unit_Price)AS end_price
    ONE ROW PER MATCH
    PATTERN (START_ROW UP1+ DOWN+ UP2+)
    DEFINE
        UP1 AS UP1.Unit_Price > PREV(Unit_Price),
        DOWN AS DOWN.Unit_Price < PREV(Unit_Price),
        UP2 AS UP2.Unit_Price  > PREV(Unit_Price)
);