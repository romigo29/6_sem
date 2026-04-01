show con_name;

-- 2. Процедуры


-- 2.1 Итоги стоимости по периоду
CREATE OR REPLACE PROCEDURE sp_ProductCostByPeriod(
    p_Product_ID IN NUMBER,
    p_StartDate IN DATE,
    p_EndDate IN DATE
)
AS
BEGIN
    FOR rec IN (
        SELECT p.Name AS ProductName,
               EXTRACT(YEAR FROM l.Purchase_Date) AS Year,
               EXTRACT(MONTH FROM l.Purchase_Date) AS Month,
               SUM(l.Total_Seats) AS TotalLicenses,
               SUM(l.Total_Seats * l.Unit_Price) AS TotalCost
        FROM Licenses l
        JOIN Products p ON l.Product_ID = p.Product_ID
        WHERE l.Product_ID = p_Product_ID
          AND l.Purchase_Date BETWEEN p_StartDate AND p_EndDate
        GROUP BY p.Name, EXTRACT(YEAR FROM l.Purchase_Date), EXTRACT(MONTH FROM l.Purchase_Date)
        ORDER BY Year, Month
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.ProductName || ' | ' || rec.Year || '-' || rec.Month ||
                             ' | Licenses: ' || rec.TotalLicenses || ' | Cost: ' || rec.TotalCost);
    END LOOP;
END;
/

-- 2.2 Прогноз лицензий на следующий год
CREATE OR REPLACE PROCEDURE sp_LicenseForecastNextYear
AS
BEGIN
    FOR rec IN (
        SELECT 
            loc.Room_Number,
            m.month_num AS ForecastMonth,
            COUNT(d.Device_ID)
            + loc.Planned_Growth_Seats
            - SUM(
                CASE 
                    WHEN ADD_MONTHS(d.Purchase_Date, d.Service_Life_Months) 
                         < ADD_MONTHS(SYSDATE, m.month_num)
                    THEN 1 
                    ELSE 0 
                END
            ) AS ForecastedLicenses
        FROM Locations loc
        CROSS JOIN (
            SELECT 1 AS month_num FROM dual UNION ALL
            SELECT 2 FROM dual UNION ALL
            SELECT 3 FROM dual UNION ALL
            SELECT 4 FROM dual UNION ALL
            SELECT 5 FROM dual UNION ALL
            SELECT 6 FROM dual UNION ALL
            SELECT 7 FROM dual UNION ALL
            SELECT 8 FROM dual UNION ALL
            SELECT 9 FROM dual UNION ALL
            SELECT 10 FROM dual UNION ALL
            SELECT 11 FROM dual UNION ALL
            SELECT 12 FROM dual
        ) m
        LEFT JOIN Devices d 
            ON loc.Location_ID = d.Location_ID
        GROUP BY 
            loc.Room_Number, 
            loc.Planned_Growth_Seats, 
            m.month_num
        ORDER BY 
            loc.Room_Number, 
            m.month_num
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.Room_Number || 
            ' | Month: ' || rec.ForecastMonth || 
            ' | Forecast: ' || rec.ForecastedLicenses
        );
    END LOOP;
END;
/

-- 2.3 Расходы по вендорам за последние 6 месяцев
CREATE OR REPLACE PROCEDURE sp_VendorExpensesLast6Months
AS
BEGIN
    FOR rec IN (
        SELECT v.Name AS VendorName,
               EXTRACT(YEAR FROM l.Purchase_Date) AS Year,
               EXTRACT(MONTH FROM l.Purchase_Date) AS Month,
               SUM(l.Total_Seats * l.Unit_Price) AS TotalSpent
        FROM Licenses l
        JOIN Products p ON l.Product_ID = p.Product_ID
        JOIN Vendors v ON p.Vendor_ID = v.Vendor_ID
        WHERE l.Purchase_Date >= ADD_MONTHS(SYSDATE, -6)
        GROUP BY v.Name, EXTRACT(YEAR FROM l.Purchase_Date), EXTRACT(MONTH FROM l.Purchase_Date)
        ORDER BY v.Name, Year, Month
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.VendorName || ' | ' || rec.Year || '-' || rec.Month || ' | ' || rec.TotalSpent);
    END LOOP;
