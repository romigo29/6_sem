BEGIN
    CREATE DATABASE SoftwareLicenseManagement;
END
GO

CREATE TABLE Vendors (
    Vendor_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) NULL
);

-- 3. Таблица: Locations (Помещения / Классы)
IF OBJECT_ID('Locations', 'U') IS NOT NULL DROP TABLE Locations;
CREATE TABLE Locations (
    Location_ID INT IDENTITY(1,1) PRIMARY KEY,
    Room_Number NVARCHAR(50) NOT NULL,
    Planned_Growth_Seats INT DEFAULT 0 -- Для прогноза расширения
);

-- 4. Таблица: Products (Репозиторий ПО)
IF OBJECT_ID('Products', 'U') IS NOT NULL DROP TABLE Products;
CREATE TABLE Products (
    Product_ID INT IDENTITY(1,1) PRIMARY KEY,
    Vendor_ID INT NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Category NVARCHAR(100) NOT NULL, -- Группировка популярности
    Version NVARCHAR(50) NULL,
    CONSTRAINT FK_Products_Vendors FOREIGN KEY (Vendor_ID) REFERENCES Vendors(Vendor_ID)
);

-- 5. Таблица: Licenses (Лицензии)
IF OBJECT_ID('Licenses', 'U') IS NOT NULL DROP TABLE Licenses;
CREATE TABLE Licenses (
    License_ID INT IDENTITY(1,1) PRIMARY KEY,
    Product_ID INT NOT NULL,
    Purchase_Date DATE NOT NULL,
    Expiration_Date DATE NULL,
    Unit_Price DECIMAL(18, 2) NOT NULL, -- Основа для ROI и трендов
    Total_Seats INT NOT NULL,
    CONSTRAINT FK_Licenses_Products FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

-- 6. Таблица: Devices (Инвентаризация оборудования)
IF OBJECT_ID('Devices', 'U') IS NOT NULL DROP TABLE Devices;
CREATE TABLE Devices (
    Device_ID INT IDENTITY(1,1) PRIMARY KEY,
    Location_ID INT NOT NULL,
    Device_Type NVARCHAR(50) NOT NULL, -- Сервер, ПК, Ноутбук
    Purchase_Date DATE NOT NULL,
    Service_Life_Months INT NOT NULL, -- Для расчета устаревания
    Hostname NVARCHAR(100) NULL,
    CONSTRAINT FK_Devices_Locations FOREIGN KEY (Location_ID) REFERENCES Locations(Location_ID)
);

-- 7. Таблица: Installations (Учет использования)
IF OBJECT_ID('Installations', 'U') IS NOT NULL DROP TABLE Installations;
CREATE TABLE Installations (
    Install_ID INT IDENTITY(1,1) PRIMARY KEY,
    Device_ID INT NOT NULL,
    License_ID INT NOT NULL,
    Last_Activity_Date DATETIME NULL,
    Usage_Count INT DEFAULT 0, -- Метрика для ROI
    CONSTRAINT FK_Installations_Devices FOREIGN KEY (Device_ID) REFERENCES Devices(Device_ID),
    CONSTRAINT FK_Installations_Licenses FOREIGN KEY (License_ID) REFERENCES Licenses(License_ID)
);

-- 8. Таблица: Requests (Заявки)
IF OBJECT_ID('Requests', 'U') IS NOT NULL DROP TABLE Requests;
CREATE TABLE Requests (
    Request_ID INT IDENTITY(1,1) PRIMARY KEY,
    Product_ID INT NOT NULL,
    User_Name NVARCHAR(255) NOT NULL,
    User_Email NVARCHAR(255) NULL,
    Request_Date DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50) DEFAULT 'В ожидании', -- В ожидании / Одобрено / Отклонено
    CONSTRAINT FK_Requests_Products FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);
GO

CREATE VIEW vw_ProductCostSummary AS
SELECT 
    p.Product_ID,
    p.Name AS ProductName,
    YEAR(l.Purchase_Date) AS Year,
    MONTH(l.Purchase_Date) AS Month,
    SUM(l.Total_Seats) AS TotalQuantity,
    SUM(l.Total_Seats * l.Unit_Price) AS TotalCost
FROM Licenses l
JOIN Products p ON l.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Name, YEAR(l.Purchase_Date), MONTH(l.Purchase_Date);


CREATE VIEW vw_VendorSpending AS
SELECT 
    v.Vendor_ID,
    v.Name AS VendorName,
    YEAR(l.Purchase_Date) AS Year,
    MONTH(l.Purchase_Date) AS Month,
    SUM(l.Total_Seats * l.Unit_Price) AS TotalSpent
