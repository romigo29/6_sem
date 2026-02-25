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