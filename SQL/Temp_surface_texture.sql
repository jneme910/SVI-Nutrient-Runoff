--# Get K factor value for surface horizon
--Define the area
DROP TABLE IF EXISTS #horizon;

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

CREATE TABLE #horizon
    (
		areasymbol	VARCHAR(10),
		muname		VARCHAR(250),
		compname	VARCHAR(250),
		cokey		INT, 
		chkey		INT,
		hzdept_r	SMALLINT, 
		hzdepb_r	SMALLINT, 
		thickness	SMALLINT, 
		hzname		VARCHAR(10),
		desgnmaster	VARCHAR(10),
		kwfact		REAL, 
		taxorder	VARCHAR(40),
		thickness2	SMALLINT, 
		hz_rowid 	SMALLINT

    )

INSERT INTO #horizon
    (
		areasymbol	,
		muname		,
		compname	,
		cokey		, 
		chkey		,
		hzdept_r	,
		hzdepb_r	,
		thickness	, 
		hzname		,
		desgnmaster	,
		kwfact		,
		taxorder	,
		thickness2	,
		hz_rowid 	
    )

SELECT l.areasymbol, muname, compname, c1.cokey, ch1.chkey, hzdept_r, hzdepb_r,  CASE WHEN hzdepb_r IS NULL THEN NULL
WHEN hzdept_r IS NULL THEN NULL
WHEN hzdept_r > hzdepb_r THEN NULL
WHEN hzdept_r = hzdepb_r THEN NULL ELSE
CASE WHEN hzdepb_r > @InRangeBot THEN @InRangeBot ELSE hzdepb_r END END - hzdept_r AS thickness,
hzname, desgnmaster, --lieutex ,
kwfact, taxorder, 
CASE WHEN hzdept_r > @InRangeBot THEN 0
WHEN hzdepb_r < @InRangeTop THEN 0
WHEN hzdepb_r <= @InRangeBot THEN hzdepb_r  WHEN hzdepb_r > @InRangeBot and hzdept_r < @InRangeBot THEN @InRangeBot ELSE @InRangeTop END-CASE WHEN hzdepb_r < @InRangeTop THEN 0
WHEN hzdept_r >@InRangeBot THEN 0 
WHEN hzdepb_r >= @InRangeTop AND hzdept_r < @InRangeTop THEN @InRangeTop 
WHEN hzdept_r < @InRangeTop THEN 0
WHEN hzdept_r < @InRangeBot then hzdept_r ELSE @InRangeTop END AS thickness2,

ROW_NUMBER() OVER(PARTITION BY c1.cokey ORDER BY hzdept_r ASC, hzdepb_r ASC, ch1.chkey ASC) AS hz_rowid


FROM  sacatalog AS  sc
 INNER JOIN legend  AS l ON l.areasymbol = sc.areasymbol
 INNER JOIN  mapunit AS mu ON mu.lkey = l.lkey AND  CASE WHEN @area_type = 2 THEN LEFT (l.areasymbol, 2) ELSE l.areasymbol END = @area
INNER JOIN  component AS c1 ON c1.mukey = mu.mukey AND majcompflag = 'Yes'
AND c1.cokey =
(SELECT TOP 1 c2.cokey FROM component AS c2 
INNER JOIN mapunit AS mu2 ON c1.mukey=mu2.mukey AND c2.mukey=mu.mukey ORDER BY c1.comppct_r DESC, c1.cokey ) 

INNER JOIN chorizon AS ch1 ON ch1.cokey=c1.cokey 

AND hzdepb_r > @InRangeTop AND hzdept_r < @InRangeBot 
AND (((CASE WHEN hzdept_r > @InRangeBot THEN 0
WHEN hzdepb_r < @InRangeTop THEN 0
WHEN hzdepb_r <= @InRangeBot THEN hzdepb_r  WHEN hzdepb_r > @InRangeBot and hzdept_r < @InRangeBot THEN @InRangeBot ELSE @InRangeTop END-CASE WHEN hzdepb_r < @InRangeTop THEN 0
WHEN hzdept_r >@InRangeBot THEN 0 
WHEN hzdepb_r >= @InRangeTop AND hzdept_r < @InRangeTop THEN @InRangeTop 
WHEN hzdept_r < @InRangeTop THEN 0
WHEN hzdept_r < @InRangeBot then hzdept_r ELSE @InRangeTop END  )


=(SELECT MAX(CASE WHEN hzdept_r > @InRangeBot THEN 0
WHEN hzdepb_r < @InRangeTop THEN 0
WHEN hzdepb_r <= @InRangeBot THEN hzdepb_r  WHEN hzdepb_r > @InRangeBot and hzdept_r < @InRangeBot THEN @InRangeBot ELSE @InRangeTop END-CASE WHEN hzdepb_r < @InRangeTop THEN 0
WHEN hzdept_r >@InRangeBot THEN 0 
WHEN hzdepb_r >= @InRangeTop AND hzdept_r < @InRangeTop THEN @InRangeTop 
WHEN hzdept_r < @InRangeTop THEN 0
WHEN hzdept_r < @InRangeBot then hzdept_r ELSE @InRangeTop END ) AS MinOfhzdept_r
FROM chorizon 
INNER JOIN chtexturegrp AS cht2 ON chorizon.chkey = cht2.chkey AND chorizon.hzname NOT LIKE '%O%'
AND (CASE WHEN cht2.texture Not In ('SPM','HPM', 'MPM') THEN 1
WHEN chorizon.hzname	LIKE '%O%' THEN 2
WHEN chorizon.desgnmaster LIKE '%O%' THEN 2
END = 1

AND cht2.rvindicator='Yes' AND c1.cokey = chorizon.cokey ))))
ORDER BY areasymbol, musym, muname, mu.mukey, comppct_r DESC, cokey,  hzdept_r, hzdepb_r



SELECT areasymbol	,
		muname		,
		compname	,
		cokey		, 
		chkey		,
		hzdept_r	,
		hzdepb_r	,
		thickness	, 
		hzname		,
		desgnmaster	,
		kwfact		,
		taxorder	,
		thickness2	,
		hz_rowid 	
FROM #horizon WHERE hz_rowid = 1

