--1
ALTER TABLE Products
ADD Category_Node hierarchyid;
GO

--2
CREATE PROCEDURE GetProductHierarchy
    @ParentNode hierarchyid
AS
BEGIN

    SELECT 
        Product_ID,
        Name,
        Category,
        Category_Node.ToString() AS Node_Path,
        Category_Node.GetLevel() AS Hierarchy_Level
    FROM Products
    WHERE Category_Node.IsDescendantOf(@ParentNode) = 1
    ORDER BY Category_Node;

END
GO


--3
CREATE PROCEDURE AddProductChild
    @ParentNode hierarchyid,     
    @Vendor_ID INT,              
    @Name NVARCHAR(255),        
    @Category NVARCHAR(100),     
    @Version NVARCHAR(50)       
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LastChild hierarchyid;
    DECLARE @NewNode hierarchyid;

    SELECT @LastChild = MAX(Category_Node)
    FROM Products
    WHERE Category_Node.GetAncestor(1) = @ParentNode;

    SET @NewNode = @ParentNode.GetDescendant(@LastChild, NULL);

    INSERT INTO Products (Vendor_ID, Name, Category, Version, Category_Node)
    VALUES (@Vendor_ID, @Name, @Category, @Version, @NewNode);
END
GO


DECLARE @ParentNode hierarchyid;
SELECT @ParentNode = Category_Node
FROM Products
WHERE Product_ID = 4;
EXEC AddProductChild
    @ParentNode = @ParentNode,
    @Vendor_ID = 1,
    @Name = 'Advanced Word Plugin',
    @Category = 'Addon',
    @Version = 'v2';



--4
CREATE OR ALTER PROCEDURE MoveProductSubtree
    @OldParent hierarchyid,  
    @NewParent hierarchyid   
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LastChild hierarchyid;
    DECLARE @NewRoot hierarchyid;

    SELECT @LastChild = MAX(Category_Node)
    FROM Products
    WHERE Category_Node.GetAncestor(1) = @NewParent;

    SET @NewRoot = @NewParent.GetDescendant(@LastChild, NULL);

    UPDATE Products
    SET Category_Node = Category_Node.GetReparentedValue(@OldParent, @NewRoot)
    WHERE Category_Node.IsDescendantOf(@OldParent) = 1
END
GO


--Демонстрация
DBCC CHECKIDENT ('Products', RESEED, 0);
delete from products;

INSERT INTO Products (Vendor_ID, Name, Category, Version)
VALUES (1, 'Software Catalog', 'Root', '1.0'), -- /
(1, 'Office Software', 'Category', '1.0'),   -- /1
(1, 'Development Software', 'Category', '1.0'), -- /2
(1, 'Word Processor', 'Subcategory', '1.0'), -- /1/1
(1, 'Spreadsheets', 'Subcategory', '1.0'),   -- /1/2
(1, 'IDE', 'Subcategory', '1.0'),            -- /2/1
(1, 'Version Control', 'Subcategory', '1.0'); -- /2/2

UPDATE Products SET Category_Node = hierarchyid::GetRoot() WHERE Product_ID = 1;
UPDATE Products SET Category_Node = hierarchyid::Parse('/1/') WHERE Product_ID = 2;
UPDATE Products SET Category_Node = hierarchyid::Parse('/2/') WHERE Product_ID = 3;
UPDATE Products SET Category_Node = hierarchyid::Parse('/1/1/') WHERE Product_ID = 4;
UPDATE Products SET Category_Node = hierarchyid::Parse('/1/2/') WHERE Product_ID = 5;
UPDATE Products SET Category_Node = hierarchyid::Parse('/2/1/') WHERE Product_ID = 6;
UPDATE Products SET Category_Node = hierarchyid::Parse('/2/2/') WHERE Product_ID = 7;
GO

select * from products;

SELECT Category_Node.ToString() as Category_Node, Product_ID,
Vendor_ID, Name, Category, Version from Products

--2
DECLARE @node hierarchyid
SET @node = hierarchyid::Parse('/')
EXEC GetProductHierarchy @node

DECLARE @node hierarchyid
SET @node = hierarchyid::Parse('/2/')
EXEC GetProductHierarchy @node

--3
DECLARE @ParentNode hierarchyid;
SELECT @ParentNode = Category_Node
FROM Products
WHERE Product_ID = 6;
EXEC AddProductChild
    @ParentNode = @ParentNode,
    @Vendor_ID = 1,
    @Name = 'Medium Word Plugin',
    @Category = 'Addon',
    @Version = 'v2';


--4
DECLARE @old hierarchyid;
DECLARE @new hierarchyid;

SET @old = hierarchyid::Parse('/1/');
SET @new = hierarchyid::Parse('/2/');

EXEC MoveProductSubtree @OldParent = @old, @NewParent = @new;