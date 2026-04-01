-- 6. Тип пространственных данных во всех таблицах
SELECT '10m_coastline' AS table_name, geom.STGeometryType() AS geom_type
FROM dbo.[10m_coastline] WHERE qgs_fid = 1
UNION ALL
SELECT '10m_ocean', geom.STGeometryType()
FROM dbo.[10m_ocean] WHERE qgs_fid = 1
UNION ALL
SELECT '10m_rivers_lake_centerlines', geom.STGeometryType()
FROM dbo.[10m_rivers_lake_centerlines] WHERE qgs_fid = 1;

-- 7. Определение SRID
SELECT '10m_coastline' AS table_name, geom.STSrid AS srid
FROM dbo.[10m_coastline] WHERE qgs_fid = 1
UNION ALL
SELECT '10m_ocean', geom.STSrid
FROM dbo.[10m_ocean] WHERE qgs_fid = 1
UNION ALL
SELECT '10m_rivers_lake_centerlines', geom.STSrid
FROM dbo.[10m_rivers_lake_centerlines] WHERE qgs_fid = 1;

-- 8. Атрибутивные столбцы 
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('10m_coastline', '10m_ocean', '10m_rivers_lake_centerlines')
  AND DATA_TYPE != 'geometry'
ORDER BY TABLE_NAME;

-- 9. Описания объектов в формате WKT
SELECT TOP 5 qgs_fid, geom.STAsText() AS wkt, geom.STGeometryType() AS type
FROM dbo.[10m_coastline];

-- 10.1. Пересечение 
SELECT TOP 3
    a.qgs_fid AS coastline_id,
    b.qgs_fid AS ocean_id,
    a.geom.STIntersection(b.geom).STAsText() AS intersection_wkt
FROM dbo.[10m_coastline] a
JOIN dbo.[10m_ocean] b ON a.geom.STIntersects(b.geom) = 1;

-- 10.2. Координаты вершин
SELECT TOP 5
    qgs_fid,
    geom.STNumPoints() AS num_points,
    geom.STStartPoint().STX AS start_lon,
    geom.STStartPoint().STY AS start_lat,
    geom.STEndPoint().STX AS end_lon,
    geom.STEndPoint().STY AS end_lat
FROM dbo.[10m_coastline];

-- 10.3. Площадь океанов и длина линий
SELECT TOP 5 qgs_fid, geom.STArea() AS area FROM dbo.[10m_ocean];
SELECT TOP 5 qgs_fid, geom.STLength() AS length FROM dbo.[10m_coastline];
SELECT TOP 5 qgs_fid, geom.STLength() AS length FROM dbo.[10m_rivers_lake_centerlines];

-- 11. Создание точки, линии и полигона
CREATE TABLE dbo.MyObjects (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    geom geometry
);

INSERT INTO dbo.MyObjects (name, geom) VALUES
('London', geometry::STGeomFromText('POINT(-0.1276 51.5074)', 4326));

INSERT INTO dbo.MyObjects (name, geom) VALUES
('Thames', geometry::STGeomFromText('LINESTRING(-0.0005 51.5085, -0.0763 51.5050, -0.1276 51.5007)', 4326));

INSERT INTO dbo.MyObjects (name, geom) VALUES
('London area', geometry::STGeomFromText('POLYGON((-0.5 51.3, 0.3 51.3, 0.3 51.7, -0.5 51.7, -0.5 51.3))', 4326));

SELECT id, name, geom.STGeometryType() AS type, geom.STAsText() AS wkt FROM dbo.MyObjects;

--12.	Найдите, в какие пространственные объекты попадают созданные вами объекты
SELECT 'London' AS name, 'coastline' AS source, c.qgs_fid
FROM dbo.[10m_coastline] c
WHERE c.geom.STDistance(geometry::STGeomFromText('POINT(-0.1276 51.5074)', 4326)) < 0.5
UNION ALL
SELECT 'London', 'river', r.qgs_fid
FROM dbo.[10m_rivers_lake_centerlines] r
WHERE r.geom.STDistance(geometry::STGeomFromText('POINT(-0.1276 51.5074)', 4326)) < 0.5
UNION ALL
SELECT m.name, 'ocean', o.qgs_fid
FROM dbo.MyObjects m
JOIN dbo.[10m_ocean] o ON m.geom.STIntersects(o.geom) = 1
UNION ALL
SELECT m.name, 'river', r.qgs_fid
FROM dbo.MyObjects m
JOIN dbo.[10m_rivers_lake_centerlines] r ON m.geom.STIntersects(r.geom) = 1;

-- 13. Пространственные индексы
CREATE SPATIAL INDEX IX_ocean ON dbo.[10m_ocean](geom)
USING GEOMETRY_GRID
WITH (BOUNDING_BOX = (-180, -90, 180, 90));

CREATE SPATIAL INDEX IX_coast ON dbo.[10m_coastline](geom)
USING GEOMETRY_GRID
WITH (BOUNDING_BOX = (-180, -90, 180, 90));

CREATE SPATIAL INDEX IX_rivers ON dbo.[10m_rivers_lake_centerlines](geom)
USING GEOMETRY_GRID
WITH (BOUNDING_BOX = (-180, -90, 180, 90));

SELECT OBJECT_NAME(object_id) AS table_name, name AS index_name
FROM sys.spatial_indexes;

SELECT o.qgs_fid
FROM dbo.[10m_ocean] o WITH(INDEX(IX_ocean))
WHERE o.geom.STIntersects(geometry::STGeomFromText('POINT(-30.0 40.0)', 4326)) = 1;

-- 14. Хранимая процедура, возвращает пространственный объект, в который эта точка попадает
CREATE OR ALTER PROCEDURE FindByPoint
    @lon FLOAT,
    @lat FLOAT
AS
BEGIN
    DECLARE @pt geometry = geometry::STGeomFromText(
        'POINT(' + CAST(@lon AS VARCHAR) + ' ' + CAST(@lat AS VARCHAR) + ')', 4326);

    SELECT 'ocean' AS src, qgs_fid FROM dbo.[10m_ocean]
    WHERE geom.STContains(@pt) = 1
    UNION ALL
    SELECT 'coastline', qgs_fid FROM dbo.[10m_coastline]
    WHERE geom.STDistance(@pt) < 1
    UNION ALL
    SELECT 'river', qgs_fid FROM dbo.[10m_rivers_lake_centerlines]
    WHERE geom.STDistance(@pt) < 1;
END;
GO

EXEC FindByPoint -0.1276, 51.5074;
EXEC FindByPoint -30.0, 40.0;
EXEC FindByPoint 37.6173, 55.7558;