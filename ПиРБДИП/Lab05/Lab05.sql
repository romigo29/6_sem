DELETE FROM Requests;
DELETE FROM Installations;
DELETE FROM Devices;
DELETE FROM Licenses;
DELETE FROM Products;
DELETE FROM Locations;
DELETE FROM Vendors;

DBCC CHECKIDENT ('Requests', RESEED, 0);
DBCC CHECKIDENT ('Installations', RESEED, 0);
DBCC CHECKIDENT ('Devices', RESEED, 0);
DBCC CHECKIDENT ('Licenses', RESEED, 0);
DBCC CHECKIDENT ('Products', RESEED, 0);
DBCC CHECKIDENT ('Locations', RESEED, 0);
DBCC CHECKIDENT ('Vendors', RESEED, 0);

-- 1. Vendors 
INSERT INTO Vendors (Name, Email) VALUES
('Microsoft',        'sales@microsoft.com'),
('Adobe',            'sales@adobe.com'),
('JetBrains',        'sales@jetbrains.com'),
('Kaspersky',        'sales@kaspersky.com'),
('1C',               'sales@1c.ru'),
('Autodesk',         'sales@autodesk.com'),
('Oracle',           'sales@oracle.com'),
('Positive Technologies', 'sales@ptsecurity.com');

-- 2. Locations
INSERT INTO Locations (Room_Number, Planned_Growth_Seats) VALUES
('101', 5),
('102', 3),
('201', 10),
('202', 0),
('203', 8),
('301', 4),
('302', 6),
('401', 0),
('402', 2),
('Серверная', 0);

-- 3. Products
INSERT INTO Products (Vendor_ID, Name, Category, Version) VALUES

(1, 'Windows 11 Pro',           'Офисное',        '23H2'),
(1, 'Microsoft Office 365',     'Офисное',        '2024'),
(1, 'Visual Studio Professional','Разработка',     '2022'),
(1, 'SQL Server Developer',     'СУБД',           '2022'),
(2, 'Adobe Photoshop',          'Графика',        '2024'),
(2, 'Adobe Illustrator',        'Графика',        '2024'),
(2, 'Adobe Premiere Pro',       'Графика',        '2024'),
(3, 'IntelliJ IDEA Ultimate',   'Разработка',     '2024.1'),
(3, 'PyCharm Professional',     'Разработка',     '2024.1'),
(3, 'DataGrip',                 'СУБД',           '2024.1'),
(4, 'Kaspersky Endpoint Security','Безопасность',  '12.0'),
(4, 'Kaspersky Total Security',  'Безопасность',  '2024'),
(5, '1С:Предприятие',           'Учёт',           '8.3'),
(5, '1С:Бухгалтерия',           'Учёт',           '3.0'),
(6, 'AutoCAD',                  'Проектирование', '2024'),
(6, '3ds Max',                  'Проектирование', '2024'),
(7, 'Oracle Database SE',       'СУБД',           '21c'),
(7, 'Oracle Java SE',           'Разработка',     '21'),
(8, 'MaxPatrol SIEM',           'Безопасность',   '7.0'),
(8, 'PT Application Firewall',  'Безопасность',   '4.0');

-- 4. Licenses 
INSERT INTO Licenses (Product_ID, Purchase_Date, Expiration_Date, Unit_Price, Total_Seats) VALUES

-- Product 1
(1, '2023-01-15', '2026-01-15', 12000, 20),
(1, '2023-05-10', '2026-05-10', 12500, 15),
(1, '2023-09-20', '2026-09-20', 13000, 10),
(1, '2024-02-05', '2027-02-05', 13500, 12),
(1, '2024-07-15', '2027-07-15', 14000, 18),
(1, '2025-03-01', '2028-03-01', 14500, 10),
(1, '2025-10-10', '2028-10-10', 15000, 8),

-- Product 2
(2, '2023-02-01', '2024-02-01', 5000, 25),
(2, '2023-06-15', '2024-06-15', 5200, 20),
(2, '2023-11-05', '2024-11-05', 5400, 30),
(2, '2024-03-10', '2025-03-10', 5600, 15),
(2, '2024-08-20', '2025-08-20', 5800, 25),
(2, '2025-01-25', '2026-01-25', 6000, 20),
(2, '2025-09-30', '2026-09-30', 6200, 35),

