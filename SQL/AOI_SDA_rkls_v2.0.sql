USE sdm;

--http://bboxfinder.com/#41.615676,-93.328981,41.629961,-93.309845
--RKLSclassvalues = "0 12.5 1;12.5 21 2;21 33.5 3;33.5 10000 4"
DROP TABLE IF EXISTS #main4;
DROP TABLE IF EXISTS #second2;
DROP TABLE IF EXISTS #third2;
DROP TABLE IF EXISTS #fourth3;
DROP TABLE IF EXISTS #sviaoirfactor ;
DROP TABLE IF EXISTS #sviaoirfactorjoin3;
DROP TABLE IF EXISTS #fifth;
DROP TABLE IF EXISTS #horizon3;
DROP TABLE IF EXISTS #horizon4;
DROP TABLE IF EXISTS #horizon5;
DROP TABLE IF EXISTS #sviaoitable;
DROP TABLE IF EXISTS #sviaoisoils;
DROP TABLE IF EXISTS #final22;

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
SELECT @aoiGeom = GEOMETRY::STGeomFromText('MULTIPOLYGON (((-88.39504 44.32962,-88.39416 44.32973,-88.39252 44.32995,-88.39166 44.32930,-88.39266 44.32907,-88.39483 44.32911,-88.39504 44.32962)))', 4326); 
SELECT @aoiGeomFixed = @aoiGeom.MakeValid().STUnion(@aoiGeom.STStartPoint()); 
INSERT INTO #sviaoitable ( landunit, aoigeom )  
VALUES ('T9981 Fld3', @aoiGeomFixed); 
SELECT @aoiGeom = GEOMETRY::STGeomFromText('MULTIPOLYGON (((-88.39473 44.33185,-88.38902 44.33269,-88.38651 44.33108,-88.39027 44.33085,-88.39424 44.33097,-88.39473 44.33185)))', 4326); 

SELECT @aoiGeomFixed = @aoiGeom.MakeValid().STUnion(@aoiGeom.STStartPoint()); 
INSERT INTO #sviaoitable ( landunit, aoigeom )  
VALUES ('T9981 Fld4', @aoiGeomFixed);

-- Populate #AoiSoils table with intersected soil polygon geometry
INSERT INTO #sviaoisoils (aoiid, landunit, mukey, soilgeom)
    SELECT A.aoiid, A.landunit, M.mukey, M.mupolygongeo.STIntersection(A.aoigeom ) AS soilgeom
    FROM mupolygon M, #sviaoitable A
    WHERE mupolygongeo.STIntersects(A.aoigeom) = 1

CREATE TABLE #main4
    (
        areasymbol        VARCHAR(255),
        musym            VARCHAR(20),
        mukey            INT,
        muname           VARCHAR(250),
		cokey            INT,
		slope_r          INT,
		slopelenusle_r   INT,
		tfact			 INT,
        major_mu_pct_sum SMALLINT,
		slopelen		 INT, 
		slopelen_palouse INT, 
		palouse  INT,
		landunit CHAR(20),
        datestamp        VARCHAR(32)
    )

INSERT INTO #main4
    (
        areasymbol,
		 musym,
		mukey,
        muname,
        cokey, 
		slope_r, 
		slopelenusle_r,
		tfact,  
        major_mu_pct_sum,
		slopelen,
		slopelen_palouse,
		palouse,
		landunit,
        datestamp
    )