FROM Licenses l
JOIN Products p ON l.Product_ID = p.Product_ID
JOIN Vendors v ON p.Vendor_ID = v.Vendor_ID
WHERE l.Purchase_Date >= DATEADD(MONTH, -6, GETDATE())
GROUP BY v.Vendor_ID, v.Name, YEAR(l.Purchase_Date), MONTH(l.Purchase_Date);

CREATE INDEX idx_Licenses_ProductPurchase
ON Licenses(Product_ID, Purchase_Date);

CREATE INDEX idx_Installations_DeviceLicenseDate
ON Installations(Device_ID, License_ID, Last_Activity_Date);


CREATE PROCEDURE sp_AddVendor
    @Name NVARCHAR(255),
    @Email NVARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO Vendors (Name, Email)
    VALUES (@Name, @Email);
END;

CREATE PROCEDURE sp_AddLocation
    @Room_Number NVARCHAR(50),
    @Planned_Growth_Seats INT = 0
AS
BEGIN
    INSERT INTO Locations (Room_Number, Planned_Growth_Seats)
    VALUES (@Room_Number, @Planned_Growth_Seats);
END;

CREATE PROCEDURE sp_AddProduct
    @Vendor_ID INT,
    @Name NVARCHAR(255),
    @Category NVARCHAR(100),
    @Version NVARCHAR(50) = NULL
AS
BEGIN
    INSERT INTO Products (Vendor_ID, Name, Category, Version)
    VALUES (@Vendor_ID, @Name, @Category, @Version);
END;

CREATE PROCEDURE sp_AddLicense
    @Product_ID INT,
    @Purchase_Date DATE,
    @Expiration_Date DATE = NULL,
    @Unit_Price DECIMAL(18,2),
    @Total_Seats INT
AS
BEGIN
    INSERT INTO Licenses (Product_ID, Purchase_Date, Expiration_Date, Unit_Price, Total_Seats)
    VALUES (@Product_ID, @Purchase_Date, @Expiration_Date, @Unit_Price, @Total_Seats);
END;

CREATE PROCEDURE sp_AddDevice
    @Location_ID INT,
    @Device_Type NVARCHAR(50),
    @Purchase_Date DATE,
    @Service_Life_Months INT,
    @Hostname NVARCHAR(100) = NULL
AS
BEGIN
    INSERT INTO Devices (Location_ID, Device_Type, Purchase_Date, Service_Life_Months, Hostname)
    VALUES (@Location_ID, @Device_Type, @Purchase_Date, @Service_Life_Months, @Hostname);
END;

CREATE PROCEDURE sp_AddInstallation
    @Device_ID INT,
    @License_ID INT,
    @Last_Activity_Date DATETIME = NULL,
    @Usage_Count INT = 0
AS
BEGIN
    INSERT INTO Installations (Device_ID, License_ID, Last_Activity_Date, Usage_Count)
    VALUES (@Device_ID, @License_ID, @Last_Activity_Date, @Usage_Count);
END;


CREATE PROCEDURE sp_AddRequest
    @Product_ID INT,
    @User_Name NVARCHAR(255),
    @User_Email NVARCHAR(255) = NULL,
    @Request_Date DATETIME = NULL,
    @Status NVARCHAR(50) = 'В ожидании'
AS
BEGIN
    INSERT INTO Requests (Product_ID, User_Name, User_Email, Request_Date, Status)
    VALUES (@Product_ID, @User_Name, @User_Email, ISNULL(@Request_Date, GETDATE()), @Status);
END;


CREATE FUNCTION fn_GetProductsByVendor(@Vendor_ID INT)
RETURNS TABLE
AS
RETURN
SELECT Product_ID, Name, Category, Version
FROM Products
WHERE Vendor_ID = @Vendor_ID;


CREATE FUNCTION fn_GetLicensesByProduct(@Product_ID INT)
RETURNS TABLE
AS
RETURN
SELECT License_ID, Purchase_Date, Expiration_Date, Unit_Price, Total_Seats
FROM Licenses
WHERE Product_ID = @Product_ID;

CREATE FUNCTION fn_GetDevicesByLocation(@Location_ID INT)
RETURNS TABLE
AS
RETURN
SELECT Device_ID, Device_Type, Purchase_Date, Service_Life_Months, Hostname
FROM Devices
WHERE Location_ID = @Location_ID;

CREATE FUNCTION fn_GetInstallationsByDevice(@Device_ID INT)
RETURNS TABLE
AS
RETURN
SELECT Install_ID, License_ID, Last_Activity_Date, Usage_Count
FROM Installations
WHERE Device_ID = @Device_ID;