-- Product 3
(3, '2023-03-20', '2026-03-20', 45000, 8),
(3, '2023-07-10', '2026-07-10', 46000, 10),
(3, '2024-01-15', '2027-01-15', 47000, 6),
(3, '2024-06-15', '2027-06-15', 48000, 10),
(3, '2025-04-01', '2028-04-01', 50000, 7),

-- Product 4 (бесплатное ПО – важно для теста)
(4, '2023-04-10', NULL, 0, 40),
(4, '2023-10-01', NULL, 0, 60),
(4, '2024-05-05', NULL, 0, 50),
(4, '2025-01-01', NULL, 0, 55),

-- Product 5
(5, '2023-05-01', '2024-05-01', 18000, 10),
(5, '2023-12-01', '2024-12-01', 18500, 12),
(5, '2024-04-10', '2025-04-10', 19000, 15),
(5, '2024-09-15', '2025-09-15', 19500, 12),
(5, '2025-02-20', '2026-02-20', 20000, 8),
(5, '2025-11-05', '2026-11-05', 21000, 6),

-- Product 6
(6, '2023-06-01', '2024-06-01', 18000, 8),
(6, '2023-08-15', '2024-08-15', 18500, 10),
(6, '2024-02-10', '2025-02-10', 19000, 7),
(6, '2024-08-20', '2025-08-20', 19500, 10),
(6, '2025-03-15', '2026-03-15', 20000, 6),

-- Product 7
(7, '2023-01-10', '2024-01-10', 22000, 5),
(7, '2023-07-01', '2024-07-01', 22500, 7),
(7, '2024-01-10', '2025-01-10', 23000, 6),
(7, '2024-10-10', '2025-10-10', 23500, 5),
(7, '2025-06-01', '2026-06-01', 24000, 4),

-- Product 8
(8, '2023-02-01', '2024-02-01', 25000, 12),
(8, '2023-09-01', '2024-09-01', 25500, 15),
(8, '2024-03-01', '2025-03-01', 26000, 10),
(8, '2024-09-05', '2025-09-05', 27000, 15),
(8, '2025-05-01', '2026-05-01', 28000, 12),
(9,  '2023-10-01', '2024-10-01', 18000.00, 10),
(9,  '2024-10-10', '2025-10-10', 19500.00, 12),

-- DataGrip (Product_ID = 10)
(10, '2024-01-20', '2025-01-20', 15000.00, 8),

-- Kaspersky Endpoint (Product_ID = 11)
(11, '2023-03-01', '2024-03-01', 3500.00,  50),
(11, '2024-03-05', '2025-03-05', 3800.00,  50),
(11, '2025-03-10', '2026-03-10', 4000.00,  55),

-- Kaspersky Total (Product_ID = 12)
(12, '2023-11-15', '2024-11-15', 5000.00,  20),
(12, '2024-11-20', '2025-11-20', 5500.00,  25),

-- 1Ñ:Ïðåäïðèÿòèå (Product_ID = 13)
(13, '2023-08-01', NULL,         35000.00,  5),

-- 1Ñ:Áóõãàëòåðèÿ (Product_ID = 14)
(14, '2023-08-01', NULL,         28000.00,  3),

-- AutoCAD (Product_ID = 15)
(15, '2023-12-01', '2024-12-01', 85000.00, 10),
(15, '2024-12-10', '2025-12-10', 90000.00, 10),

-- 3ds Max (Product_ID = 16)
(16, '2024-04-15', '2025-04-15', 95000.00, 5),

-- Oracle Database SE (Product_ID = 17)
(17, '2023-06-01', '2025-06-01', 150000.00, 2),

-- Oracle Java SE (Product_ID = 18)
(18, '2024-07-01', '2025-07-01', 8000.00,  20),

-- MaxPatrol SIEM (Product_ID = 19)
(19, '2024-02-01', '2025-02-01', 250000.00, 1),

