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
(1, '2024-01-15', '2026-01-15', 12000, 20),
(1, '2024-02-15', '2026-01-15', 12000, 20),
(1, '2024-03-15', '2026-01-15', 12000, 20),
(1, '2024-04-15', '2026-01-15', 12000, 20),
(1, '2024-05-15', '2026-01-15', 12000, 20),
(1, '2024-06-15', '2026-01-15', 12000, 20),
(1, '2024-07-10', '2026-05-10', 12500, 15),
(1, '2024-08-20', '2026-09-20', 13000, 10),
(1, '2024-09-05', '2027-02-05', 13500, 12),
(1, '2024-10-15', '2027-07-15', 14000, 18),
(1, '2024-11-01', '2028-03-01', 14500, 10),
(1, '2024-12-10', '2028-10-10', 15000, 8),
(1, '2025-01-15', '2027-01-15', 15500, 12),
(1, '2025-02-10', '2027-02-10', 15800, 14),
(1, '2025-03-05', '2027-08-05', 16000, 10),
(1, '2025-04-20', '2027-10-20', 16200, 16),
(1, '2025-05-12', '2028-01-12', 16500, 9),
(1, '2025-06-01', '2028-03-01', 16800, 11),
(1, '2025-07-18', '2028-07-18', 17000, 13),
(1, '2025-08-22', '2029-02-22', 17200, 8),
(1, '2025-09-14', '2029-04-14', 17500, 15),
(1, '2025-10-07', '2029-09-07', 17800, 10),
(1, '2025-11-19', '2029-11-19', 18000, 12),
(1, '2025-12-03', '2030-06-03', 18200, 14),
(1, '2026-01-25', '2030-01-25', 18500, 11),
(1, '2026-02-14', '2030-07-14', 18800, 9),
(1, '2026-03-09', '2030-10-09', 19000, 13),
(1, '2026-04-17', '2031-01-17', 19200, 16),
(1, '2026-05-05', '2031-03-05', 19500, 10),
(1, '2026-06-28', '2031-06-28', 19800, 12),
(1, '2026-07-15', '2031-11-15', 20000, 8),
(1, '2026-08-30', '2032-02-28', 20200, 14),
(1, '2026-09-22', '2032-05-22', 20500, 10),
(1, '2026-10-11', '2032-09-11', 20800, 7),
(1, '2026-11-08', '2032-12-08', 21000, 15),
(1, '2026-12-19', '2033-04-19', 21200, 9),

-- Product 2
(2, '2024-01-01', '2024-02-01', 5000, 25),
(2, '2024-02-15', '2024-06-15', 5200, 20),
(2, '2024-03-05', '2024-11-05', 5400, 30),
(2, '2024-04-05', '2024-11-05', 6400, 30),
(2, '2024-05-05', '2024-11-05', 7400, 30),
(2, '2024-06-05', '2024-11-05', 3400, 30),
(2, '2024-07-05', '2024-11-05', 5300, 30),
(2, '2024-08-10', '2025-03-10', 5200, 15),
(2, '2024-09-20', '2025-08-20', 5100, 25),
(2, '2024-11-25', '2026-01-25', 6000, 20),
(2, '2024-12-30', '2026-09-30', 6200, 35),
(2, '2025-01-10', '2025-06-10', 6300, 28),
(2, '2025-02-22', '2025-09-22', 6400, 22),
(2, '2025-03-15', '2026-01-15', 6500, 30),
(2, '2025-04-05', '2026-04-05', 6600, 18),
(2, '2025-05-20', '2026-08-20', 6700, 25),
(2, '2025-06-12', '2026-11-12', 6800, 32),
(2, '2025-07-01', '2027-02-01', 6900, 20),
(2, '2025-08-14', '2027-05-14', 7000, 27),
(2, '2025-09-28', '2027-09-28', 7100, 15),
(2, '2025-10-19', '2027-12-19', 7200, 24),
(2, '2025-11-09', '2028-03-09', 7300, 30),
(2, '2025-12-25', '2028-07-25', 7400, 19),
(2, '2026-01-18', '2028-10-18', 7500, 26),
(2, '2026-02-07', '2029-01-07', 7600, 22),
(2, '2026-03-29', '2029-04-29', 7700, 31),
(2, '2026-04-13', '2029-07-13', 7800, 17),
(2, '2026-05-24', '2029-10-24', 7900, 28),
(2, '2026-06-16', '2029-12-16', 8000, 23),
(2, '2026-07-08', '2030-03-08', 8100, 35),
(2, '2026-08-26', '2030-08-26', 8200, 20),
(2, '2026-09-17', '2030-11-17', 8300, 29),
(2, '2026-10-03', '2031-01-03', 8400, 24),
(2, '2026-11-27', '2031-04-27', 8500, 18),
(2, '2026-12-12', '2031-09-12', 8600, 32),


