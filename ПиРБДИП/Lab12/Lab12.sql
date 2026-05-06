--1
CREATE TABLE dbo.Report
(
    id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    report_xml XML NOT NULL
);

--2
CREATE OR ALTER PROCEDURE dbo.sp_GenerateLicenseXml
    @ReportXml XML OUTPUT
AS
BEGIN
    SELECT @ReportXml =
    (
        SELECT GETDATE() AS [@generatedAt],
            (
                SELECT
                    COUNT(*) AS [LicensesCount],
                    SUM(l.Total_Seats) AS [TotalSeats],
                    SUM(l.Unit_Price * l.Total_Seats) AS [TotalCost]
                FROM Licenses l
                FOR XML PATH('Total'), TYPE
            ),
            (
                SELECT
                    v.Vendor_ID AS [@vendorId],
                    v.Name AS [@vendorName],
                    p.Product_ID AS [@productId],
                    p.Name AS [@productName],
                    p.Category AS [@category],
                    l.License_ID AS [@licenseId],
                    l.Unit_Price AS [UnitPrice],
                    l.Total_Seats AS [TotalSeats],
                    l.Unit_Price * l.Total_Seats AS [LicenseCost]
                FROM Vendors v
                INNER JOIN Products p
					ON p.Vendor_ID = v.Vendor_ID
                INNER JOIN Licenses l
					ON l.Product_ID = p.Product_ID
                FOR XML PATH('LicenseInfo'), ROOT('Licenses'), TYPE
            ),
            (
                SELECT
                    v.Name AS [@vendorName],
                    COUNT(l.License_ID) AS [LicensesCount],
                    SUM(l.Total_Seats) AS [TotalSeats],
                    SUM(l.Unit_Price * l.Total_Seats) AS [VendorTotalCost]
                FROM Vendors v
                INNER JOIN Products p
					ON p.Vendor_ID = v.Vendor_ID
				INNER JOIN Licenses l
					ON l.Product_ID = p.Product_ID
                GROUP BY v.Name
                FOR XML PATH('VendorTotal'), ROOT('VendorTotals'), TYPE
            )

        FOR XML PATH('LicenseReport'), TYPE
    );
END;

--3	
CREATE OR ALTER PROCEDURE sp_InsertLicenseReport
AS
BEGIN
    DECLARE @Xml XML;

    EXEC sp_GenerateLicenseXml @ReportXml = @Xml OUTPUT;

    INSERT INTO dbo.Report(report_xml) VALUES (@Xml);
END;

EXEC sp_InsertLicenseReport;

SELECT * FROM Report;

--4
CREATE PRIMARY XML INDEX PXML_Report_report_xml
ON Report(report_xml);

SELECT * FROM dbo.Report
WHERE report_xml.exist('/LicenseReport/Licenses/LicenseInfo[@vendorName="Microsoft"]') = 1;

--5
CREATE OR ALTER PROCEDURE sp_GetXmlReportByVendorName
    @VendorName NVARCHAR(255)
AS
BEGIN
    SELECT
        r.id AS ReportId,

        X.Node.value('@vendorId', 'INT') AS VendorId,
        X.Node.value('@vendorName', 'NVARCHAR(255)') AS VendorName,
        X.Node.value('@productId', 'INT') AS ProductId,
        X.Node.value('@productName', 'NVARCHAR(255)') AS ProductName,
        X.Node.value('@category', 'NVARCHAR(100)') AS Category,
        X.Node.value('@licenseId', 'INT') AS LicenseId,

        X.Node.value('(UnitPrice/text())[1]', 'DECIMAL(18,2)') AS UnitPrice,
        X.Node.value('(TotalSeats/text())[1]', 'INT') AS TotalSeats,
        X.Node.value('(LicenseCost/text())[1]', 'DECIMAL(18,2)') AS LicenseCost
    FROM dbo.Report r
        CROSS APPLY r.report_xml.nodes('/LicenseReport/Licenses/LicenseInfo') AS X(Node)
    WHERE X.Node.value('@vendorName', 'NVARCHAR(255)') = @VendorName;
END;

EXEC dbo.sp_GetXmlReportByVendorName @VendorName = N'Microsoft';