-- PT Application Firewall (Product_ID = 20)
(20, '2024-09-01', '2025-09-01', 180000.00, 1);

-- 5. Devices
INSERT INTO Devices (Location_ID, Device_Type, Purchase_Date, Service_Life_Months, Hostname) VALUES
(1, 'ПК',      '2022-09-01', 60, 'PC-101-01'),
(1, 'ПК',      '2022-09-01', 60, 'PC-101-02'),
(1, 'ПК',      '2022-09-01', 60, 'PC-101-03'),
(1, 'ПК',      '2023-09-01', 60, 'PC-101-04'),
(1, 'ПК',      '2023-09-01', 60, 'PC-101-05'),
(2, 'ПК',      '2023-01-15', 60, 'PC-102-01'),
(2, 'ПК',      '2023-01-15', 60, 'PC-102-02'),
(2, 'ПК',      '2023-01-15', 60, 'PC-102-03'),
(3, 'ПК',      '2021-09-01', 60, 'PC-201-01'),
(3, 'ПК',      '2021-09-01', 60, 'PC-201-02'),
(3, 'ПК',      '2021-09-01', 60, 'PC-201-03'),
(3, 'ПК',      '2023-03-01', 60, 'PC-201-04'),
(3, 'ПК',      '2023-03-01', 60, 'PC-201-05'),
(4, 'Ноутбук', '2023-06-01', 48, 'NB-202-01'),
(4, 'Ноутбук', '2023-06-01', 48, 'NB-202-02'),
(4, 'Ноутбук', '2024-01-10', 48, 'NB-202-03'),
(5, 'ПК',      '2022-01-15', 60, 'PC-203-01'),
(5, 'ПК',      '2022-01-15', 60, 'PC-203-02'),
(5, 'ПК',      '2024-02-01', 60, 'PC-203-03'),
(5, 'ПК',      '2024-02-01', 60, 'PC-203-04'),
(6, 'ПК',      '2023-09-01', 60, 'PC-301-01'),
(6, 'ПК',      '2023-09-01', 60, 'PC-301-02'),
(6, 'ПК',      '2024-09-01', 60, 'PC-301-03'),
(7, 'Ноутбук', '2024-03-01', 48, 'NB-302-01'),
(7, 'Ноутбук', '2024-03-01', 48, 'NB-302-02'),
(10, 'Сервер', '2021-06-01', 84, 'SRV-01'),
(10, 'Сервер', '2022-12-01', 84, 'SRV-02'),
(10, 'Сервер', '2024-06-01', 84, 'SRV-03');

-- 6. Installations

INSERT INTO Installations (Device_ID, License_ID, Last_Activity_Date, Usage_Count) VALUES
(1,  1, '2025-03-28', 450),
(2,  1, '2025-03-27', 430),
(3,  1, '2025-03-28', 410),
(4,  2, '2025-03-26', 380),
(5,  2, '2025-03-28', 395),
(6,  1, '2025-03-25', 350),
(7,  1, '2025-03-28', 360),
(8,  1, '2025-03-27', 340),
(1,  4, '2025-03-28', 500),
(2,  4, '2025-03-27', 480),
(3,  4, '2025-03-28', 490),
(6,  5, '2025-03-25', 310),
(7,  5, '2025-03-28', 320),
(9,  5, '2025-03-20', 280),
(10, 5, '2025-03-22', 260),
(9,  7, '2025-03-15', 120),
(10, 7, '2025-03-18', 140),
(11, 7, '2025-03-20', 110),
(12, 8, '2025-03-25', 95),
(13, 8, '2025-03-28', 105),
(17, 10, '2025-03-22', 85),
(18, 11, '2025-03-28', 92),
(19, 11, '2025-03-27', 78),
(20, 12, '2025-02-10', 45),
(17, 13, '2025-03-20', 60),
(18, 14, '2025-03-25', 72),
(19, 14, '2025-03-28', 55),
(14, 15, '2025-03-18', 30),
(15, 16, '2025-03-28', 42),
(9,  17, '2025-03-10', 200),
(10, 17, '2025-03-15', 190),
(11, 18, '2025-03-28', 175),
(12, 18, '2025-03-26', 160),
(21, 19, '2025-03-12', 140),
(22, 20, '2025-03-28', 155),
(23, 20, '2025-03-25', 130),
(24, 21, '2025-03-20', 60),
(25, 21, '2025-03-28', 55),
(1,  22, '2025-03-28', 500),
(2,  22, '2025-03-28', 490),
(3,  22, '2025-03-28', 480),
(6,  23, '2025-03-28', 470),
(7,  23, '2025-03-28', 460),
(9,  23, '2025-03-28', 440),
(10, 23, '2025-03-28', 430),
(11, 24, '2025-03-28', 200),
(17, 24, '2025-03-28', 210),
(14, 25, '2025-03-28', 300),
(15, 25, '2025-03-28', 290),
(16, 26, '2025-03-28', 150),
(21, 27, '2025-03-20', 250),
(22, 27, '2025-03-22', 240),
(23, 28, '2025-03-18', 180),
(17, 29, '2025-03-15', 70),
(18, 30, '2025-03-28', 85),
(19, 30, '2025-03-25', 65),
(20, 30, '2025-03-20', 50),
(26, 9, '2025-03-28', 1000),
(27, 9, '2025-03-28', 950),
(28, 33, '2025-03-28', 800),
(26, 34, '2025-03-28', 600),
(27, 35, '2025-03-28', 550);

