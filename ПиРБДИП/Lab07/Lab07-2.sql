SELECT *
FROM (
    SELECT 
        p.Product_ID,
        p.Name        AS Product_Name,
        l.Purchase_Date,
        l.Unit_Price
    FROM Licenses l
    JOIN Products p ON p.Product_ID = l.Product_ID
) t
MATCH_RECOGNIZE (
    PARTITION BY Product_ID
    ORDER BY Purchase_Date
    MEASURES
        FIRST(UP1.Purchase_Date)  AS start_date,
        LAST(UP2.Purchase_Date)   AS end_date,
        FIRST(UP1.Unit_Price)     AS start_price,
        MIN(DOWN.Unit_Price)      AS bottom_price,
        LAST(UP2.Unit_Price)      AS end_price
    ONE ROW PER MATCH
    PATTERN (UP1+ DOWN+ UP2+)
    DEFINE
        UP1  AS Unit_Price > PREV(Unit_Price),
        DOWN AS Unit_Price < PREV(Unit_Price),
        UP2  AS Unit_Price > PREV(Unit_Price)
);

  SELECT 
        p.Product_ID,
        p.Name        AS Product_Name,
        l.Purchase_Date,
        l.Unit_Price
    FROM Licenses l
    JOIN Products p ON p.Product_ID = l.Product_ID