SELECT sc.areasymbol, musym, mu.mukey, muname,  c.cokey, slope_r, slopelenusle_r, tfact,  

                (
                    SELECT
                        SUM(CCO.comppct_r)
                    FROM
                        mapunit       AS MM2
                        INNER JOIN
                            component AS CCO
                                ON CCO.mukey = MM2.mukey
                                   AND mu.mukey = MM2.mukey
                                   AND (CASE
                                            WHEN 1 = @major
                                                THEN 0
                                            WHEN majcompflag = 'Yes'
                                                THEN 0
                                            ELSE
                                                1
                                        END = 0
                                       )
                )  AS major_mu_pct_sum,
					CASE WHEN  slope_r >= 0 and slope_r < 0.75 THEN 100
                    WHEN slope_r >= 0.75 and slope_r < 1.5 THEN 200
                    WHEN slope_r >= 1.5 and slope_r < 2.5 THEN 300
                    WHEN slope_r >= 2.5 and slope_r < 3.5 THEN 200
                    WHEN slope_r >= 3.5 and slope_r < 4.5 THEN 180
                    WHEN slope_r >= 4.5 and slope_r < 5.5 THEN 160
                    WHEN slope_r >= 5.5 and slope_r < 6.5 THEN 150
                    WHEN slope_r >= 6.5 and slope_r < 7.5 THEN 140
                    WHEN slope_r >= 7.5 and slope_r < 8.5 THEN 130
                    WHEN slope_r >= 8.5 and slope_r < 9.5 THEN 125
                    WHEN slope_r >= 9.5 and slope_r < 10.5 THEN 120
                    WHEN slope_r >= 10.5 and slope_r < 11.5 THEN 110
                    WHEN slope_r >= 11.5 and slope_r < 12.5 THEN 100
                    WHEN slope_r >= 12.5 and slope_r < 13.5 THEN 90
                    WHEN slope_r >= 13.5 and slope_r < 14.5 THEN 80
                    WHEN slope_r >= 14.5 and slope_r < 15.5 THEN 70
                    WHEN slope_r >= 15.5 and slope_r < 17.5 THEN 60
                    WHEN slope_r >= 17.5 THEN 50
					ELSE null END AS slopelen,	

					CASE WHEN slope_r >= 0 and slope_r < 5.5 THEN 350
                    WHEN slope_r >= 5.5 and slope_r < 10.5 THEN 275
                  	WHEN slope_r >= 10.5 and slope_r < 15.5 THEN 225
                 	WHEN slope_r >= 15.5 and slope_r < 20.5 THEN 175
                 	WHEN slope_r >= 20.5 and slope_r < 25.5 THEN 150
                   	WHEN slope_r >= 25.5 and slope_r < 35.5 THEN 125
                   	WHEN slope_r >= 35.5 THEN 100
					ELSE null END AS slopelen_palouse	,
					CASE WHEN l.areasymbol = 'ID620' then 1
					WHEN l.areasymbol = 'ID057' then 1
					WHEN l.areasymbol = 'OR021' then 1
					WHEN l.areasymbol = 'OR049' then 1
					WHEN l.areasymbol = 'OR055' then 1
					WHEN l.areasymbol = 'OR625' then 1
					WHEN l.areasymbol = 'OR667' then 1
					WHEN l.areasymbol = 'OR670' then 1
					WHEN l.areasymbol = 'OR673' then 1
					WHEN l.areasymbol = 'WA001' then 1
 					WHEN l.areasymbol = 'WA021' then 1
					WHEN l.areasymbol = 'WA025' then 1
					WHEN l.areasymbol = 'WA043' then 1
					WHEN l.areasymbol = 'WA063' then 1
					WHEN l.areasymbol = 'WA071' then 1
					WHEN l.areasymbol = 'WA075' then 1
					WHEN l.areasymbol = 'WA603' then 1
					WHEN l.areasymbol = 'WA605' then 1
					WHEN l.areasymbol = 'WA613' then 1
					WHEN l.areasymbol = 'WA617' then 1
					WHEN l.areasymbol = 'WA623' then 1
					WHEN l.areasymbol = 'WA639' then 1
					WHEN l.areasymbol = 'WA676' then 1
					WHEN l.areasymbol = 'WA677' then 1 ELSE 0 END AS palouse	,
					landunit, 

				CONCAT([sc].[areasymbol], ' ', FORMAT([sc].[saverest], 'dd-MM-yy')) AS datestamp
 FROM  sacatalog AS  sc
 INNER JOIN legend  AS l ON l.areasymbol = sc.areasymbol
 INNER JOIN  mapunit AS mu ON mu.lkey = l.lkey --AND l.areasymbol = 'US' 
 INNER JOIN #sviaoisoils AS s ON s.mukey=mu.mukey
 --AND CASE  WHEN @area_type = 2 THEN LEFT (l.areasymbol, 2) ELSE l.areasymbol END  = @area


 INNER JOIN  component AS c ON c.mukey = mu.mukey  AND (CASE
                                    WHEN 1 = @major
                                        THEN 0
                                    WHEN majcompflag = 'Yes'
                                        THEN 0
                                    ELSE
                                        1
                                END = 0
                               )
 ORDER BY sc.areasymbol, musym, muname, mu.mukey


 ----Horizon