-- 7. Requests
INSERT INTO Requests (Product_ID, User_Name, User_Email, Request_Date, Status) VALUES
(2, N'Иванов А.С.', 'ivanov@univ.ru', '2024-09-01', N'Одобрено'),
(2, N'Иванов А.С.', 'ivanov@univ.ru', '2024-09-01', N'Одобрено'),
(5, N'Сидоров К.Л.', 'sidorov@univ.ru', '2024-09-10', N'Одобрено'),
(5, N'Сидоров К.Л.', 'sidorov@univ.ru', '2024-09-10', N'Одобрено'),
(3, N'Петрова М.В.', 'petrova@univ.ru', '2024-09-05', N'Одобрено'),
(3, N'Петрова М.В.', 'petrova@univ.ru', '2024-09-05', N'Одобрено'),
(8,  N'Козлов Д.А.',    'kozlov@univ.ru',    '2024-09-15', N'Одобрено'),
(15, N'Морозова Е.И.',  'morozova@univ.ru',  '2024-10-01', N'Одобрено'),
(9,  N'Волков Р.С.',    'volkov@univ.ru',    '2024-10-10', N'Одобрено'),
(6,  N'Новикова А.П.',  'novikova@univ.ru',  '2024-10-15', N'Одобрено'),
(7,  N'Фёдоров И.М.',   'fedorov@univ.ru',   '2024-11-01', N'Одобрено'),
(16, N'Алексеева Т.Н.', 'alekseeva@univ.ru', '2024-11-10', N'Отклонено'),
(10, N'Егоров В.В.',    'egorov@univ.ru',    '2024-11-20', N'Одобрено'),
(13, N'Дмитриева О.С.', 'dmitrieva@univ.ru', '2024-12-01', N'Одобрено'),
(2,  N'Кузнецов П.А.',  'kuznetsov@univ.ru', '2024-12-05', N'В ожидании'),
(5,  N'Попова Л.Г.',    'popova@univ.ru',    '2024-12-10', N'В ожидании'),
(3,  N'Соколов А.Р.',   'sokolov@univ.ru',   '2025-01-10', N'Одобрено'),
(11, N'Лебедева Н.К.',  'lebedeva@univ.ru',  '2025-01-15', N'Одобрено'),
(15, N'Михайлов С.Д.',  'mikhailov@univ.ru', '2025-01-20', N'В ожидании'),
(8,  N'Новиков Е.А.',   'novikov@univ.ru',   '2025-02-01', N'Одобрено'),
(19, N'Зайцев О.П.',    'zaytsev@univ.ru',   '2025-02-05', N'Отклонено'),
(20, N'Борисова Д.Л.',  'borisova@univ.ru',  '2025-02-10', N'Отклонено'),
(2,  N'Григорьев К.М.', 'grigoriev@univ.ru', '2025-02-15', N'Одобрено'),
(9,  N'Романова В.И.',  'romanova@univ.ru',  '2025-02-20', N'В ожидании'),
(14, N'Васильев Н.С.',  'vasiliev@univ.ru',  '2025-03-01', N'Одобрено'),
(1,  N'Павлова А.М.',   'pavlova@univ.ru',   '2025-03-05', N'В ожидании'),
(17, N'Семёнов Д.В.',   'semenov@univ.ru',   '2025-03-10', N'Отклонено'),
(4,  N'Голубева И.Р.',  'golubeva@univ.ru',  '2025-03-15', N'Одобрено');