CREATE FUNCTION fn_GetRequestsByProduct(@Product_ID INT)
RETURNS TABLE
AS
RETURN
SELECT Request_ID, User_Name, User_Email, Request_Date, Status
FROM Requests
WHERE Product_ID = @Product_ID;

CREATE FUNCTION fn_GetVendor(@Vendor_ID INT)
RETURNS TABLE
AS
RETURN
SELECT Vendor_ID, Name, Email
FROM Vendors
WHERE Vendor_ID = @Vendor_ID;


CREATE FUNCTION fn_GetActiveLicenses()
RETURNS TABLE
AS
RETURN
SELECT License_ID, Product_ID, Purchase_Date, Expiration_Date, Unit_Price, Total_Seats
FROM Licenses
WHERE Expiration_Date IS NULL OR Expiration_Date >= GETDATE();


EXEC sp_AddVendor N'Microsoft', N'contact@microsoft.com';
EXEC sp_AddVendor N'Adobe', N'sales@adobe.com';
EXEC sp_AddVendor N'Kaspersky', N'info@kaspersky.com';
EXEC sp_AddVendor N'JetBrains', N'support@jetbrains.com';
EXEC sp_AddVendor N'Oracle', N'info@oracle.com';

EXEC sp_AddLocation N'101A', 10;
EXEC sp_AddLocation N'202B', 5;
EXEC sp_AddLocation N'303C', 15;
EXEC sp_AddLocation N'404D', 0;
EXEC sp_AddLocation N'505E', 8;

EXEC sp_AddProduct 1, N'Windows 11 Pro', N'Operating System', N'23H2';
EXEC sp_AddProduct 2, N'Photoshop', N'Graphics Editor', N'2024';
EXEC sp_AddProduct 3, N'Kaspersky Endpoint Security', N'Antivirus', N'12.0';
EXEC sp_AddProduct 4, N'IntelliJ IDEA', N'IDE', N'2023.3';
EXEC sp_AddProduct 5, N'Oracle Database', N'Database', N'19c';

-- 1. Объявляем переменные для дат
DECLARE 
    @p1 INT = 1,
    @p2 INT = 2,
    @p3 INT = 3,
    @p4 INT = 4,
    @p5 INT = 5,

    @pd1 DATE = DATEADD(MONTH, -6, CAST(GETDATE() AS DATE)),
    @ed1 DATE = DATEADD(YEAR, 1, CAST(GETDATE() AS DATE)),

    @pd2 DATE = DATEADD(MONTH, -3, CAST(GETDATE() AS DATE)),
    @ed2 DATE = DATEADD(YEAR, 1, CAST(GETDATE() AS DATE)),

    @pd3 DATE = DATEADD(MONTH, -1, CAST(GETDATE() AS DATE)),
    @ed3 DATE = DATEADD(YEAR, 2, CAST(GETDATE() AS DATE)),

    @pd4 DATE = DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)),
    @ed4 DATE = DATEADD(MONTH, 6, CAST(GETDATE() AS DATE)),

    @pd5 DATE = DATEADD(MONTH, -24, CAST(GETDATE() AS DATE)),

    @price1 DECIMAL(18,2) = 150.00,
    @price2 DECIMAL(18,2) = 300.00,
    @price3 DECIMAL(18,2) = 50.00,
    @price4 DECIMAL(18,2) = 200.00,
    @price5 DECIMAL(18,2) = 1000.00,

    @seats1 INT = 50,
    @seats2 INT = 20,
    @seats3 INT = 100,
    @seats4 INT = 15,
    @seats5 INT = 10;


EXEC sp_AddLicense @p1, @pd1, @ed1, @price1, @seats1;
EXEC sp_AddLicense @p2, @pd2, @ed2, @price2, @seats2;
EXEC sp_AddLicense @p3, @pd3, @ed3, @price3, @seats3;
EXEC sp_AddLicense @p4, @pd4, @ed4, @price4, @seats4;
EXEC sp_AddLicense @p5, @pd5, NULL,  @price5, @seats5;