CREATE TABLE #horizon3
    (
		areasymbol	VARCHAR(30),
		muname		VARCHAR(250),
		mukey		INT,
		compname	VARCHAR(250),
		cokey		INT, 
		compkind	VARCHAR(250),
		chkey		INT,
		hzdept_r	SMALLINT, 
		hzdepb_r	SMALLINT, 
		thickness	SMALLINT, 
		hzname		VARCHAR(30),
		desgnmaster	VARCHAR(30),
		taxorder	VARCHAR(40),
		thickness2	SMALLINT, 
		texture  VARCHAR(250),
		lieutex  VARCHAR(250),
		om			REAL,
		ksat		REAL,
		totalsand	REAL,	
		totalsilt	REAL,
		totalclay	REAL,
		vfsand		REAL,
		dbthirdbar	REAL,	
		kwfact		REAL,
		landunit  CHAR(20)

    )

INSERT INTO #horizon3
    (
	areasymbol, 
	muname, 
	mukey, 
	compname, 
	cokey,  
	compkind, 
	chkey, 
	hzdept_r,
	hzdepb_r, 
	thickness,
	hzname, 
	desgnmaster,
	taxorder, 
	thickness2,
	texture ,
	lieutex,
	om,
	ksat,
	totalsand ,	
	totalsilt,
	totalclay,
	vfsand,	
	dbthirdbar,	
	kwfact ,
	landunit
    )

 SELECT areasymbol, muname, m.mukey, compname, c1.cokey,  compkind, ch1.chkey, CASE WHEN hzdept_r IS NULL THEN @InRangeTop ELSE hzdept_r END AS hzdept_r,
CASE WHEN hzdepb_r IS NULL THEN @InRangeBot ELSE hzdepb_r END AS hzdepb_r, -- Added this for misc land types
 CASE WHEN hzdepb_r IS NULL THEN NULL
WHEN hzdept_r IS NULL THEN NULL
WHEN hzdept_r > hzdepb_r THEN NULL
WHEN hzdept_r = hzdepb_r THEN NULL ELSE
CASE WHEN hzdepb_r > @InRangeBot THEN @InRangeBot ELSE hzdepb_r END END - hzdept_r AS thickness,
hzname, desgnmaster, --lieutex ,


taxorder, 
CASE WHEN hzdept_r > @InRangeBot THEN 0
WHEN hzdepb_r < @InRangeTop THEN 0
WHEN hzdepb_r <= @InRangeBot THEN hzdepb_r  WHEN hzdepb_r > @InRangeBot and hzdept_r < @InRangeBot THEN @InRangeBot ELSE @InRangeTop END-CASE WHEN hzdepb_r < @InRangeTop THEN 0
WHEN hzdept_r >@InRangeBot THEN 0 
WHEN hzdepb_r >= @InRangeTop AND hzdept_r < @InRangeTop THEN @InRangeTop 
WHEN hzdept_r < @InRangeTop THEN 0
WHEN hzdept_r < @InRangeBot then hzdept_r ELSE @InRangeTop END AS thickness2,

(SELECT STRING_AGG(texture, ', ')  FROM chorizon AS ch4 INNER JOIN chtexturegrp AS cht4 ON ch4.chkey = cht4.chkey  AND cht4.rvindicator='yes' AND ch4.chkey=ch1.chkey) AS rv_texture ,
(SELECT STRING_AGG(lieutex, ', ')  FROM chorizon AS ch5 INNER JOIN chtexturegrp AS cht5 ON ch5.chkey = cht5.chkey  AND cht5.rvindicator='yes' AND ch5.chkey=ch1.chkey
INNER JOIN chtexture AS t5 ON t5.chtgkey=cht5.chtgkey) AS rv_lieutex,
CAST (om_r AS DECIMAL (7,3)) AS om,
CAST (ksat_r AS DECIMAL (7,3)) AS  ksat,
CAST (sandtotal_r AS DECIMAL (7,3)) AS totalsand ,		-- total sand, silt and clay fractions 
CAST (silttotal_r AS DECIMAL (7,3)) AS totalsilt,
CAST (claytotal_r AS DECIMAL (7,3)) AS totalclay,
CAST (sandvf_r	AS DECIMAL (7,3)) AS vfsand,		        -- sand sub-fractions 
CAST (dbthirdbar_r AS DECIMAL (7,3)) AS dbthirdbar,	
CASE WHEN kwfact IS NOT NULL THEN kwfact 
WHEN taxorder = 'Histosols' THEN 0.02 
WHEN desgnmaster LIKE '%O%' THEN 0.02  
WHEN hzname LIKE '%O%' THEN 0.02 ELSE kwfact 
END AS kwfact, landunit