SELECT * FROM Requests;
SELECT * FROM Installations;
SELECT * FROM Devices;
SELECT * FROM Licenses;
SELECT * FROM Products;
SELECT * FROM Locations;
SELECT * FROM Vendors;

--3. Вычисление итогов стоимости определенного вида ПО помесячно, за квартал, за полгода, за год
CREATE OR ALTER PROCEDURE sp_ProductCostByPeriod
    @Product_ID INT,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

	WITH src as (
		SELECT 
            p.Name AS ProductName,
            YEAR(l.Purchase_Date) AS Yr,
            MONTH(l.Purchase_Date) AS Mn,
            DATEPART(QUARTER, l.Purchase_Date) AS Qr,
            CASE WHEN MONTH(l.Purchase_Date) <= 6 THEN 1 ELSE 2 END AS Hf,
            l.Total_Seats AS TotalSeats,
            l.Unit_Price AS UnitPrice
        FROM Licenses l
            JOIN Products p ON l.Product_ID = p.Product_ID
        WHERE l.Product_ID = @Product_ID
          AND l.Purchase_Date BETWEEN @StartDate AND @EndDate
	)

    SELECT 
        ProductName,
        Yr AS Year,
        CASE WHEN GROUPING(Mn) = 0 THEN Mn END AS Month,
        CASE WHEN GROUPING(Qr) = 0 THEN Qr END AS Quarter,
        CASE WHEN GROUPING(Hf) = 0 THEN Hf END AS HalfYear,
        SUM(TotalSeats) AS TotalLicenses,
        SUM(TotalSeats * UnitPrice) AS TotalCost
    FROM src
    GROUP BY GROUPING SETS (
        (ProductName, Yr, Mn),
        (ProductName, Yr, Qr),
        (ProductName, Yr, Hf),
        (ProductName, Yr)
    )
    ORDER BY Year, Month, Quarter, HalfYear;
END;

EXEC sp_ProductCostByPeriod
    @Product_ID = 2,
    @StartDate = '2023-01-01',
    @EndDate = '2025-12-31';

SELECT * FROM Licenses WHERE Product_ID = 2;

--Вычисление итогов стоимости определенного вида ПО за период:
--	количество и стоимость лицензий;
--	сравнение их с общим количество лицензий (в %);
--	сравнение их с общей стоимостью лицензий (в %).

CREATE OR ALTER PROCEDURE sp_LicenseCostAnalysis
    @DateFrom DATE = '2023-01-01',
    @DateTo   DATE = '2025-12-31'
AS
BEGIN
    SELECT
        p.Category AS [Категория ПО],
        p.Name AS [Продукт],
        YEAR(l.Purchase_Date) AS [Год],
        COUNT(*) AS [Кол-во лицензий],
        SUM(l.Unit_Price * l.Total_Seats) AS [Стоимость],
 
        CAST( COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
		AS DECIMAL(5,2)) AS [% от общего кол-ва],
 
        CAST( SUM(l.Unit_Price * l.Total_Seats) * 100.0 /
              SUM( SUM(l.Unit_Price * l.Total_Seats)) OVER ()
        AS DECIMAL(5,2)) AS [% от общей стоимости]
 
    FROM Licenses l
        JOIN Products p ON l.Product_ID = p.Product_ID
    WHERE l.Purchase_Date BETWEEN @DateFrom AND @DateTo
 
    GROUP BY p.Category, p.Name, YEAR(l.Purchase_Date)
    ORDER BY p.Category, p.Name, [Год];
