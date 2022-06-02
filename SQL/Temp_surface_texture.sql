--# Get K factor value for surface horizon
--Define the area
DROP TABLE IF EXISTS #horizon3;
DROP TABLE IF EXISTS #horizon4;
DECLARE @area VARCHAR(20);
DECLARE @area_type INT ;
DECLARE @major INT;
DECLARE @InRangeTop INT;
DECLARE @InRangeBot INT;

-- Soil Data Access
/*~DeclareChar(@area,20)~  -- Used for Soil Data Access
~DeclareINT(@area_type)~
*/
--~DeclareINT(@area_type)~ 
-- End soil data access

SELECT @area= 'WI003'; --Enter State Abbreviation or Soil Survey Area i.e. WI or WI025
SELECT @area_type = LEN (@area); --determines number of characters of area 2-State, 5- Soil Survey Area
SELECT @InRangeTop = 0;
SELECT @InRangeBot = 15;

CREATE TABLE #horizon3
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
		hzname		VARCHAR(10),
		desgnmaster	VARCHAR(10),
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
		kwfact		REAL

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
	kwfact 
    )

SELECT l.areasymbol, muname, mu.mukey, compname, c1.cokey,  compkind, ch1.chkey, CASE WHEN hzdept_r IS NULL THEN @InRangeTop ELSE hzdept_r END AS hzdept_r,
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
END AS kwfact
FROM  sacatalog AS  sc
 INNER JOIN legend  AS l ON l.areasymbol = sc.areasymbol
 INNER JOIN  mapunit AS mu ON mu.lkey = l.lkey AND  CASE WHEN @area_type = 2 THEN LEFT (l.areasymbol, 2) ELSE l.areasymbol END = @area
INNER JOIN  component AS c1 ON c1.mukey = mu.mukey AND majcompflag = 'Yes'
AND c1.cokey =
(SELECT TOP 1 c2.cokey FROM component AS c2 
INNER JOIN mapunit AS mu2 ON c2.mukey=mu2.mukey AND mu2.mukey=mu.mukey AND majcompflag = 'Yes' ORDER BY CASE WHEN compkind = 'Miscellaneous area' THEN 2 ELSE 1 END ASC,  c2.comppct_r DESC, c2.cokey ) 
--Dominant Component - If Misc is first name component use second component
LEFT OUTER JOIN chorizon AS ch1 ON ch1.cokey=c1.cokey 
ORDER BY areasymbol, musym, muname, mu.mukey, comppct_r DESC, cokey,  hzdept_r, hzdepb_r


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
		hzname		VARCHAR(10),
		desgnmaster	VARCHAR(10),
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
		hz_rowid	SMALLINT

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
	hz_rowid	
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
		hzdept_r ASC, hzdepb_r ASC, chkey ASC) AS hz_rowid	
FROM #horizon3 WHERE hzdept_r BETWEEN  @InRangeTop AND @InRangeBot  ORDER BY muname 


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
	hz_rowid	

	FROM #horizon4 WHERE hz_rowid = 1

DROP TABLE IF EXISTS #horizon3;
DROP TABLE IF EXISTS #horizon4;
--WHERE hzdepb_r > @InRangeTop AND hzdept_r < @InRangeBot 

--AND (((ch1.hzdept_r)=(SELECT Min(chorizon.hzdept_r) AS MIN_hor_depth_r
--FROM chorizon LEFT JOIN chtexturegrp ON chorizon.chkey = chtexturegrp.chkey 
--WHERE chtexturegrp.texture Not In ('SPM','HPM', 'MPM') AND chtexturegrp.rvindicator='yes' AND c1.cokey = chorizon.cokey )))