FROM #main4 AS m 
INNER JOIN component AS c1 ON m.mukey=c1.mukey 
AND c1.cokey =
(SELECT TOP 1 c2.cokey FROM component AS c2 
INNER JOIN mapunit AS mu2 ON c2.mukey=mu2.mukey AND mu2.mukey=m.mukey AND majcompflag = 'Yes' ORDER BY CASE WHEN compkind = 'Miscellaneous area' THEN 2 ELSE 1 END ASC,  c2.comppct_r DESC, c2.cokey ) 
--Dominant Component - If Misc is first name component use second component
LEFT OUTER JOIN chorizon AS ch1 ON ch1.cokey=c1.cokey 
ORDER BY areasymbol, musym, muname, m.mukey, comppct_r DESC, cokey,  hzdept_r, hzdepb_r

CREATE TABLE #horizon4
    (
		areasymbol	VARCHAR(10),
		muname		VARCHAR(250),
		mukey		INT,
		compname	VARCHAR(250),
		cokey		INT, 
		compkind	VARCHAR(250),
		chkey		INT,
		hzdept_r	SMALLINT, 
		hzdepb_r	SMALLINT, 
		thickness	SMALLINT, 
		hzname		VARCHAR(15),
		desgnmaster	VARCHAR(20),
		taxorder	VARCHAR(100),
		thickness2	SMALLINT, 
		texture  VARCHAR(250),
		lieutex  VARCHAR(250),
		om			REAL,
		ksat		REAL,
		totalsand	REAL,	
		totalsilt	REAL,
		totalclay	REAL,
		vfsand		REAL,
		dbthirdbar	REAL,	
		kwfact		REAL,
		hz_rowid	SMALLINT,
		 landunit CHAR(20)

    )

INSERT INTO #horizon4
    (
	areasymbol, 
	muname, 
	mukey, 
	compname, 
	cokey,  
	compkind, 
	chkey, 
	hzdept_r,
	hzdepb_r, 
	thickness,
	hzname, 
	desgnmaster,
	taxorder, 
	thickness2,
	texture ,
	lieutex,
	om,
	ksat,
	totalsand ,	
	totalsilt,
	totalclay,
	vfsand,	
	dbthirdbar,	
	kwfact ,
	hz_rowid, 
	landunit
    )

SELECT 
	areasymbol, 
	muname, 
	mukey, 
	compname, 
	cokey,  
	compkind, 
	chkey, 
	hzdept_r,
	hzdepb_r, 
	thickness,
	hzname, 
	desgnmaster,
	taxorder, 
	thickness2,
	texture ,
	lieutex,
	om,
	ksat,
	totalsand ,	
	totalsilt,
	totalclay,
	vfsand,	
	dbthirdbar,	
	
	CASE 
	WHEN kwfact IS NOT NULL THEN kwfact 
	WHEN texture LIKE '%mpm%' THEN 0.02
	WHEN texture LIKE '%mpt%'  THEN 0.02
	WHEN texture LIKE '%muck%' THEN 0.02
	WHEN texture LIKE '%peat%' THEN 0.02
	WHEN texture LIKE '%spm%' THEN 0.02
	WHEN texture LIKE '%udom%' THEN 0.02
	WHEN texture LIKE '%pdom%' THEN 0.02
	WHEN texture LIKE '%hpm%'THEN 0.02 ELSE kwfact END AS kwfact ,
	   
		ROW_NUMBER() OVER(PARTITION BY cokey ORDER BY 
		CASE WHEN desgnmaster LIKE '%O%' THEN 2 
		WHEN hzname LIKE '%O%' THEN 2
		WHEN texture LIKE '%mpm%' THEN 2
		WHEN texture LIKE '%mpt%'  THEN 2
		WHEN texture LIKE '%muck%' THEN 2
		WHEN texture LIKE '%peat%' THEN 2
		WHEN texture LIKE '%spm%'  THEN 2
		WHEN texture LIKE '%udom%' THEN 2
		WHEN texture LIKE '%pdom%' THEN 2
		WHEN texture LIKE '%hpm%'  THEN 2
		ELSE 1 END ASC,
		hzdept_r ASC, hzdepb_r ASC, chkey ASC) AS hz_rowid, landunit