END;
/

-- 2.4 Использование лицензий по типам устройств
CREATE OR REPLACE PROCEDURE sp_DeviceTypeLicenseLoad
AS
BEGIN
    FOR rec IN (
        SELECT d.Device_Type,
               COUNT(i.Install_ID) AS TotalInstallations,
               SUM(i.Usage_Count) AS TotalUsage
        FROM Installations i
        JOIN Devices d ON i.Device_ID = d.Device_ID
        GROUP BY d.Device_Type
        ORDER BY TotalUsage DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.Device_Type || ' | Installations: ' || rec.TotalInstallations || ' | Usage: ' || rec.TotalUsage);
    END LOOP;
END;
/

-- 2.5 Распределение лицензий по помещениям
CREATE OR REPLACE PROCEDURE sp_LocationLicenseDistribution
AS
BEGIN
    FOR rec IN (
        SELECT loc.Room_Number,
               COUNT(i.Install_ID) AS TotalInstalledLicenses
        FROM Installations i
        JOIN Devices d ON i.Device_ID = d.Device_ID
        JOIN Locations loc ON d.Location_ID = loc.Location_ID
        GROUP BY loc.Room_Number
        ORDER BY TotalInstalledLicenses DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.Room_Number || ' | Total Installed: ' || rec.TotalInstalledLicenses);
    END LOOP;
END;
/

-- 3. Функции

-- 3.1 Доля продукта по количеству и стоимости лицензий
CREATE OR REPLACE FUNCTION fn_ProductShareAnalysis(
    p_Product_ID NUMBER,
    p_StartDate DATE,
    p_EndDate DATE
) RETURN SYS_REFCURSOR
AS
    rc SYS_REFCURSOR;
    v_TotalSeats NUMBER;
    v_TotalCost NUMBER;
    v_OverallSeats NUMBER;
    v_OverallCost NUMBER;
BEGIN

    SELECT SUM(Total_Seats), SUM(Total_Seats * Unit_Price)
    INTO v_TotalSeats, v_TotalCost
    FROM Licenses
    WHERE Product_ID = p_Product_ID
      AND Purchase_Date BETWEEN p_StartDate AND p_EndDate;

    SELECT SUM(Total_Seats), SUM(Total_Seats * Unit_Price)
    INTO v_OverallSeats, v_OverallCost
    FROM Licenses
    WHERE Purchase_Date BETWEEN p_StartDate AND p_EndDate;

    OPEN rc FOR
    SELECT v_TotalSeats AS ProductLicenses,
           v_TotalCost AS ProductCost,
           ROUND(v_TotalSeats * 100 / v_OverallSeats, 2) AS LicenseSharePercent,
           ROUND(v_TotalCost * 100 / v_OverallCost, 2) AS CostSharePercent
    FROM dual;

    RETURN rc;
END;
/

-- 3.2 Наиболее используемое ПО по типу устройств
CREATE OR REPLACE FUNCTION fn_TopSoftwareByDeviceType RETURN SYS_REFCURSOR
AS
    rc SYS_REFCURSOR;
BEGIN
    OPEN rc FOR
        SELECT Device_Type, ProductName, TotalUsage
        FROM (
            SELECT d.Device_Type,
                   p.Name AS ProductName,
                   SUM(i.Usage_Count) AS TotalUsage,
                   ROW_NUMBER() OVER(PARTITION BY d.Device_Type ORDER BY SUM(i.Usage_Count) DESC) AS rn
            FROM Installations i
            JOIN Devices d ON i.Device_ID = d.Device_ID
            JOIN Licenses l ON i.License_ID = l.License_ID
            JOIN Products p ON l.Product_ID = p.Product_ID
            GROUP BY d.Device_Type, p.Name
        ) WHERE rn = 1;
    RETURN rc;
END;
/

-- 3.3 Доля вендоров по стоимости лицензий
CREATE OR REPLACE FUNCTION fn_VendorTotalShare RETURN SYS_REFCURSOR
AS
    rc SYS_REFCURSOR;