-- Product 3
(3, '2024-01-20', '2026-03-20', 45000, 8),
(3, '2024-03-20', '2026-03-20', 45000, 8),
(3, '2024-04-20', '2026-03-20', 45000, 8),
(3, '2024-05-20', '2026-03-20', 45000, 8),
(3, '2024-06-20', '2026-03-20', 45000, 8),
(3, '2024-07-10', '2026-07-10', 46000, 10),
(3, '2024-09-15', '2027-01-15', 47000, 6),
(3, '2024-10-15', '2027-06-15', 48000, 10),
(3, '2024-11-01', '2028-04-01', 50000, 7),
(3, '2025-01-05', '2027-04-05', 51000, 9),
(3, '2025-02-18', '2027-08-18', 52000, 7),
(3, '2025-03-30', '2027-11-30', 53000, 11),
(3, '2025-04-22', '2028-01-22', 54000, 8),
(3, '2025-05-11', '2028-05-11', 55000, 10),
(3, '2025-06-08', '2028-08-08', 56000, 6),
(3, '2025-07-27', '2028-12-27', 57000, 12),
(3, '2025-08-19', '2029-03-19', 58000, 9),
(3, '2025-09-09', '2029-06-09', 59000, 7),
(3, '2025-10-31', '2029-10-31', 60000, 10),
(3, '2025-11-23', '2030-02-23', 61000, 8),
(3, '2025-12-14', '2030-05-14', 62000, 11),
(3, '2026-01-29', '2030-08-29', 63000, 9),
(3, '2026-02-19', '2030-11-19', 64000, 7),
(3, '2026-03-12', '2031-03-12', 65000, 12),
(3, '2026-04-25', '2031-06-25', 66000, 10),
(3, '2026-05-30', '2031-09-30', 67000, 8),
(3, '2026-06-21', '2031-12-21', 68000, 6),
(3, '2026-07-09', '2032-03-09', 69000, 11),
(3, '2026-08-05', '2032-06-05', 70000, 9),
(3, '2026-09-26', '2032-09-26', 71000, 13),
(3, '2026-10-17', '2033-01-17', 72000, 7),
(3, '2026-11-13', '2033-04-13', 73000, 10),
(3, '2026-12-01', '2033-07-01', 74000, 8);

INSERT INTO Licenses (Product_ID, Purchase_Date, Expiration_Date, Unit_Price, Total_Seats)
VALUES (5, '2025-11-15', '2026-11-15', 8200, 12);

INSERT INTO Licenses (Product_ID, Purchase_Date, Expiration_Date, Unit_Price, Total_Seats)
VALUES (5, '2026-02-10', '2027-02-10', 8500, 10);

-- JetBrains (Vendor_ID = 3, Product_ID = 8)
INSERT INTO Licenses (Product_ID, Purchase_Date, Expiration_Date, Unit_Price, Total_Seats)
VALUES (8, '2025-12-05', '2026-12-05', 15000, 7);

INSERT INTO Licenses (Product_ID, Purchase_Date, Expiration_Date, Unit_Price, Total_Seats)
VALUES (8, '2026-03-18', '2027-03-18', 15800, 9);



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

SELECT * FROM Products;
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

EXEC sp_InstallationsPaged 1; 
EXEC sp_InstallationsPaged 2;  

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

SELECT
    v.Name AS [Вендор],
    YEAR(l.Purchase_Date) AS [Год],
    MONTH(l.Purchase_Date) AS [Месяц],
    SUM(l.Unit_Price * l.Total_Seats) AS [Стоимость за месяц],
    SUM(SUM(l.Unit_Price * l.Total_Seats)) OVER (
        PARTITION BY v.Vendor_ID
    ) AS [Итого за 6 месяцев по вендору]
FROM Licenses l
JOIN Products p ON l.Product_ID = p.Product_ID
JOIN Vendors v ON p.Vendor_ID = v.Vendor_ID
WHERE l.Purchase_Date >= DATEFROMPARTS(YEAR(DATEADD(MONTH, -5, GETDATE())), MONTH(DATEADD(MONTH, -5, GETDATE())), 1)
  AND l.Purchase_Date < DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
GROUP BY
    v.Vendor_ID,
    v.Name,
    YEAR(l.Purchase_Date),
    MONTH(l.Purchase_Date)
ORDER BY v.Name, [Год], [Месяц];


SELECT * FROM Licenses;

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