FROM #horizon3 WHERE hzdept_r BETWEEN  @InRangeTop AND @InRangeBot  ORDER BY muname 

CREATE TABLE #horizon5
    (
		areasymbol	VARCHAR(30),
		muname		VARCHAR(250),
		mukey		INT,
		compname	VARCHAR(250),
		cokey		INT, 
		compkind	VARCHAR(250),
		chkey		INT,
		hzdept_r	SMALLINT, 
		hzdepb_r	SMALLINT, 
		thickness	SMALLINT, 
		hzname		VARCHAR(30),
		desgnmaster	VARCHAR(40),
		taxorder	VARCHAR(40),
		thickness2	SMALLINT, 
		texture  VARCHAR(250),
		lieutex  VARCHAR(250),
		om			REAL,
		ksat		REAL,
		totalsand	REAL,	
		totalsilt	REAL,
		totalclay	REAL,
		vfsand		REAL,
		dbthirdbar	REAL,	
		kwfact		REAL,
		hz_rowid	SMALLINT,
		 landunit CHAR(20),

    )

INSERT INTO #horizon5
    (
	areasymbol, 
	muname, 
	mukey, 
	compname, 
	cokey,  
	compkind, 
	chkey, 
	hzdept_r,
	hzdepb_r, 
	thickness,
	hzname, 
	desgnmaster,
	taxorder, 
	thickness2,
	texture ,
	lieutex,
	om,
	ksat,
	totalsand ,	
	totalsilt,
	totalclay,
	vfsand,	
	dbthirdbar,	
	kwfact ,
	hz_rowid	,
	landunit
    )

SELECT 	areasymbol, 
	muname, 
	mukey, 
	compname, 
	cokey,  
	compkind, 
	chkey, 
	hzdept_r,
	hzdepb_r, 
	thickness,
	hzname, 
	desgnmaster,
	taxorder, 
	thickness2,
	texture ,
	lieutex,
	om,
	ksat,
	totalsand ,	
	totalsilt,
	totalclay,
	vfsand,	
	dbthirdbar,	
	kwfact ,
	hz_rowid,
	landunit

	FROM #horizon4 WHERE hz_rowid = 1






CREATE TABLE #second2
    (
        areasymbol        VARCHAR(255),
        musym            VARCHAR(20),
        mukey            INT,
        muname           VARCHAR(250),
		cokey            INT,
		slope_r          INT,
		slopelenusle_r   INT,
		tfact			 INT,
        major_mu_pct_sum SMALLINT,
		slopelen		 INT, 
		slopelen_palouse INT, 
		palouse		     INT,
		slope_length     INT,
        datestamp        VARCHAR(32)
    )

INSERT INTO #second2
    (
        areasymbol ,
        musym  ,
        mukey  ,
        muname ,
		cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse		    ,
		slope_length     ,
        datestamp       
    )

 SELECT areasymbol ,
        musym  ,
        mukey  ,
        muname ,
		cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse		    ,
		CASE WHEN palouse = 0 THEN slopelen WHEN palouse = 1 then slopelen_palouse else slopelen END AS slope_length,
        datestamp
 FROM #main4

 CREATE TABLE #third2
    (
        areasymbol        VARCHAR(255),
        musym            VARCHAR(20),
        mukey            INT,
        muname           VARCHAR(250),
		cokey            INT,
		slope_r          INT,
		slopelenusle_r   INT,
		tfact			 INT,
        major_mu_pct_sum SMALLINT,
		slopelen		 INT, 
		slopelen_palouse INT, 
		palouse		     INT,
		slope_length     INT,
		length_fact		 REAL,
		sine_theta		 REAL,
        datestamp        VARCHAR(32)
    )

INSERT INTO #third2
    (
		areasymbol ,
        musym  ,
        mukey  ,
        muname ,
		cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse,
		slope_length,
		length_fact,
		sine_theta ,
		datestamp 
    )

 SELECT areasymbol ,
        musym  ,
        mukey  ,
        muname ,
		cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse,
		slope_length,
		CASE WHEN slope_r IS NULL THEN NULL
			 WHEN  slope_r < 1 THEN (slope_length/72.6) *0.2 
			 WHEN  slope_r >=1 AND slope_r < 3 THEN  (slope_length/72.6)*0.3 
			 WHEN  slope_r >=3 AND slope_r < 4.5 THEN  (slope_length/72.6)*0.4 
			 WHEN  slope_r >= 4.5 THEN  (slope_length/72.6)*0.5 ELSE 0 END AS length_fact,
			SIN( ATAN (CAST(slope_r AS decimal(6, 2))/100)) AS sine_theta,
		datestamp 