END;

SELECT * FROM Licenses;
SELECT * FROM Products;

EXEC sp_LicenseCostAnalysis '2023-01-01', '2024-12-31';   


--5. Продемонстрируйте применение функции ранжирования ROW_NUMBER() для разбиения результатов
--запроса на страницы (по 20 строк на каждую страницу).
CREATE OR ALTER PROCEDURE sp_InstallationsPaged
    @PageNumber INT = 1
AS
BEGIN
    SELECT *
    FROM (
        SELECT
            ROW_NUMBER() OVER (ORDER BY i.Install_ID) AS [№],
            d.Hostname AS [Устройство],
            p.Name AS [Продукт],
            i.Usage_Count AS [Использований]
        FROM Installations i
            JOIN Devices d ON i.Device_ID  = d.Device_ID
            JOIN Licenses l ON i.License_ID = l.License_ID
            JOIN Products p ON l.Product_ID = p.Product_ID
    ) t
    WHERE [№] BETWEEN (@PageNumber - 1) * 20 + 1
                    AND @PageNumber * 20
    ORDER BY [№];
END;

EXEC sp_InstallationsPaged 1;  -- страница 1
EXEC sp_InstallationsPaged 2;  -- страница 2

-- 6. Продемонстрируйте применение функции ранжирования ROW_NUMBER() для удаления дубликатов.

CREATE OR ALTER PROCEDURE sp_RequestsNoDuplicates
AS
BEGIN
    WITH cte AS (
        SELECT *, ROW_NUMBER() OVER (
            PARTITION BY User_Name, Product_ID
            ORDER BY Request_ID DESC
        ) AS rn
        FROM Requests
    )
    DELETE FROM cte
    WHERE rn > 1;
END;
GO

EXEC sp_RequestsNoDuplicates;
SELECT * FROM Requests;

-- Задание 7: Для каждого вендора — суммы затрат
-- на лицензирование за последние 6 месяцев помесячно

CREATE OR ALTER PROCEDURE sp_VendorCostLast6Months
AS
BEGIN
    SELECT
        v.Name AS [Вендор],
        YEAR(l.Purchase_Date) AS [Год],
        MONTH(l.Purchase_Date) AS [Месяц],
        SUM(l.Unit_Price * l.Total_Seats) AS [Стоимость за месяц],

        SUM(SUM(l.Unit_Price * l.Total_Seats)) OVER (
            PARTITION BY v.Vendor_ID
            ORDER BY YEAR(l.Purchase_Date), MONTH(l.Purchase_Date)
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ) AS [Сумма за 6 месяцев]

    FROM Licenses l
         JOIN Products p ON l.Product_ID = p.Product_ID
         JOIN Vendors v  ON p.Vendor_ID  = v.Vendor_ID

    GROUP BY v.Vendor_ID, v.Name, YEAR(l.Purchase_Date), MONTH(l.Purchase_Date)
    ORDER BY v.Name, [Год], [Месяц];
END;

EXEC sp_VendorCostLast6Months;

-- 8: Какой тип ПО (категория) использовался
-- наибольшее число раз для устройств определённого
-- вида? Вернуть для всех видов устройств.

CREATE OR ALTER PROCEDURE sp_TopCategoryByDeviceType
AS
BEGIN
    WITH cte AS (
        SELECT
            d.Device_Type AS [Тип устройства],
            p.Category AS [Категория ПО],
            COUNT(*) AS [Кол-во установок],
            ROW_NUMBER() OVER (
                PARTITION BY d.Device_Type
                ORDER BY COUNT(*) DESC
            ) AS rn
        FROM Installations i
            JOIN Devices d ON i.Device_ID  = d.Device_ID
            JOIN Licenses l ON i.License_ID = l.License_ID
            JOIN Products p ON l.Product_ID = p.Product_ID
        GROUP BY
            d.Device_Type,
            p.Category
    )
    SELECT [Тип устройства], [Категория ПО], [Кол-во установок]
    FROM cte
    WHERE rn = 1;
END;


EXEC sp_TopCategoryByDeviceType;