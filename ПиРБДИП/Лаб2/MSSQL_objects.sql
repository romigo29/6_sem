
CREATE PROCEDURE sp_ProductCostByPeriod
    @Product_ID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT 
        p.Name AS ProductName,
        YEAR(l.Purchase_Date) AS Year,
        MONTH(l.Purchase_Date) AS Month,
        DATEPART(QUARTER, l.Purchase_Date) AS Quarter,
        SUM(l.Total_Seats) AS TotalLicenses,
        SUM(l.Total_Seats * l.Unit_Price) AS TotalCost
    FROM Licenses l
    JOIN Products p ON l.Product_ID = p.Product_ID
    WHERE l.Product_ID = @Product_ID
      AND l.Purchase_Date BETWEEN @StartDate AND @EndDate
    GROUP BY p.Name, YEAR(l.Purchase_Date), 
             MONTH(l.Purchase_Date), 
             DATEPART(QUARTER, l.Purchase_Date)
    ORDER BY Year, Month;
END;

CREATE PROCEDURE sp_LicenseForecastNextYear
AS
BEGIN
    SELECT 
        loc.Room_Number,
        MONTH(DATEADD(MONTH, v.number, GETDATE())) AS ForecastMonth,
        
        COUNT(d.Device_ID) + loc.Planned_Growth_Seats - SUM(
            CASE 
                WHEN DATEADD(MONTH, d.Service_Life_Months, d.Purchase_Date) 
                     < DATEADD(MONTH, v.number, GETDATE())
                THEN 1 ELSE 0
            END
        ) AS ForecastedLicenses

    FROM Locations loc
    LEFT JOIN Devices d ON loc.Location_ID = d.Location_ID
    CROSS JOIN master..spt_values v
    WHERE v.type = 'P'
      AND v.number BETWEEN 1 AND 12

    GROUP BY loc.Room_Number, v.number, loc.Planned_Growth_Seats
    ORDER BY loc.Room_Number, ForecastMonth;
END;

CREATE PROCEDURE sp_VendorExpensesLast6Months
AS
BEGIN
    SELECT 
        v.Name AS VendorName,
        YEAR(l.Purchase_Date) AS Year,
        MONTH(l.Purchase_Date) AS Month,
        SUM(l.Total_Seats * l.Unit_Price) AS TotalSpent
    FROM Licenses l
    JOIN Products p ON l.Product_ID = p.Product_ID
    JOIN Vendors v ON p.Vendor_ID = v.Vendor_ID
    WHERE l.Purchase_Date >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY v.Name, YEAR(l.Purchase_Date), MONTH(l.Purchase_Date)
    ORDER BY v.Name, Year, Month;
END;

CREATE PROCEDURE sp_DeviceTypeLicenseLoad
AS
BEGIN
    SELECT 
        d.Device_Type,
        COUNT(i.Install_ID) AS TotalInstallations,
        SUM(i.Usage_Count) AS TotalUsage
    FROM Installations i
    JOIN Devices d ON i.Device_ID = d.Device_ID
    GROUP BY d.Device_Type
    ORDER BY TotalUsage DESC;
END;

CREATE PROCEDURE sp_LocationLicenseDistribution
AS
BEGIN
    SELECT 
        loc.Room_Number,
        COUNT(i.Install_ID) AS TotalInstalledLicenses
    FROM Installations i
    JOIN Devices d ON i.Device_ID = d.Device_ID
    JOIN Locations loc ON d.Location_ID = loc.Location_ID
    GROUP BY loc.Room_Number
    ORDER BY TotalInstalledLicenses DESC;
END;