FROM #second2

 CREATE TABLE #fourth3
    (
        areasymbol         VARCHAR(255),
        musym            VARCHAR(20),
        mukey            INT,
        muname           VARCHAR(250),
		cokey            INT,
		slope_r          INT,
		slopelenusle_r   INT,
		tfact			 INT,
        major_mu_pct_sum SMALLINT,
		slopelen		 INT, 
		slopelen_palouse INT, 
		palouse		     INT,
		slope_length     INT,
		length_fact		 REAL,
		sine_theta		 REAL,
		steep_fact		 REAL,
        datestamp        VARCHAR(32)
    )

INSERT INTO #fourth3
    (
		areasymbol ,
        musym  ,
        mukey  ,
        muname ,
		cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse,
		slope_length,
		length_fact,
		sine_theta ,
		steep_fact,
		datestamp 
    )

SELECT  areasymbol,
        musym  ,
        mukey  ,
        muname ,
		cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse		    ,
		slope_length     ,
		length_fact,
		sine_theta,
		(65.41)*(sine_theta*2)+(4.56*sine_theta)+0.065 AS steep_fact,
        datestamp   
FROM #third2

 CREATE TABLE #fifth
    (
        areasymbol        VARCHAR(255),
        musym            VARCHAR(20),
        mukey            INT,
        muname           VARCHAR(250),
		cokey            INT,
		slope_r          INT,
		slopelenusle_r   INT,
		tfact			 INT,
        major_mu_pct_sum SMALLINT,
		slopelen		 INT, 
		slopelen_palouse INT, 
		palouse		     INT,
		slope_length     INT,
		length_fact		 REAL,
		sine_theta		 REAL,
		steep_fact		 REAL,
		ls_factor		 REAL,
        datestamp        VARCHAR(32)
    )

INSERT INTO #fifth
    (
		areasymbol,
        musym  ,
        mukey  ,
        muname ,
		cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse,
		slope_length,
		length_fact,
		sine_theta ,
		steep_fact,
		ls_factor,
		datestamp 
    )



SELECT	areasymbol ,
        musym  ,
        mukey  ,
        muname ,
		cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse,
		slope_length,
		length_fact,
		sine_theta ,
		steep_fact,
		(length_fact)*(steep_fact)AS ls_factor,
		datestamp 
FROM #fourth3

--R Factor Intersect
CREATE TABLE #sviaoirfactor
    ( rolyid INT IDENTITY (1,1),
    aoiid INT,
    landunit CHAR(20),
    r_factor REAL,
    geom GEOMETRY )

INSERT INTO #sviaoirfactor (aoiid, landunit, r_factor, geom)
SELECT A.aoiid, A.landunit, r_factor,--M.mukey,
   B.geom.STIntersection(A.aoigeom ) AS soilgeom
    FROM [sdm_spatial].[dbo].[r_factor] B, #sviaoitable A
    WHERE B.geom.STIntersects(A.aoigeom) = 1

--Use the R-Factor AOI to intersect with mupolygon
CREATE TABLE #sviaoirfactorjoin3
    ( aoiid INT, landunit  CHAR(20),
	
	rmolyid INT IDENTITY (1,1),
    mukey INT,
    r_factor REAL,
    soilgeom GEOMETRY )

INSERT INTO #sviaoirfactorjoin3 (aoiid, landunit, mukey,  r_factor, soilgeom)
SELECT M.aoiid, M.landunit,
  M.mukey