BEGIN
    OPEN rc FOR
        SELECT v.Name AS VendorName,
               SUM(l.Total_Seats * l.Unit_Price) AS TotalCost,
               SUM(l.Total_Seats * l.Unit_Price) * 100 / SUM(SUM(l.Total_Seats * l.Unit_Price)) OVER () AS SharePercent
        FROM Licenses l
        JOIN Products p ON l.Product_ID = p.Product_ID
        JOIN Vendors v ON p.Vendor_ID = v.Vendor_ID
        GROUP BY v.Name;
    RETURN rc;
END;
/

-- 3.4 Устаревание оборудования по месяцам
CREATE OR REPLACE FUNCTION fn_DeviceAgingImpact RETURN SYS_REFCURSOR
AS
    rc SYS_REFCURSOR;
BEGIN
    OPEN rc FOR
        SELECT EXTRACT(YEAR FROM ADD_MONTHS(Purchase_Date, Service_Life_Months)) AS ExpireYear,
               EXTRACT(MONTH FROM ADD_MONTHS(Purchase_Date, Service_Life_Months)) AS ExpireMonth,
               COUNT(*) AS DevicesToExpire
        FROM Devices
        GROUP BY EXTRACT(YEAR FROM ADD_MONTHS(Purchase_Date, Service_Life_Months)),
                 EXTRACT(MONTH FROM ADD_MONTHS(Purchase_Date, Service_Life_Months));
    RETURN rc;
END;
/

-- 3.5 Использование ПО по категориям
CREATE OR REPLACE FUNCTION fn_ProductCategoryUsage RETURN SYS_REFCURSOR
AS
    rc SYS_REFCURSOR;
BEGIN
    OPEN rc FOR
        SELECT p.Category,
               SUM(i.Usage_Count) AS TotalUsage
        FROM Installations i
        JOIN Licenses l ON i.License_ID = l.License_ID
        JOIN Products p ON l.Product_ID = p.Product_ID
        GROUP BY p.Category;
    RETURN rc;
END;
/

-- 4. Триггер: обновление даты последней активности
CREATE OR REPLACE TRIGGER tr_UpdateLastActivity
BEFORE INSERT OR UPDATE ON Installations
FOR EACH ROW
BEGIN
    :NEW.Last_Activity_Date := SYSDATE;
END;
/


-- Демонстрация
SET SERVEROUTPUT ON;

-- Вызов процедуры
BEGIN
    sp_ProductCostByPeriod(1, DATE '2020-01-01', DATE '2026-12-31');
END;
/

BEGIN
    sp_LicenseForecastNextYear;
END;
/

BEGIN
    sp_VendorExpensesLast6Months;
END;
/

BEGIN
    sp_DeviceTypeLicenseLoad;
END;
/

BEGIN
    sp_LocationLicenseDistribution;
END;
/

DECLARE
    rc SYS_REFCURSOR;
BEGIN
    rc := fn_ProductShareAnalysis(1, DATE '2025-01-01', DATE '2026-12-31');
    DBMS_SQL.RETURN_RESULT(rc);
END;
/


DECLARE
    rc SYS_REFCURSOR;
BEGIN
    rc := fn_TopSoftwareByDeviceType();
    DBMS_SQL.RETURN_RESULT(rc);
END;
/


DECLARE
    rc SYS_REFCURSOR;
BEGIN
    rc := fn_VendorTotalShare();
    DBMS_SQL.RETURN_RESULT(rc);
END;
/


DECLARE
    rc SYS_REFCURSOR;
BEGIN
    rc := fn_DeviceAgingImpact();
    DBMS_SQL.RETURN_RESULT(rc);
END;
/

DECLARE
    rc SYS_REFCURSOR;
BEGIN
    rc := fn_ProductCategoryUsage();
    DBMS_SQL.RETURN_RESULT(rc);
END;
/

CREATE SEQUENCE Installations_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
ALTER SEQUENCE Installations_SEQ INCREMENT BY 5; 

-- Проверка работы триггера
INSERT INTO Installations (Install_ID, Device_ID, License_ID, Usage_Count) VALUES (Installations_SEQ.NEXTVAL, 1, 2, 1);
SELECT * FROM Installations;