CREATE FUNCTION fn_ProductShareAnalysis
(
    @Product_ID INT,
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
SELECT
    SUM(l.Total_Seats) AS ProductLicenses,
    SUM(l.Total_Seats * l.Unit_Price) AS ProductCost,

    SUM(l.Total_Seats) * 100.0 /
        (SELECT SUM(Total_Seats) 
         FROM Licenses 
         WHERE Purchase_Date BETWEEN @StartDate AND @EndDate)
        AS LicenseSharePercent,

    SUM(l.Total_Seats * l.Unit_Price) * 100.0 /
        (SELECT SUM(Total_Seats * Unit_Price)
         FROM Licenses
         WHERE Purchase_Date BETWEEN @StartDate AND @EndDate)
        AS CostSharePercent

FROM Licenses l
WHERE l.Product_ID = @Product_ID
  AND l.Purchase_Date BETWEEN @StartDate AND @EndDate;

CREATE FUNCTION fn_TopSoftwareByDeviceType()
RETURNS TABLE
AS
RETURN
WITH UsageStats AS (
    SELECT 
        d.Device_Type,
        p.Name AS ProductName,
        SUM(i.Usage_Count) AS TotalUsage,
        ROW_NUMBER() OVER(
            PARTITION BY d.Device_Type
            ORDER BY SUM(i.Usage_Count) DESC
        ) AS rn
    FROM Installations i
    JOIN Devices d ON i.Device_ID = d.Device_ID
    JOIN Licenses l ON i.License_ID = l.License_ID
    JOIN Products p ON l.Product_ID = p.Product_ID
    GROUP BY d.Device_Type, p.Name
)
SELECT Device_Type, ProductName, TotalUsage
FROM UsageStats
WHERE rn = 1;

CREATE FUNCTION fn_VendorTotalShare()
RETURNS TABLE
AS
RETURN
SELECT 
    v.Name AS VendorName,
    SUM(l.Total_Seats * l.Unit_Price) AS TotalCost,
    SUM(l.Total_Seats * l.Unit_Price) * 100.0 /
        SUM(SUM(l.Total_Seats * l.Unit_Price)) OVER() AS SharePercent
FROM Licenses l
JOIN Products p ON l.Product_ID = p.Product_ID
JOIN Vendors v ON p.Vendor_ID = v.Vendor_ID
GROUP BY v.Name;

CREATE FUNCTION fn_DeviceAgingImpact()
RETURNS TABLE
AS
RETURN
SELECT 
    YEAR(DATEADD(MONTH, Service_Life_Months, Purchase_Date)) AS ExpireYear,
    MONTH(DATEADD(MONTH, Service_Life_Months, Purchase_Date)) AS ExpireMonth,
    COUNT(*) AS DevicesToExpire
FROM Devices
GROUP BY YEAR(DATEADD(MONTH, Service_Life_Months, Purchase_Date)),
         MONTH(DATEADD(MONTH, Service_Life_Months, Purchase_Date));

CREATE FUNCTION fn_ProductCategoryUsage()
RETURNS TABLE
AS
RETURN
SELECT 
    p.Category,
    SUM(i.Usage_Count) AS TotalUsage
FROM Installations i
JOIN Licenses l ON i.License_ID = l.License_ID
JOIN Products p ON l.Product_ID = p.Product_ID
GROUP BY p.Category;

CREATE TRIGGER tr_UpdateLastActivity
ON Installations
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE i
    SET Last_Activity_Date = GETDATE()
    FROM Installations i
    JOIN inserted ins ON i.Install_ID = ins.Install_ID;
END;

--Продажи товаров за период
EXEC sp_ProductCostByPeriod @Product_ID = 1, @StartDate = '2020-01-01', @EndDate = '2026-12-31';

--Прогноз лицензий на следующий год
EXEC sp_LicenseForecastNextYear;

-- Расходы по вендорам за последние 6 месяцев
EXEC sp_VendorExpensesLast6Months;

-- Использование лицензий по типам устройств
EXEC sp_DeviceTypeLicenseLoad;

-- Распределение лицензий по помещениям
EXEC sp_LocationLicenseDistribution;


-- Доля продукта по количеству и стоимости лицензий
SELECT * FROM fn_ProductShareAnalysis(1, '2020-01-01', '2026-12-31');

-- Наиболее используемое ПО по типу устройств
SELECT * FROM fn_TopSoftwareByDeviceType();

-- Доля вендоров по стоимости лицензий
SELECT * FROM fn_VendorTotalShare();

--Устаревание оборудования по месяцам
SELECT * FROM fn_DeviceAgingImpact();

-- Использование ПО по категориям
SELECT * FROM fn_ProductCategoryUsage();


SELECT * FROM Installations;

INSERT INTO Installations (Device_ID, License_ID, Usage_Count) VALUES (1, 2, 1);

SELECT * FROM Installations ORDER BY Install_ID DESC;