, A.[r_factor] AS r_factor
, M.soilgeom.STIntersection(A.geom ) AS soilgeom
FROM #sviaoisoils M, #sviaoirfactor A
WHERE soilgeom.STIntersects(A.geom) = 1 ;


 CREATE TABLE #final22
   (
		landunit  VARCHAR(255),
        areasymbol        VARCHAR(255),
        musym            VARCHAR(20),
        mukey            INT,
        muname           VARCHAR(250),
		cokey            INT,
		slope_r          INT,
		slopelenusle_r   INT,
		tfact			 INT,
        major_mu_pct_sum SMALLINT,
		slopelen		 INT, 
		slopelen_palouse INT, 
		palouse		     INT,
		slope_length     INT,
		length_fact		 REAL,
		sine_theta		 REAL,
		steep_fact		 REAL,
		ls_factor		 REAL,
      	r_factor		 REAL,
		kwfact			 REAL,
		taxorder		VARCHAR(250),
		erosion_index	 REAL,
		water_sensitive	 REAL,
		datestamp VARCHAR(32)
    )

INSERT INTO #final22
  (
	landunit,
	areasymbol,
        musym  ,
        mukey  ,
        muname ,
	cokey  ,
	slope_r   ,
	slopelenusle_r,
	tfact		,
        major_mu_pct_sum,
	slopelen	, 
	slopelen_palouse , 
	palouse,
	slope_length,
	length_fact,
	sine_theta ,
	steep_fact,
	ls_factor,
	r_factor,
	kwfact,
	taxorder,	
	erosion_index,
	water_sensitive,	
	datestamp 
    )

SELECT rf.landunit, 	
	    f.areasymbol AS areasymbol,
	    musym  ,
        f.mukey  ,
        f.muname ,
		f.cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse,
		slope_length,
		length_fact,
		sine_theta ,
		steep_fact,
		ls_factor,
		r_factor , 
		kwfact		,  
		taxorder	,  
		((r_factor)*(kwfact)*(ls_factor))/tfact AS erosion_index,
		((r_factor)*(kwfact)*(ls_factor)) water_sensitive,
		datestamp 
FROM #fifth AS f
INNER JOIN #sviaoirfactorjoin3 AS rf ON rf.mukey=f.mukey
INNER JOIN #horizon5 AS h ON h.cokey=f.cokey

GROUP BY rf.landunit,	f.areasymbol ,
	
        musym  ,
        f.mukey  ,
        f.muname ,
		f.cokey  ,
		slope_r   ,
		slopelenusle_r,
		tfact		,
        major_mu_pct_sum,
		slopelen	, 
		slopelen_palouse , 
		palouse,
		slope_length,
		length_fact,
		sine_theta ,
		steep_fact,
		ls_factor,
		r_factor , 
		kwfact		,  
		taxorder	, 
		thickness2,
		texture ,
		lieutex,
		om,
		ksat,
		totalsand ,	
		totalsilt,
		totalclay,
		vfsand,	
		dbthirdbar,	
		datestamp 
ORDER BY f.areasymbol, muname, f.mukey, f.cokey  


SELECT 	landunit,
	areasymbol,
        musym  ,
        mukey  ,
        muname ,
	cokey  ,
	slope_r   ,
	slopelenusle_r,
	tfact		,
        major_mu_pct_sum,
	slopelen	, 
	slopelen_palouse , 
	palouse,
	slope_length,
	length_fact,
	sine_theta ,
	steep_fact,
	ls_factor,
	r_factor,
	kwfact,
	taxorder,	
	erosion_index,
	water_sensitive,
	CASE WHEN water_sensitive BETWEEN	0.000281452 AND 5.990581464  THEN 1
	 WHEN water_sensitive BETWEEN		5.990581465 AND 28.66695351  THEN 2
	 WHEN  water_sensitive BETWEEN		28.66695352 AND 114.5087057 THEN 3
	 WHEN water_sensitive BETWEEN		114.5087058 AND 439.4639675 THEN 4
	 WHEN water_sensitive BETWEEN	    439.4639676 AND 1669.587067 THEN 5 
	 WHEN water_sensitive BETWEEN	    1669.587068 AND 6326.236816 THEN 6
	 ELSE 0 
	END AS class_water_sensitive,
	datestamp 
	FROM #final22
	
 DROP TABLE IF EXISTS #main4;
 DROP TABLE IF EXISTS #second2;
 DROP TABLE IF EXISTS #third2;
 DROP TABLE IF EXISTS #fourth3;
 DROP TABLE IF EXISTS #sviaoirfactor ;
 DROP TABLE IF EXISTS #fifth;
 DROP TABLE IF EXISTS #horizon3;
 DROP TABLE IF EXISTS #horizon4;
 DROP TABLE IF EXISTS #horizon5;
DROP TABLE IF EXISTS #sviaoirfactorjoin3;