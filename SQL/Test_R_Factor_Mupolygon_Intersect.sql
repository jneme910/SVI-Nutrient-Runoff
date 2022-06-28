USE sdm;

--http://bboxfinder.com/#41.615676,-93.328981,41.629961,-93.309845
--RKLSclassvalues = "0 12.5 1;12.5 21 2;21 33.5 3;33.5 10000 4"
DROP TABLE IF EXISTS #main4;
DROP TABLE IF EXISTS #second2;
DROP TABLE IF EXISTS #third2;
DROP TABLE IF EXISTS #fourth3;
DROP TABLE IF EXISTS #r_factor3 ;
DROP TABLE IF EXISTS #fifth;
DROP TABLE IF EXISTS #horizon3;
DROP TABLE IF EXISTS #horizon4;
DROP TABLE IF EXISTS #horizon5;
DROP TABLE IF EXISTS #sviaoitable;
DROP TABLE IF EXISTS #sviaoisoils;
DROP TABLE IF EXISTS #final2;
DROP TABLE IF EXISTS #sviaoirfactor

--Define the area
DECLARE @allssa INT;
DECLARE @statsgo INT;
DECLARE @area VARCHAR(20);
DECLARE @area_type INT ;
DECLARE @InRangeTop INT;
DECLARE @InRangeBot INT;
DECLARE @major INT;
DECLARE @aoiGeom Geometry;
DECLARE @aoiGeomFixed Geometry;

-- Soil Data Access
/*
~DeclareChar(@area,20)~  --Enter State Abbreviation or Soil Survey Area i.e. WI or WI025
--~DeclareINT(@allssa)~  --Enter 1 for All Soil Survey areas including STATSGO -- Need to add dynamic operator; WHERE (A = B AND @equalOp = 1) OR (A > B AND @gtOp = 1) OR (A < B AND @ltOp = 1)
--~DeclareINT(@statsgo)~ -- Enter 1 to exclude STATSGO and Run all Soil Survey Areas -- Need to add dynamic operator; WHERE (A = B AND @equalOp = 1) OR (A > B AND @gtOp = 1) OR (A < B AND @ltOp = 1)
~DeclareINT(@area_type)~ --determines number of characters of area 2-State, 5- Soil Survey Area
~DeclareINT(@InRangeTop)~ -- Top Soil Depth
~DeclareINT(@InRangeBot)~  -- Botom Soil Depth
~DeclareINT(@major)~ -- Enter 0 for major component, enter 1 for all component
~DeclareGeometry(@aoiGeom)~
~DeclareGeometry(@aoiGeomFixed)~
*/
-- End soil data access
--SELECT @statsgo = 1;-- Enter 1 to exclude STATSGO and Run all Soil Survey Areas
--SELECT @allssa = 1; --Enter 1 for All Soil Survey areas including STATSGO
SELECT @area= 'WI001'; --Enter State Abbreviation or Soil Survey Area i.e. WI or WI025
SELECT @major = 0; -- Enter 0 for major component, enter 1 for all components
SELECT @InRangeTop = 0;
SELECT @InRangeBot = 15;
---
SELECT @area_type = LEN (@area); --determines number of characters of area 2-State, 5- Soil Survey Area
---

CREATE TABLE #sviaoitable
    ( aoiid INT IDENTITY (1,1),
    landunit CHAR(20),
    aoigeom GEOMETRY );


-- #AoiSoils table contains intersected soil polygon table with geometry
CREATE TABLE #sviaoisoils
    ( polyid INT IDENTITY (1,1),
    aoiid INT,
    landunit CHAR(20),
    mukey INT,
    soilgeom GEOMETRY )

CREATE TABLE #sviaoirfactor
    ( rolyid INT IDENTITY (1,1),
    aoiid INT,
    landunit CHAR(20),
    r_factor REAL,
    geom GEOMETRY )

SELECT @aoiGeom = GEOMETRY::STGeomFromText('MULTIPOLYGON (((-88.39504 44.32962,-88.39416 44.32973,-88.39252 44.32995,-88.39166 44.32930,-88.39266 44.32907,-88.39483 44.32911,-88.39504 44.32962)))', 4326); 
SELECT @aoiGeomFixed = @aoiGeom.MakeValid().STUnion(@aoiGeom.STStartPoint()); 
INSERT INTO #sviaoitable ( landunit, aoigeom )  
VALUES ('T9981 Fld3', @aoiGeomFixed); 
SELECT @aoiGeom = GEOMETRY::STGeomFromText('MULTIPOLYGON (((-88.39473 44.33185,-88.38902 44.33269,-88.38651 44.33108,-88.39027 44.33085,-88.39424 44.33097,-88.39473 44.33185)))', 4326); 

SELECT @aoiGeomFixed = @aoiGeom.MakeValid().STUnion(@aoiGeom.STStartPoint()); 
INSERT INTO #sviaoitable ( landunit, aoigeom )  
VALUES ('T9981 Fld4', @aoiGeomFixed);

INSERT INTO #sviaoirfactor (aoiid, landunit, r_factor, geom)
SELECT A.aoiid, A.landunit, r_factor,--M.mukey,
   B.geom.STIntersection(A.aoigeom ) AS soilgeom
    FROM [sdm_spatial].[dbo].[r_factor] B, #sviaoitable A
    WHERE B.geom.STIntersects(A.aoigeom) = 1

INSERT INTO #sviaoisoils (aoiid, landunit, mukey, soilgeom)
    SELECT A.aoiid, A.landunit, M.mukey, M.mupolygongeo.STIntersection(A.aoigeom ) AS soilgeom
    FROM mupolygon M, #sviaoitable A
    WHERE mupolygongeo.STIntersects(A.aoigeom) = 1

SELECT 
  M.mukey
, A.[r_factor]
, M.soilgeom.STIntersection(A.geom ) AS soilgeom
FROM #sviaoisoils M, #sviaoirfactor A
WHERE soilgeom.STIntersects(A.geom) = 1 ;