DECLARE
    @loc1 INT = 1,
    @loc2 INT = 2,
    @loc3 INT = 3,
    @loc4 INT = 4,
    @loc5 INT = 5,

    @type1 NVARCHAR(50) = N'PC',
    @type2 NVARCHAR(50) = N'Laptop',
    @type3 NVARCHAR(50) = N'PC',
    @type4 NVARCHAR(50) = N'Server',
    @type5 NVARCHAR(50) = N'Laptop',

    @pd1 DATE = DATEADD(YEAR, -2, CAST(GETDATE() AS DATE)),
    @pd2 DATE = DATEADD(YEAR, -1, CAST(GETDATE() AS DATE)),
    @pd3 DATE = DATEADD(YEAR, -3, CAST(GETDATE() AS DATE)),
    @pd4 DATE = DATEADD(YEAR, -4, CAST(GETDATE() AS DATE)),
    @pd5 DATE = DATEADD(MONTH, -18, CAST(GETDATE() AS DATE)),

    @life1 INT = 60,
    @life2 INT = 48,
    @life3 INT = 72,
    @life4 INT = 84,
    @life5 INT = 48,

    @host1 NVARCHAR(100) = N'PC-'  + LEFT(CONVERT(NVARCHAR(36), NEWID()), 8),
    @host2 NVARCHAR(100) = N'LT-'  + LEFT(CONVERT(NVARCHAR(36), NEWID()), 8),
    @host3 NVARCHAR(100) = N'PC-'  + LEFT(CONVERT(NVARCHAR(36), NEWID()), 8),
    @host4 NVARCHAR(100) = N'SRV-' + LEFT(CONVERT(NVARCHAR(36), NEWID()), 8),
    @host5 NVARCHAR(100) = N'LT-'  + LEFT(CONVERT(NVARCHAR(36), NEWID()), 8);


EXEC sp_AddDevice @loc1, @type1, @pd1, @life1, @host1;
EXEC sp_AddDevice @loc2, @type2, @pd2, @life2, @host2;
EXEC sp_AddDevice @loc3, @type3, @pd3, @life3, @host3;
EXEC sp_AddDevice @loc4, @type4, @pd4, @life4, @host4;
EXEC sp_AddDevice @loc5, @type5, @pd5, @life5, @host5;

EXEC sp_AddInstallation 1, 1, DATEADD(DAY, -5, GETDATE()), 120;
EXEC sp_AddInstallation 2, 2, DATEADD(DAY, -10, GETDATE()), 85;
EXEC sp_AddInstallation 3, 3, DATEADD(DAY, -1, GETDATE()), 200;
EXEC sp_AddInstallation 4, 5, DATEADD(DAY, -30, GETDATE()), 40;
EXEC sp_AddInstallation 5, 4, DATEADD(DAY, -15, GETDATE()), 60;

DECLARE
    @d1 DATETIME = DATEADD(DAY, -5,  GETDATE()),
    @d2 DATETIME = DATEADD(DAY, -10, GETDATE()),
    @d3 DATETIME = DATEADD(DAY, -1,  GETDATE()),
    @d4 DATETIME = DATEADD(DAY, -30, GETDATE()),
    @d5 DATETIME = DATEADD(DAY, -15, GETDATE());

EXEC sp_AddInstallation 1, 1, @d1, 120;
EXEC sp_AddInstallation 2, 2, @d2, 85;
EXEC sp_AddInstallation 3, 3, @d3, 200;
EXEC sp_AddInstallation 4, 5, @d4, 40;
EXEC sp_AddInstallation 5, 4, @d5, 60;

DECLARE
    @r2 DATETIME = DATEADD(DAY, -2, GETDATE()),
    @r4 DATETIME = DATEADD(DAY, -7, GETDATE());

EXEC sp_AddRequest 1, N'Иван Петров',     N'ivan.petrov@mail.com',     NULL, DEFAULT;
EXEC sp_AddRequest 2, N'Анна Смирнова',   N'anna.smirnova@mail.com',   @r2,  N'Одобрено';
EXEC sp_AddRequest 3, N'Дмитрий Козлов',  N'd.kozlov@mail.com',        NULL, DEFAULT;
EXEC sp_AddRequest 4, N'Ольга Морозова',  N'o.morozova@mail.com',      @r4,  N'Отклонено';
EXEC sp_AddRequest 5, N'Сергей Иванов',   N's.ivanov@mail.com',        NULL, DEFAULT;




SELECT *
FROM dbo.fn_GetProductsByVendor(1);

SELECT *
FROM dbo.fn_GetLicensesByProduct(1);

SELECT *
FROM dbo.fn_GetDevicesByLocation(1);

SELECT *
FROM dbo.fn_GetRequestsByProduct(1);

SELECT *
FROM dbo.fn_GetVendor(1);

SELECT *
FROM dbo.fn_GetActiveLicenses();


DECLARE
    rc SYS_REFCURSOR;
BEGIN
    rc := fn_GetProductsByVendor(1);

    -- Вывод результата (для SQL Developer / 12c+)
    DBMS_SQL.RETURN_RESULT(rc);
END;
/