USE sdmOnline;
DROP TABLE IF EXISTS #main3;
DROP TABLE IF EXISTS #second2;
DROP TABLE IF EXISTS #third2;
DROP TABLE IF EXISTS #fourth3;
DROP TABLE IF EXISTS #r_factor3 ;
DROP TABLE IF EXISTS #fifth;
DROP TABLE IF EXISTS #horizon3;
DROP TABLE IF EXISTS #horizon4;
DROP TABLE IF EXISTS #horizon5;
--Define the area
DECLARE @area VARCHAR(20);
DECLARE @area_type INT ;
DECLARE @InRangeTop INT;
DECLARE @InRangeBot INT;
DECLARE @major INT;


-- Soil Data Access
/*
~DeclareChar(@area,20)~  -- Used for Soil Data Access
~DeclareINT(@area_type)~
~DeclareINT(@InRangeTop)~
~DeclareINT(@InRangeBot)~
~DeclareINT(@major)~
*/
-- End soil data access

SELECT @area= 'WI003'; --Enter State Abbreviation or Soil Survey Area i.e. WI or WI025
SELECT @area_type = LEN (@area); --determines number of characters of area 2-State, 5- Soil Survey Area
SELECT @major = 0; -- Enter 0 for major component, enter 1 for all components
SELECT @InRangeTop = 0;
SELECT @InRangeBot = 15;

CREATE TABLE #main3
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
        datestamp        VARCHAR(32)
    )

INSERT INTO #main3
    (
        areasymbol,
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
        datestamp
    )

SELECT sc.areasymbol, mu.mukey, muname,  c.cokey, slope_r, slopelenusle_r, tfact,  

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


				CONCAT([sc].[areasymbol], ' ', FORMAT([sc].[saverest], 'dd-MM-yy')) AS datestamp
 FROM  sacatalog AS  sc
 INNER JOIN legend  AS l ON l.areasymbol = sc.areasymbol
 INNER JOIN  mapunit AS mu ON mu.lkey = l.lkey --AND l.areasymbol = 'US' 
 --AND CASE WHEN @area_type = 2 THEN LEFT (l.areasymbol, 2) ELSE l.areasymbol END = @area
 INNER JOIN  component AS c ON c.mukey = mu.mukey AND majcompflag = 'Yes'
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
END AS kwfact
FROM #main3 AS m 
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
		hz_rowid	SMALLINT

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
	hz_rowid	
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
	hz_rowid	

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
 FROM #main3

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

CREATE TABLE #r_factor3 
(rfid INT IDENTITY (1,1),
areasymbol VARCHAR(10),
r_factor float
 CONSTRAINT pk_rf_index2 PRIMARY KEY CLUSTERED (rfid ))
	  

INSERT INTO #r_factor3 SELECT	'AR023'	,	286.33	;
INSERT INTO #r_factor3 SELECT	'OK007' 	,	124.66	;
INSERT INTO #r_factor3 SELECT	'TX155' 	,	167.02	;
INSERT INTO #r_factor3 SELECT	'NY043' 	,	72.21	;
INSERT INTO #r_factor3 SELECT	'MN095' 	,	92.53	;
INSERT INTO #r_factor3 SELECT	'AR141' 	,	291.45	;
INSERT INTO #r_factor3 SELECT	'MO186' 	,	220.63	;
INSERT INTO #r_factor3 SELECT	'AS630'	,	428.9349976	;
INSERT INTO #r_factor3 SELECT	'FM931'	,	620.2249756	;
INSERT INTO #r_factor3 SELECT	'FM932'	,	620.2249756	;
INSERT INTO #r_factor3 SELECT	'GU640'	,	295.6950073	;
INSERT INTO #r_factor3 SELECT	'HI701'	,	836.6149902	;
INSERT INTO #r_factor3 SELECT	'HI801'	,	836.6149902	;
INSERT INTO #r_factor3 SELECT	'HI950'	,	616.572998	;
INSERT INTO #r_factor3 SELECT	'HI960'	,	620.2369995	;
INSERT INTO #r_factor3 SELECT	'HI970'	,	84.4184036	;
INSERT INTO #r_factor3 SELECT	'HI980'	,	547.0750122	;
INSERT INTO #r_factor3 SELECT	'HI990'	,	523.9689941	;
INSERT INTO #r_factor3 SELECT	'MP645'	,	180.8970032	;
INSERT INTO #r_factor3 SELECT	'OR648'	,	6.793129137	;
INSERT INTO #r_factor3 SELECT	'PR682'	,	410.3441453	;
INSERT INTO #r_factor3 SELECT	'PR684'	,	463.6619263	;
INSERT INTO #r_factor3 SELECT	'PR686'	,	379.5918326	;
INSERT INTO #r_factor3 SELECT	'PR688'	,	256.8803082	;
INSERT INTO #r_factor3 SELECT	'PR689'	,	363.3534615	;
INSERT INTO #r_factor3 SELECT	'PR700'	,	554.7115752	;
INSERT INTO #r_factor3 SELECT	'PR787'	,	246.38249	;
INSERT INTO #r_factor3 SELECT	'PW935'	,	455.9890137	;
INSERT INTO #r_factor3 SELECT	'AK600'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK605'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK610'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK612'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK615'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK621'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK622'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK623'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK625'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK630'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK631'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK635'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK636'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK637'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK638'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK639'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK640'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK641'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK642'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK643'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK644'	,	38.75647545	;
INSERT INTO #r_factor3 SELECT	'AK645'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK646'	,	41.34024048	;
INSERT INTO #r_factor3 SELECT	'AK649'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK650'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK651'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK652'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK653'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK654'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK655'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK656'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK657'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK658'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK659'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK683'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK684'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK685'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK686'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK692'	,	34.4502004	;
INSERT INTO #r_factor3 SELECT	'AK693'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK700'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK701'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK702'	,	41.34024048	;
INSERT INTO #r_factor3 SELECT	'AK703'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK704'	,	38.75647545	;
INSERT INTO #r_factor3 SELECT	'AK705'	,	38.75647545	;
INSERT INTO #r_factor3 SELECT	'AK706'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK707'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK708'	,	41.34024048	;
INSERT INTO #r_factor3 SELECT	'AK709'	,	34.4502004	;
INSERT INTO #r_factor3 SELECT	'AK710'	,	44.2931148	;
INSERT INTO #r_factor3 SELECT	'AK711'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK712'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK713'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK714'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK715'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK716'	,	41.34024048	;
INSERT INTO #r_factor3 SELECT	'AK717'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK718'	,	50.70029493	;
INSERT INTO #r_factor3 SELECT	'AK719'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK720'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK721'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK722'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK723'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK724'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK725'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK726'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK727'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK728'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK729'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK730'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK731'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK732'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK733'	,	43.0627505	;
INSERT INTO #r_factor3 SELECT	'AK734'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK735'	,	41.34024048	;
INSERT INTO #r_factor3 SELECT	'AK736'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK737'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK738'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK739'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK740'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK741'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK742'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK743'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK744'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK745'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK746'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK747'	,	41.34024048	;
INSERT INTO #r_factor3 SELECT	'AK748'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK749'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK750'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK751'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK752'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK753'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK754'	,	38.75647545	;
INSERT INTO #r_factor3 SELECT	'AK755'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK756'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK757'	,	38.75647545	;
INSERT INTO #r_factor3 SELECT	'AK758'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK759'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK760'	,	34.4502004	;
INSERT INTO #r_factor3 SELECT	'AK761'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK762'	,	34.4502004	;
INSERT INTO #r_factor3 SELECT	'AK763'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK764'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK765'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK766'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK767'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK768'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK769'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK770'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK771'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK772'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK773'	,	47.36902555	;
INSERT INTO #r_factor3 SELECT	'AK774'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK775'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK776'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK777'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK778'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK779'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK781'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK782'	,	33.43695921	;
INSERT INTO #r_factor3 SELECT	'AK783'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK784'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK785'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK786'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK787'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK788'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK789'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK790'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK791'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK792'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK793'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK794'	,	38.75647545	;
INSERT INTO #r_factor3 SELECT	'AK795'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'AK796'	,	25.8376503	;
INSERT INTO #r_factor3 SELECT	'AK797'	,	51.6753006	;
INSERT INTO #r_factor3 SELECT	'149A'	,	189	;
INSERT INTO #r_factor3 SELECT	'OR648'	,	4.05;
INSERT INTO #r_factor3 SELECT	'AR023'	,	286.33;
INSERT INTO #r_factor3 SELECT	'OK007'	,	124.66;
INSERT INTO #r_factor3 SELECT	'TX155'	,	167.02;
INSERT INTO #r_factor3 SELECT	'NY043'	,	72.21;
INSERT INTO #r_factor3 SELECT	'MN095'	,	92.53;
INSERT INTO #r_factor3 SELECT	'AR141'	,	291.45;
INSERT INTO #r_factor3 SELECT	'MO186'	,	220.63;
INSERT INTO #r_factor3 SELECT	 'DE100'	,	189	;
INSERT INTO #r_factor3 SELECT	 'ID672'	,	9.6	;
INSERT INTO #r_factor3 SELECT	 'ID672'	,	9.6	;
INSERT INTO #r_factor3 SELECT	 'ID661'	,	10	;
INSERT INTO #r_factor3 SELECT	 'WA671'	,	15	;
INSERT INTO #r_factor3 SELECT	 'AR019'	,	331.6	;
INSERT INTO #r_factor3 SELECT	'AR059'	,	331.6	;
INSERT INTO #r_factor3 SELECT	'Interps'	,	113.4	;
INSERT INTO #r_factor3 SELECT	 'NPS'	,	113.4	;
INSERT INTO #r_factor3 SELECT	'PA055'	,	113.4	;
INSERT INTO #r_factor3 SELECT	'PA057'	,	113.4	;
INSERT INTO #r_factor3 SELECT	'SS0061'	,	28	;
INSERT INTO #r_factor3 SELECT	 'FTIG'	,	113.44	;
INSERT INTO #r_factor3 SELECT	'WV605'	,	105	;
INSERT INTO #r_factor3 SELECT	'qWV605'	,	105	;
INSERT INTO #r_factor3 SELECT	 'AL001'	,	391.28	;
INSERT INTO #r_factor3 SELECT	'AL003'	,	601.64	;
INSERT INTO #r_factor3 SELECT	'AL005'	,	391.36	;
INSERT INTO #r_factor3 SELECT	'AL007'	,	382.29	;
INSERT INTO #r_factor3 SELECT	'AL009'	,	326.28	;
INSERT INTO #r_factor3 SELECT	'AL011'	,	386.28	;
INSERT INTO #r_factor3 SELECT	'AL013'	,	443.39	;
INSERT INTO #r_factor3 SELECT	'AL015'	,	320.92	;
INSERT INTO #r_factor3 SELECT	'AL017'	,	346.33	;
INSERT INTO #r_factor3 SELECT	'AL019'	,	295.27	;
INSERT INTO #r_factor3 SELECT	'AL021'	,	379.88	;
INSERT INTO #r_factor3 SELECT	'AL023'	,	464.46	;
INSERT INTO #r_factor3 SELECT	'AL025'	,	480.56	;
INSERT INTO #r_factor3 SELECT	'AL027'	,	344.17	;
INSERT INTO #r_factor3 SELECT	'AL029'	,	318.2	;
INSERT INTO #r_factor3 SELECT	'AL031'	,	450.44	;
INSERT INTO #r_factor3 SELECT	'AL033'	,	293.2	;
INSERT INTO #r_factor3 SELECT	'AL035'	,	475.5	;
INSERT INTO #r_factor3 SELECT	'AL037'	,	364.11	;
INSERT INTO #r_factor3 SELECT	'AL039'	,	481.65	;
INSERT INTO #r_factor3 SELECT	'AL041'	,	433	;
INSERT INTO #r_factor3 SELECT	'AL043'	,	321.21	;
INSERT INTO #r_factor3 SELECT	'AL045'	,	430.74	;
INSERT INTO #r_factor3 SELECT	'AL047'	,	417.9	;
INSERT INTO #r_factor3 SELECT	'AL049'	,	281.77	;
INSERT INTO #r_factor3 SELECT	'AL051'	,	375.18	;
INSERT INTO #r_factor3 SELECT	'AL053'	,	514.23	;
INSERT INTO #r_factor3 SELECT	'AL055'	,	310.75	;
INSERT INTO #r_factor3 SELECT	'AL057'	,	351.74	;
INSERT INTO #r_factor3 SELECT	'AL059'	,	308.5	;
INSERT INTO #r_factor3 SELECT	'AL061'	,	476.99	;
INSERT INTO #r_factor3 SELECT	'AL063'	,	401.33	;
INSERT INTO #r_factor3 SELECT	'AL065'	,	402.54	;
INSERT INTO #r_factor3 SELECT	'AL067'	,	409.25	;
INSERT INTO #r_factor3 SELECT	'AL069'	,	441.53	;
INSERT INTO #r_factor3 SELECT	'AL071'	,	265.95	;
INSERT INTO #r_factor3 SELECT	'AL073'	,	354.2	;
INSERT INTO #r_factor3 SELECT	'AL075'	,	349.57	;
INSERT INTO #r_factor3 SELECT	'AL077'	,	281.54	;
INSERT INTO #r_factor3 SELECT	'AL079'	,	299.99	;
INSERT INTO #r_factor3 SELECT	'AL081'	,	355.1	;
INSERT INTO #r_factor3 SELECT	'AL083'	,	276.9	;
INSERT INTO #r_factor3 SELECT	'AL085'	,	412.08	;
INSERT INTO #r_factor3 SELECT	'AL087'	,	371.76	;
INSERT INTO #r_factor3 SELECT	'AL089'	,	272.76	;
INSERT INTO #r_factor3 SELECT	'AL091'	,	440.72	;
INSERT INTO #r_factor3 SELECT	'AL093'	,	329.24	;
INSERT INTO #r_factor3 SELECT	'AL095'	,	295.41	;
INSERT INTO #r_factor3 SELECT	'AL097'	,	609.62	;
INSERT INTO #r_factor3 SELECT	'AL099'	,	475.54	;
INSERT INTO #r_factor3 SELECT	'AL101'	,	393.85	;
INSERT INTO #r_factor3 SELECT	'AL103'	,	298.42	;
INSERT INTO #r_factor3 SELECT	'AL105'	,	403.67	;
INSERT INTO #r_factor3 SELECT	'AL107'	,	377.15	;
INSERT INTO #r_factor3 SELECT	'AL109'	,	412.45	;
INSERT INTO #r_factor3 SELECT	'AL111'	,	333.13	;
INSERT INTO #r_factor3 SELECT	'AL113'	,	362.78	;
INSERT INTO #r_factor3 SELECT	'AL115'	,	336.27	;
INSERT INTO #r_factor3 SELECT	'AL117'	,	361.49	;
INSERT INTO #r_factor3 SELECT	'AL119'	,	421.83	;
INSERT INTO #r_factor3 SELECT	'AL121'	,	346.8	;
INSERT INTO #r_factor3 SELECT	'AL123'	,	356.33	;
INSERT INTO #r_factor3 SELECT	'AL125'	,	373.48	;
INSERT INTO #r_factor3 SELECT	'AL127'	,	345.69	;
INSERT INTO #r_factor3 SELECT	'AL129'	,	518.81	;
INSERT INTO #r_factor3 SELECT	'AL131'	,	447	;
INSERT INTO #r_factor3 SELECT	'AL133'	,	326.09	;
INSERT INTO #r_factor3 SELECT	'AR001'	,	337.81	;
INSERT INTO #r_factor3 SELECT	'AR003'	,	374.22	;
INSERT INTO #r_factor3 SELECT	'AR005'	,	252.92	;
INSERT INTO #r_factor3 SELECT	'AR007'	,	261.66	;
INSERT INTO #r_factor3 SELECT	'AR009'	,	253.79	;
INSERT INTO #r_factor3 SELECT	'AR011'	,	360.52	;
INSERT INTO #r_factor3 SELECT	'AR015'	,	256.27	;
INSERT INTO #r_factor3 SELECT	'AR017'	,	372.77	;
INSERT INTO #r_factor3 SELECT	'AR021'	,	263.66	;
INSERT INTO #r_factor3 SELECT	'AR025'	,	348.04	;
INSERT INTO #r_factor3 SELECT	'AR027'	,	355.71	;
INSERT INTO #r_factor3 SELECT	'AR029'	,	296.85	;
INSERT INTO #r_factor3 SELECT	'AR031'	,	277.5	;
INSERT INTO #r_factor3 SELECT	'AR033'	,	279.51	;
INSERT INTO #r_factor3 SELECT	'AR035'	,	293.61	;
INSERT INTO #r_factor3 SELECT	'AR037'	,	294.32	;
INSERT INTO #r_factor3 SELECT	'AR041'	,	353.53	;
INSERT INTO #r_factor3 SELECT	'AR043'	,	358.92	;
INSERT INTO #r_factor3 SELECT	'AR045'	,	302.36	;
INSERT INTO #r_factor3 SELECT	'AR047'	,	283.09	;
INSERT INTO #r_factor3 SELECT	'AR049'	,	253.23	;
INSERT INTO #r_factor3 SELECT	'AR051'	,	316.09	;
INSERT INTO #r_factor3 SELECT	'AR053'	,	334.3	;
INSERT INTO #r_factor3 SELECT	'AR055'	,	270.46	;
INSERT INTO #r_factor3 SELECT	'AR057'	,	336.85	;
INSERT INTO #r_factor3 SELECT	'AR061'	,	321.11	;
INSERT INTO #r_factor3 SELECT	'AR063'	,	279.87	;
INSERT INTO #r_factor3 SELECT	'AR065'	,	263.23	;
INSERT INTO #r_factor3 SELECT	'AR067'	,	285.74	;
INSERT INTO #r_factor3 SELECT	'AR071'	,	282.08	;
INSERT INTO #r_factor3 SELECT	'AR075'	,	270.53	;
INSERT INTO #r_factor3 SELECT	'AR077'	,	310.86	;
INSERT INTO #r_factor3 SELECT	'AR083'	,	294.44	;
INSERT INTO #r_factor3 SELECT	'AR087'	,	267.08	;
INSERT INTO #r_factor3 SELECT	'AR089'	,	253.09	;
INSERT INTO #r_factor3 SELECT	'AR093'	,	277.58	;
INSERT INTO #r_factor3 SELECT	'AR095'	,	319.52	;
INSERT INTO #r_factor3 SELECT	'AR097'	,	311.08	;
INSERT INTO #r_factor3 SELECT	'AR099'	,	343.89	;
INSERT INTO #r_factor3 SELECT	'AR101'	,	267.84	;
INSERT INTO #r_factor3 SELECT	'AR103'	,	350.57	;
INSERT INTO #r_factor3 SELECT	'AR105'	,	305.68	;
INSERT INTO #r_factor3 SELECT	'AR107'	,	328.43	;
INSERT INTO #r_factor3 SELECT	'AR109'	,	323.09	;
INSERT INTO #r_factor3 SELECT	'AR111'	,	284.78	;
INSERT INTO #r_factor3 SELECT	'AR113'	,	307.63	;
INSERT INTO #r_factor3 SELECT	'AR115'	,	288.19	;
INSERT INTO #r_factor3 SELECT	'AR119'	,	316.6	;
INSERT INTO #r_factor3 SELECT	'AR121'	,	260.86	;
INSERT INTO #r_factor3 SELECT	'AR123'	,	301.53	;
INSERT INTO #r_factor3 SELECT	'AR125'	,	319	;
INSERT INTO #r_factor3 SELECT	'AR127'	,	300.55	;
INSERT INTO #r_factor3 SELECT	'AR129'	,	267.46	;
INSERT INTO #r_factor3 SELECT	'AR131'	,	291.35	;
INSERT INTO #r_factor3 SELECT	'AR133'	,	320.82	;
INSERT INTO #r_factor3 SELECT	'AR135'	,	264.26	;
INSERT INTO #r_factor3 SELECT	'AR137'	,	272.27	;
INSERT INTO #r_factor3 SELECT	'AR139'	,	367.29	;
INSERT INTO #r_factor3 SELECT	'AR143'	,	269.77	;
INSERT INTO #r_factor3 SELECT	'AR145'	,	299.6	;
INSERT INTO #r_factor3 SELECT	'AR147'	,	300.27	;
INSERT INTO #r_factor3 SELECT	'AR149'	,	300.98	;
INSERT INTO #r_factor3 SELECT	'AR620'	,	348.96	;
INSERT INTO #r_factor3 SELECT	'AR630'	,	331.63	;
INSERT INTO #r_factor3 SELECT	'AR640'	,	285.2	;
INSERT INTO #r_factor3 SELECT	'AR660'	,	341.91	;
INSERT INTO #r_factor3 SELECT	'AR670'	,	341.72	;
INSERT INTO #r_factor3 SELECT	'AR680'	,	317.31	;
INSERT INTO #r_factor3 SELECT	'AZ623'	,	11.568	;
INSERT INTO #r_factor3 SELECT	'AZ625'	,	15.655	;
INSERT INTO #r_factor3 SELECT	'AZ627'	,	10.121	;
INSERT INTO #r_factor3 SELECT	'AZ629'	,	11.195	;
INSERT INTO #r_factor3 SELECT	'AZ631'	,	27.418	;
INSERT INTO #r_factor3 SELECT	'AZ633'	,	20.571	;
INSERT INTO #r_factor3 SELECT	'AZ635'	,	13.047	;
INSERT INTO #r_factor3 SELECT	'AZ637'	,	22.651	;
INSERT INTO #r_factor3 SELECT	'AZ639'	,	41.125	;
INSERT INTO #r_factor3 SELECT	'AZ641'	,	44.397	;
INSERT INTO #r_factor3 SELECT	'AZ643'	,	46.608	;
INSERT INTO #r_factor3 SELECT	'AZ645'	,	19.855	;
INSERT INTO #r_factor3 SELECT	'AZ646'	,	37.418	;
INSERT INTO #r_factor3 SELECT	'AZ647'	,	24.98	;
INSERT INTO #r_factor3 SELECT	'AZ648'	,	28.649	;
INSERT INTO #r_factor3 SELECT	'AZ649'	,	15.44	;
INSERT INTO #r_factor3 SELECT	'AZ651'	,	20.538	;
INSERT INTO #r_factor3 SELECT	'AZ653'	,	27.587	;
INSERT INTO #r_factor3 SELECT	'AZ655'	,	23.849	;
INSERT INTO #r_factor3 SELECT	'AZ656'	,	9.4782	;
INSERT INTO #r_factor3 SELECT	'AZ657'	,	12.681	;
INSERT INTO #r_factor3 SELECT	'AZ658'	,	25.445	;
INSERT INTO #r_factor3 SELECT	'AZ659'	,	37.91	;
INSERT INTO #r_factor3 SELECT	'AZ661'	,	53.633	;
INSERT INTO #r_factor3 SELECT	'AZ662'	,	37.728	;
INSERT INTO #r_factor3 SELECT	'AZ663'	,	32.803	;
INSERT INTO #r_factor3 SELECT	'AZ664'	,	33.292	;
INSERT INTO #r_factor3 SELECT	'AZ665'	,	46.027	;
INSERT INTO #r_factor3 SELECT	'AZ666'	,	66.688	;
INSERT INTO #r_factor3 SELECT	'AZ667'	,	78.702	;
INSERT INTO #r_factor3 SELECT	'AZ668'	,	53.86	;
INSERT INTO #r_factor3 SELECT	'AZ669'	,	65.33	;
INSERT INTO #r_factor3 SELECT	'AZ671'	,	54.326	;
INSERT INTO #r_factor3 SELECT	'AZ673'	,	54.69	;
INSERT INTO #r_factor3 SELECT	'AZ675'	,	50.388	;
INSERT INTO #r_factor3 SELECT	'AZ683'	,	45.329	;
INSERT INTO #r_factor3 SELECT	'AZ687'	,	57.558	;
INSERT INTO #r_factor3 SELECT	'AZ691'	,	35.888	;
INSERT INTO #r_factor3 SELECT	'AZ693'	,	33.633	;
INSERT INTO #r_factor3 SELECT	'AZ695'	,	23.553	;
INSERT INTO #r_factor3 SELECT	'AZ697'	,	16.689	;
INSERT INTO #r_factor3 SELECT	'AZ699'	,	26.646	;
INSERT INTO #r_factor3 SELECT	'AZ701'	,	19.664	;
INSERT INTO #r_factor3 SELECT	'AZ703'	,	44.16	;
INSERT INTO #r_factor3 SELECT	'AZ707'	,	12.862	;
INSERT INTO #r_factor3 SELECT	'AZ711'	,	10.379	;
INSERT INTO #r_factor3 SELECT	'AZ712'	,	10.683	;
INSERT INTO #r_factor3 SELECT	'AZ713'	,	11.125	;
INSERT INTO #r_factor3 SELECT	'AZ714'	,	10.372	;
INSERT INTO #r_factor3 SELECT	'AZ715'	,	9.8132	;
INSERT INTO #r_factor3 SELECT	'AZ723'	,	53.564	;
INSERT INTO #r_factor3 SELECT	'CA011'	,	21.701	;
INSERT INTO #r_factor3 SELECT	'CA013'	,	29.669	;
INSERT INTO #r_factor3 SELECT	'CA021'	,	29.532	;
INSERT INTO #r_factor3 SELECT	'CA031'	,	2.7302	;
INSERT INTO #r_factor3 SELECT	'CA033'	,	38.92	;
INSERT INTO #r_factor3 SELECT	'CA041'	,	50.634	;
INSERT INTO #r_factor3 SELECT	'CA053'	,	24.164	;
INSERT INTO #r_factor3 SELECT	'CA055'	,	62.235	;
INSERT INTO #r_factor3 SELECT	'CA067'	,	35.466	;
INSERT INTO #r_factor3 SELECT	'CA069'	,	18.005	;
INSERT INTO #r_factor3 SELECT	'CA077'	,	17.028	;
INSERT INTO #r_factor3 SELECT	'CA087'	,	94.189	;
INSERT INTO #r_factor3 SELECT	'CA095'	,	29.777	;
INSERT INTO #r_factor3 SELECT	'CA097'	,	109.56	;
INSERT INTO #r_factor3 SELECT	'CA101'	,	27.245	;
INSERT INTO #r_factor3 SELECT	'CA113'	,	21.401	;
INSERT INTO #r_factor3 SELECT	'CA600'	,	93.821	;
INSERT INTO #r_factor3 SELECT	'CA601'	,	116.64	;
INSERT INTO #r_factor3 SELECT	'CA602'	,	14.26	;
INSERT INTO #r_factor3 SELECT	'CA603'	,	3.3392	;
INSERT INTO #r_factor3 SELECT	'CA604'	,	15.733	;
INSERT INTO #r_factor3 SELECT	'CA605'	,	140.6	;
INSERT INTO #r_factor3 SELECT	'CA606'	,	57.579	;
INSERT INTO #r_factor3 SELECT	'CA607'	,	91.364	;
INSERT INTO #r_factor3 SELECT	'CA608'	,	2.0284	;
INSERT INTO #r_factor3 SELECT	'CA609'	,	26.097	;
INSERT INTO #r_factor3 SELECT	'CA610'	,	42.406	;
INSERT INTO #r_factor3 SELECT	'CA612'	,	44.764	;
INSERT INTO #r_factor3 SELECT	'CA614'	,	12.703	;
INSERT INTO #r_factor3 SELECT	'CA618'	,	63.63	;
INSERT INTO #r_factor3 SELECT	'CA619'	,	94.452	;
INSERT INTO #r_factor3 SELECT	'CA620'	,	62.678	;
INSERT INTO #r_factor3 SELECT	'CA624'	,	77.89	;
INSERT INTO #r_factor3 SELECT	'CA628'	,	59.166	;
INSERT INTO #r_factor3 SELECT	'CA630'	,	61.336	;
INSERT INTO #r_factor3 SELECT	'CA632'	,	35.491	;
INSERT INTO #r_factor3 SELECT	'CA637'	,	79.597	;
INSERT INTO #r_factor3 SELECT	'CA638'	,	29.249	;
INSERT INTO #r_factor3 SELECT	'CA641'	,	42.286	;
INSERT INTO #r_factor3 SELECT	'CA642'	,	10.351	;
INSERT INTO #r_factor3 SELECT	'CA644'	,	22.207	;
INSERT INTO #r_factor3 SELECT	'CA645'	,	41.295	;
INSERT INTO #r_factor3 SELECT	'CA646'	,	24.835	;
INSERT INTO #r_factor3 SELECT	'CA647'	,	10.242	;
INSERT INTO #r_factor3 SELECT	'CA648'	,	16.802	;
INSERT INTO #r_factor3 SELECT	'CA649'	,	35.212	;
INSERT INTO #r_factor3 SELECT	'CA651'	,	18.096	;
INSERT INTO #r_factor3 SELECT	'CA653'	,	6.9401	;
INSERT INTO #r_factor3 SELECT	'CA654'	,	20.693	;
INSERT INTO #r_factor3 SELECT	'CA659'	,	7.2823	;
INSERT INTO #r_factor3 SELECT	'CA660'	,	29.554	;
INSERT INTO #r_factor3 SELECT	'CA663'	,	3.2041	;
INSERT INTO #r_factor3 SELECT	'CA664'	,	51.142	;
INSERT INTO #r_factor3 SELECT	'CA665'	,	29.538	;
INSERT INTO #r_factor3 SELECT	'CA666'	,	2.3049	;
INSERT INTO #r_factor3 SELECT	'CA667'	,	7.1479	;
INSERT INTO #r_factor3 SELECT	'CA668'	,	4.1706	;
INSERT INTO #r_factor3 SELECT	'CA669'	,	0.5126	;
INSERT INTO #r_factor3 SELECT	'CA670'	,	0.5557	;
INSERT INTO #r_factor3 SELECT	'CA671'	,	9.0029	;
INSERT INTO #r_factor3 SELECT	'CA672'	,	34.495	;
INSERT INTO #r_factor3 SELECT	'CA673'	,	86.574	;
INSERT INTO #r_factor3 SELECT	'CA674'	,	81.26	;
INSERT INTO #r_factor3 SELECT	'CA675'	,	7.7431	;
INSERT INTO #r_factor3 SELECT	'CA676'	,	42.412	;
INSERT INTO #r_factor3 SELECT	'CA677'	,	36.539	;
INSERT INTO #r_factor3 SELECT	'CA678'	,	36.577	;
INSERT INTO #r_factor3 SELECT	'CA679'	,	20.239	;
INSERT INTO #r_factor3 SELECT	'CA680'	,	8.609	;
INSERT INTO #r_factor3 SELECT	'CA681'	,	9.9414	;
INSERT INTO #r_factor3 SELECT	'CA682'	,	3.0734	;
INSERT INTO #r_factor3 SELECT	'CA683'	,	8.0479	;
INSERT INTO #r_factor3 SELECT	'CA684'	,	9.5726	;
INSERT INTO #r_factor3 SELECT	'CA685'	,	0.7999	;
INSERT INTO #r_factor3 SELECT	'CA686'	,	3.7966	;
INSERT INTO #r_factor3 SELECT	'CA687'	,	64.47	;
INSERT INTO #r_factor3 SELECT	'CA688'	,	61.807	;
INSERT INTO #r_factor3 SELECT	'CA689'	,	39.044	;
INSERT INTO #r_factor3 SELECT	'CA691'	,	0.1933	;
INSERT INTO #r_factor3 SELECT	'CA692'	,	49.02	;
INSERT INTO #r_factor3 SELECT	'CA693'	,	8.2453	;
INSERT INTO #r_factor3 SELECT	'CA694'	,	99.551	;
INSERT INTO #r_factor3 SELECT	'CA695'	,	3.9279	;
INSERT INTO #r_factor3 SELECT	'CA696'	,	42.398	;
INSERT INTO #r_factor3 SELECT	'CA697'	,	4.6614	;
INSERT INTO #r_factor3 SELECT	'CA698'	,	10.482	;
INSERT INTO #r_factor3 SELECT	'CA699'	,	3.9301	;
INSERT INTO #r_factor3 SELECT	'CA701'	,	118.13	;
INSERT INTO #r_factor3 SELECT	'CA702'	,	55.982	;
INSERT INTO #r_factor3 SELECT	'CA703'	,	6.555	;
INSERT INTO #r_factor3 SELECT	'CA704'	,	68.236	;
INSERT INTO #r_factor3 SELECT	'CA707'	,	72.528	;
INSERT INTO #r_factor3 SELECT	'CA708'	,	11.224	;
INSERT INTO #r_factor3 SELECT	'CA709'	,	36.727	;
INSERT INTO #r_factor3 SELECT	'CA713'	,	31.236	;
INSERT INTO #r_factor3 SELECT	'CA719'	,	36.496	;
INSERT INTO #r_factor3 SELECT	'CA724'	,	33.468	;
INSERT INTO #r_factor3 SELECT	'CA729'	,	4.0627	;
INSERT INTO #r_factor3 SELECT	'CA731'	,	22.964	;
INSERT INTO #r_factor3 SELECT	'CA732'	,	7.1179	;
INSERT INTO #r_factor3 SELECT	'CA740'	,	11.019	;
INSERT INTO #r_factor3 SELECT	'CA750'	,	25.659	;
INSERT INTO #r_factor3 SELECT	'CA760'	,	17.663	;
INSERT INTO #r_factor3 SELECT	'CA763'	,	2.0992	;
INSERT INTO #r_factor3 SELECT	'CA772'	,	33.678	;
INSERT INTO #r_factor3 SELECT	'CA776'	,	33.196	;
INSERT INTO #r_factor3 SELECT	'CA777'	,	43.001	;
INSERT INTO #r_factor3 SELECT	'CA788'	,	19.395	;
INSERT INTO #r_factor3 SELECT	'CA789'	,	12.646	;
INSERT INTO #r_factor3 SELECT	'CA790'	,	11.68	;
INSERT INTO #r_factor3 SELECT	'CA792'	,	18.049	;
INSERT INTO #r_factor3 SELECT	'CA793'	,	3.3546	;
INSERT INTO #r_factor3 SELECT	'CA794'	,	5.1978	;
INSERT INTO #r_factor3 SELECT	'CA795'	,	4.1413	;
INSERT INTO #r_factor3 SELECT	'CA796'	,	171.22	;
INSERT INTO #r_factor3 SELECT	'CA802'	,	4.0668	;
INSERT INTO #r_factor3 SELECT	'CA803'	,	8.0476	;
INSERT INTO #r_factor3 SELECT	'CA804'	,	9.5025	;
INSERT INTO #r_factor3 SELECT	'CA805'	,	5.3812	;
INSERT INTO #r_factor3 SELECT	'CA806'	,	0.6998	;
INSERT INTO #r_factor3 SELECT	'CO001'	,	43.262	;
INSERT INTO #r_factor3 SELECT	'CO005'	,	41.777	;
INSERT INTO #r_factor3 SELECT	'CO009'	,	63.502	;
INSERT INTO #r_factor3 SELECT	'CO011'	,	46.814	;
INSERT INTO #r_factor3 SELECT	'CO017'	,	56.945	;
INSERT INTO #r_factor3 SELECT	'CO023'	,	15.406	;
INSERT INTO #r_factor3 SELECT	'CO025'	,	42.547	;
INSERT INTO #r_factor3 SELECT	'CO031'	,	33.098	;
INSERT INTO #r_factor3 SELECT	'CO061'	,	51.504	;
INSERT INTO #r_factor3 SELECT	'CO063'	,	51.552	;
INSERT INTO #r_factor3 SELECT	'CO073'	,	41.427	;
INSERT INTO #r_factor3 SELECT	'CO075'	,	65.087	;
INSERT INTO #r_factor3 SELECT	'CO087'	,	56.834	;
INSERT INTO #r_factor3 SELECT	'CO089'	,	40.664	;
INSERT INTO #r_factor3 SELECT	'CO095'	,	61.78	;
INSERT INTO #r_factor3 SELECT	'CO099'	,	59.875	;
INSERT INTO #r_factor3 SELECT	'CO115'	,	64.862	;
INSERT INTO #r_factor3 SELECT	'CO121'	,	58.584	;
INSERT INTO #r_factor3 SELECT	'CO125'	,	54.097	;
INSERT INTO #r_factor3 SELECT	'CO617'	,	42.316	;
INSERT INTO #r_factor3 SELECT	'CO618'	,	31.771	;
INSERT INTO #r_factor3 SELECT	'CO622'	,	32.079	;
INSERT INTO #r_factor3 SELECT	'CO623'	,	39.994	;
INSERT INTO #r_factor3 SELECT	'CO624'	,	42.032	;
INSERT INTO #r_factor3 SELECT	'CO625'	,	33.728	;
INSERT INTO #r_factor3 SELECT	'CO626'	,	38.124	;
INSERT INTO #r_factor3 SELECT	'CO627'	,	24.379	;
INSERT INTO #r_factor3 SELECT	'CO628'	,	32.698	;
INSERT INTO #r_factor3 SELECT	'CO630'	,	10.16	;
INSERT INTO #r_factor3 SELECT	'CO631'	,	8.89	;
INSERT INTO #r_factor3 SELECT	'CO632'	,	10.302	;
INSERT INTO #r_factor3 SELECT	'CO633'	,	9.974	;
INSERT INTO #r_factor3 SELECT	'CO634'	,	12.337	;
INSERT INTO #r_factor3 SELECT	'CO635'	,	15.027	;
INSERT INTO #r_factor3 SELECT	'CO636'	,	18.669	;
INSERT INTO #r_factor3 SELECT	'CO637'	,	18.516	;
INSERT INTO #r_factor3 SELECT	'CO638'	,	20.748	;
INSERT INTO #r_factor3 SELECT	'CO640'	,	25.852	;
INSERT INTO #r_factor3 SELECT	'CO641'	,	27.8	;
INSERT INTO #r_factor3 SELECT	'CO642'	,	15.962	;
INSERT INTO #r_factor3 SELECT	'CO643'	,	26.453	;
INSERT INTO #r_factor3 SELECT	'CO644'	,	15.419	;
INSERT INTO #r_factor3 SELECT	'CO645'	,	14.285	;
INSERT INTO #r_factor3 SELECT	'CO646'	,	7.4841	;
INSERT INTO #r_factor3 SELECT	'CO647'	,	7.3791	;
INSERT INTO #r_factor3 SELECT	'CO648'	,	8.5924	;
INSERT INTO #r_factor3 SELECT	'CO649'	,	7.2038	;
INSERT INTO #r_factor3 SELECT	'CO650'	,	7.3933	;
INSERT INTO #r_factor3 SELECT	'CO651'	,	12.562	;
INSERT INTO #r_factor3 SELECT	'CO653'	,	23.634	;
INSERT INTO #r_factor3 SELECT	'CO654'	,	9.8667	;
INSERT INTO #r_factor3 SELECT	'CO655'	,	8.3106	;
INSERT INTO #r_factor3 SELECT	'CO657'	,	18.201	;
INSERT INTO #r_factor3 SELECT	'CO658'	,	15.782	;
INSERT INTO #r_factor3 SELECT	'CO660'	,	9.9675	;
INSERT INTO #r_factor3 SELECT	'CO661'	,	10.879	;
INSERT INTO #r_factor3 SELECT	'CO662'	,	10.028	;
INSERT INTO #r_factor3 SELECT	'CO663'	,	10.443	;
INSERT INTO #r_factor3 SELECT	'CO664'	,	9.8006	;
INSERT INTO #r_factor3 SELECT	'CO666'	,	9.0704	;
INSERT INTO #r_factor3 SELECT	'CO668'	,	8.4298	;
INSERT INTO #r_factor3 SELECT	'CO669'	,	15.495	;
INSERT INTO #r_factor3 SELECT	'CO670'	,	19.836	;
INSERT INTO #r_factor3 SELECT	'CO671'	,	18.393	;
INSERT INTO #r_factor3 SELECT	'CO672'	,	19.397	;
INSERT INTO #r_factor3 SELECT	'CO674'	,	13.26	;
INSERT INTO #r_factor3 SELECT	'CO675'	,	12.46	;
INSERT INTO #r_factor3 SELECT	'CO676'	,	10.918	;
INSERT INTO #r_factor3 SELECT	'CO677'	,	10.492	;
INSERT INTO #r_factor3 SELECT	'CO679'	,	10.062	;
INSERT INTO #r_factor3 SELECT	'CO680'	,	10.02	;
INSERT INTO #r_factor3 SELECT	'CO682'	,	9.9328	;
INSERT INTO #r_factor3 SELECT	'CO683'	,	9.5917	;
INSERT INTO #r_factor3 SELECT	'CO684'	,	9.3595	;
INSERT INTO #r_factor3 SELECT	'CO685'	,	10.014	;
INSERT INTO #r_factor3 SELECT	'CO686'	,	9.9586	;
INSERT INTO #r_factor3 SELECT	'CO690'	,	11.751	;
INSERT INTO #r_factor3 SELECT	'CO692'	,	10.042	;
INSERT INTO #r_factor3 SELECT	'CT600'	,	144.33	;
INSERT INTO #r_factor3 SELECT	'DC001'	,	180.86	;
INSERT INTO #r_factor3 SELECT	'DE001'	,	184.58	;
INSERT INTO #r_factor3 SELECT	'DE003'	,	179.33	;
INSERT INTO #r_factor3 SELECT	'DE005'	,	187.83	;
INSERT INTO #r_factor3 SELECT	'FL001'	,	439.24	;
INSERT INTO #r_factor3 SELECT	'FL003'	,	428.46	;
INSERT INTO #r_factor3 SELECT	'FL005'	,	549.79	;
INSERT INTO #r_factor3 SELECT	'FL007'	,	440.13	;
INSERT INTO #r_factor3 SELECT	'FL009'	,	475.92	;
INSERT INTO #r_factor3 SELECT	'FL013'	,	512.55	;
INSERT INTO #r_factor3 SELECT	'FL015'	,	493.48	;
INSERT INTO #r_factor3 SELECT	'FL017'	,	457.55	;
INSERT INTO #r_factor3 SELECT	'FL019'	,	447.11	;
INSERT INTO #r_factor3 SELECT	'FL023'	,	423.77	;
INSERT INTO #r_factor3 SELECT	'FL027'	,	489.4	;
INSERT INTO #r_factor3 SELECT	'FL029'	,	452.34	;
INSERT INTO #r_factor3 SELECT	'FL031'	,	449.73	;
INSERT INTO #r_factor3 SELECT	'FL033'	,	590.35	;
INSERT INTO #r_factor3 SELECT	'FL035'	,	453.43	;
INSERT INTO #r_factor3 SELECT	'FL037'	,	521.86	;
INSERT INTO #r_factor3 SELECT	'FL039'	,	461.57	;
INSERT INTO #r_factor3 SELECT	'FL041'	,	439.08	;
INSERT INTO #r_factor3 SELECT	'FL043'	,	491.63	;
INSERT INTO #r_factor3 SELECT	'FL045'	,	545.93	;
INSERT INTO #r_factor3 SELECT	'FL047'	,	409.16	;
INSERT INTO #r_factor3 SELECT	'FL049'	,	484.18	;
INSERT INTO #r_factor3 SELECT	'FL051'	,	496.25	;
INSERT INTO #r_factor3 SELECT	'FL053'	,	479.31	;
INSERT INTO #r_factor3 SELECT	'FL055'	,	482.64	;
INSERT INTO #r_factor3 SELECT	'FL057'	,	494.58	;
INSERT INTO #r_factor3 SELECT	'FL059'	,	504.03	;
INSERT INTO #r_factor3 SELECT	'FL061'	,	506.57	;
INSERT INTO #r_factor3 SELECT	'FL063'	,	475.64	;
INSERT INTO #r_factor3 SELECT	'FL065'	,	436.88	;
INSERT INTO #r_factor3 SELECT	'FL067'	,	436.67	;
INSERT INTO #r_factor3 SELECT	'FL071'	,	492.6	;
INSERT INTO #r_factor3 SELECT	'FL073'	,	453.46	;
INSERT INTO #r_factor3 SELECT	'FL075'	,	450.32	;
INSERT INTO #r_factor3 SELECT	'FL077'	,	502.68	;
INSERT INTO #r_factor3 SELECT	'FL079'	,	420.35	;
INSERT INTO #r_factor3 SELECT	'FL081'	,	501.21	;
INSERT INTO #r_factor3 SELECT	'FL085'	,	560.48	;
INSERT INTO #r_factor3 SELECT	'FL089'	,	438.66	;
INSERT INTO #r_factor3 SELECT	'FL091'	,	549.54	;
INSERT INTO #r_factor3 SELECT	'FL093'	,	497.45	;
INSERT INTO #r_factor3 SELECT	'FL095'	,	452.19	;
INSERT INTO #r_factor3 SELECT	'FL097'	,	464.9	;
INSERT INTO #r_factor3 SELECT	'FL101'	,	487.71	;
INSERT INTO #r_factor3 SELECT	'FL103'	,	510.16	;
INSERT INTO #r_factor3 SELECT	'FL105'	,	464.14	;
INSERT INTO #r_factor3 SELECT	'FL107'	,	448.66	;
INSERT INTO #r_factor3 SELECT	'FL109'	,	453.16	;
INSERT INTO #r_factor3 SELECT	'FL111'	,	539.52	;
INSERT INTO #r_factor3 SELECT	'FL113'	,	568.06	;
INSERT INTO #r_factor3 SELECT	'FL115'	,	502.05	;
INSERT INTO #r_factor3 SELECT	'FL117'	,	452.68	;
INSERT INTO #r_factor3 SELECT	'FL119'	,	443.19	;
INSERT INTO #r_factor3 SELECT	'FL121'	,	424.79	;
INSERT INTO #r_factor3 SELECT	'FL123'	,	448.53	;
INSERT INTO #r_factor3 SELECT	'FL125'	,	434.39	;
INSERT INTO #r_factor3 SELECT	'FL127'	,	454.28	;
INSERT INTO #r_factor3 SELECT	'FL129'	,	480.62	;
INSERT INTO #r_factor3 SELECT	'FL131'	,	539.78	;
INSERT INTO #r_factor3 SELECT	'FL133'	,	522.93	;
INSERT INTO #r_factor3 SELECT	'FL606'	,	606.06	;
INSERT INTO #r_factor3 SELECT	'FL607'	,	445.33	;
INSERT INTO #r_factor3 SELECT	'FL608'	,	440.38	;
INSERT INTO #r_factor3 SELECT	'FL609'	,	447.2	;
INSERT INTO #r_factor3 SELECT	'FL611'	,	567.22	;
INSERT INTO #r_factor3 SELECT	'FL615'	,	572.21	;
INSERT INTO #r_factor3 SELECT	'FL616'	,	529.31	;
INSERT INTO #r_factor3 SELECT	'FL618'	,	531.94	;
INSERT INTO #r_factor3 SELECT	'FL621'	,	491.58	;
INSERT INTO #r_factor3 SELECT	'FL686'	,	596.5	;
INSERT INTO #r_factor3 SELECT	'FL687'	,	584.13	;
INSERT INTO #r_factor3 SELECT	'FL999'	,	534.32	;
INSERT INTO #r_factor3 SELECT	'GA015'	,	280.5	;
INSERT INTO #r_factor3 SELECT	'GA021'	,	318	;
INSERT INTO #r_factor3 SELECT	'GA031'	,	346.57	;
INSERT INTO #r_factor3 SELECT	'GA033'	,	303.76	;
INSERT INTO #r_factor3 SELECT	'GA035'	,	303.91	;
INSERT INTO #r_factor3 SELECT	'GA047'	,	255.57	;
INSERT INTO #r_factor3 SELECT	'GA067'	,	291.65	;
INSERT INTO #r_factor3 SELECT	'GA087'	,	434.95	;
INSERT INTO #r_factor3 SELECT	'GA089'	,	294.66	;
INSERT INTO #r_factor3 SELECT	'GA095'	,	374.47	;
INSERT INTO #r_factor3 SELECT	'GA097'	,	301.8	;
INSERT INTO #r_factor3 SELECT	'GA103'	,	363.88	;
INSERT INTO #r_factor3 SELECT	'GA107'	,	326.82	;
INSERT INTO #r_factor3 SELECT	'GA117'	,	278.69	;
INSERT INTO #r_factor3 SELECT	'GA121'	,	295.29	;
INSERT INTO #r_factor3 SELECT	'GA129'	,	270.65	;
INSERT INTO #r_factor3 SELECT	'GA131'	,	418.18	;
INSERT INTO #r_factor3 SELECT	'GA133'	,	294.89	;
INSERT INTO #r_factor3 SELECT	'GA135'	,	287.47	;
INSERT INTO #r_factor3 SELECT	'GA137'	,	267.74	;
INSERT INTO #r_factor3 SELECT	'GA147'	,	276.02	;
INSERT INTO #r_factor3 SELECT	'GA159'	,	302.07	;
INSERT INTO #r_factor3 SELECT	'GA165'	,	318.02	;
INSERT INTO #r_factor3 SELECT	'GA185'	,	393.72	;
INSERT INTO #r_factor3 SELECT	'GA191'	,	405.36	;
INSERT INTO #r_factor3 SELECT	'GA199'	,	323.69	;
INSERT INTO #r_factor3 SELECT	'GA207'	,	312.44	;
INSERT INTO #r_factor3 SELECT	'GA211'	,	295.77	;
INSERT INTO #r_factor3 SELECT	'GA215'	,	348.45	;
INSERT INTO #r_factor3 SELECT	'GA221'	,	287.06	;
INSERT INTO #r_factor3 SELECT	'GA223'	,	296.03	;
INSERT INTO #r_factor3 SELECT	'GA229'	,	382.52	;
INSERT INTO #r_factor3 SELECT	'GA243'	,	377.12	;
INSERT INTO #r_factor3 SELECT	'GA245'	,	293.13	;
INSERT INTO #r_factor3 SELECT	'GA251'	,	327.76	;
INSERT INTO #r_factor3 SELECT	'GA255'	,	307.95	;
INSERT INTO #r_factor3 SELECT	'GA259'	,	362.85	;
INSERT INTO #r_factor3 SELECT	'GA277'	,	368.64	;
INSERT INTO #r_factor3 SELECT	'GA283'	,	334.55	;
INSERT INTO #r_factor3 SELECT	'GA289'	,	322	;
INSERT INTO #r_factor3 SELECT	'GA297'	,	291.77	;
INSERT INTO #r_factor3 SELECT	'GA299'	,	392.53	;
INSERT INTO #r_factor3 SELECT	'GA305'	,	383.95	;
INSERT INTO #r_factor3 SELECT	'GA307'	,	356.35	;
INSERT INTO #r_factor3 SELECT	'GA321'	,	367.12	;
INSERT INTO #r_factor3 SELECT	'GA601'	,	362.31	;
INSERT INTO #r_factor3 SELECT	'GA602'	,	369.57	;
INSERT INTO #r_factor3 SELECT	'GA603'	,	391.67	;
INSERT INTO #r_factor3 SELECT	'GA604'	,	306.26	;
INSERT INTO #r_factor3 SELECT	'GA605'	,	273.72	;
INSERT INTO #r_factor3 SELECT	'GA606'	,	279.99	;
INSERT INTO #r_factor3 SELECT	'GA608'	,	359.31	;
INSERT INTO #r_factor3 SELECT	'GA609'	,	378.23	;
INSERT INTO #r_factor3 SELECT	'GA610'	,	343.74	;
INSERT INTO #r_factor3 SELECT	'GA611'	,	407.03	;
INSERT INTO #r_factor3 SELECT	'GA612'	,	402.06	;
INSERT INTO #r_factor3 SELECT	'GA613'	,	391.2	;
INSERT INTO #r_factor3 SELECT	'GA615'	,	401.41	;
INSERT INTO #r_factor3 SELECT	'GA616'	,	420.13	;
INSERT INTO #r_factor3 SELECT	'GA617'	,	352.56	;
INSERT INTO #r_factor3 SELECT	'GA618'	,	309.42	;
INSERT INTO #r_factor3 SELECT	'GA619'	,	262.12	;
INSERT INTO #r_factor3 SELECT	'GA620'	,	348.16	;
INSERT INTO #r_factor3 SELECT	'GA621'	,	285.58	;
INSERT INTO #r_factor3 SELECT	'GA622'	,	271.88	;
INSERT INTO #r_factor3 SELECT	'GA623'	,	288.06	;
INSERT INTO #r_factor3 SELECT	'GA625'	,	302.57	;
INSERT INTO #r_factor3 SELECT	'GA626'	,	395.84	;
INSERT INTO #r_factor3 SELECT	'GA627'	,	383.43	;
INSERT INTO #r_factor3 SELECT	'GA628'	,	292.51	;
INSERT INTO #r_factor3 SELECT	'GA629'	,	323.1	;
INSERT INTO #r_factor3 SELECT	'GA630'	,	328.89	;
INSERT INTO #r_factor3 SELECT	'GA631'	,	354.2	;
INSERT INTO #r_factor3 SELECT	'GA632'	,	269.4	;
INSERT INTO #r_factor3 SELECT	'GA634'	,	340.69	;
INSERT INTO #r_factor3 SELECT	'GA636'	,	279.46	;
INSERT INTO #r_factor3 SELECT	'GA637'	,	257.52	;
INSERT INTO #r_factor3 SELECT	'GA638'	,	303.26	;
INSERT INTO #r_factor3 SELECT	'GA639'	,	298.73	;
INSERT INTO #r_factor3 SELECT	'GA640'	,	330	;
INSERT INTO #r_factor3 SELECT	'GA641'	,	327.17	;
INSERT INTO #r_factor3 SELECT	'GA642'	,	317.57	;
INSERT INTO #r_factor3 SELECT	'GA643'	,	363.34	;
INSERT INTO #r_factor3 SELECT	'GA644'	,	386.78	;
INSERT INTO #r_factor3 SELECT	'GA645'	,	287.2	;
INSERT INTO #r_factor3 SELECT	'GA646'	,	428.36	;
INSERT INTO #r_factor3 SELECT	'GA647'	,	347.23	;
INSERT INTO #r_factor3 SELECT	'GA648'	,	260.45	;
INSERT INTO #r_factor3 SELECT	'GA649'	,	297.43	;
INSERT INTO #r_factor3 SELECT	'GA650'	,	344.75	;
INSERT INTO #r_factor3 SELECT	'GA651'	,	255.65	;
INSERT INTO #r_factor3 SELECT	'GA652'	,	349.68	;
INSERT INTO #r_factor3 SELECT	'GA654'	,	311.49	;
INSERT INTO #r_factor3 SELECT	'GA655'	,	337.88	;
INSERT INTO #r_factor3 SELECT	'GA658'	,	387.07	;
INSERT INTO #r_factor3 SELECT	'IA001'	,	162.02	;
INSERT INTO #r_factor3 SELECT	'IA003'	,	169.35	;
INSERT INTO #r_factor3 SELECT	'IA005'	,	157.67	;
INSERT INTO #r_factor3 SELECT	'IA007'	,	176.78	;
INSERT INTO #r_factor3 SELECT	'IA009'	,	149.55	;
INSERT INTO #r_factor3 SELECT	'IA011'	,	163.67	;
INSERT INTO #r_factor3 SELECT	'IA013'	,	159.29	;
INSERT INTO #r_factor3 SELECT	'IA015'	,	152.48	;
INSERT INTO #r_factor3 SELECT	'IA017'	,	157.05	;
INSERT INTO #r_factor3 SELECT	'IA019'	,	161.28	;
INSERT INTO #r_factor3 SELECT	'IA021'	,	137.11	;
INSERT INTO #r_factor3 SELECT	'IA023'	,	153.86	;
INSERT INTO #r_factor3 SELECT	'IA025'	,	143.7	;
INSERT INTO #r_factor3 SELECT	'IA027'	,	145.51	;
INSERT INTO #r_factor3 SELECT	'IA029'	,	156.89	;
INSERT INTO #r_factor3 SELECT	'IA031'	,	166.38	;
INSERT INTO #r_factor3 SELECT	'IA033'	,	148.73	;
INSERT INTO #r_factor3 SELECT	'IA035'	,	133.96	;
INSERT INTO #r_factor3 SELECT	'IA037'	,	155.53	;
INSERT INTO #r_factor3 SELECT	'IA039'	,	173.23	;
INSERT INTO #r_factor3 SELECT	'IA041'	,	134.14	;
INSERT INTO #r_factor3 SELECT	'IA043'	,	159.7	;
INSERT INTO #r_factor3 SELECT	'IA045'	,	162.97	;
INSERT INTO #r_factor3 SELECT	'IA047'	,	142.16	;
INSERT INTO #r_factor3 SELECT	'IA049'	,	157.79	;
INSERT INTO #r_factor3 SELECT	'IA051'	,	175.82	;
INSERT INTO #r_factor3 SELECT	'IA053'	,	177.78	;
INSERT INTO #r_factor3 SELECT	'IA055'	,	161.86	;
INSERT INTO #r_factor3 SELECT	'IA057'	,	173.13	;
INSERT INTO #r_factor3 SELECT	'IA059'	,	131.15	;
INSERT INTO #r_factor3 SELECT	'IA061'	,	160.56	;
INSERT INTO #r_factor3 SELECT	'IA063'	,	133.45	;
INSERT INTO #r_factor3 SELECT	'IA065'	,	159.06	;
INSERT INTO #r_factor3 SELECT	'IA067'	,	151.83	;
INSERT INTO #r_factor3 SELECT	'IA069'	,	150.5	;
INSERT INTO #r_factor3 SELECT	'IA071'	,	167.91	;
INSERT INTO #r_factor3 SELECT	'IA073'	,	148.55	;
INSERT INTO #r_factor3 SELECT	'IA075'	,	156.83	;
INSERT INTO #r_factor3 SELECT	'IA077'	,	152.74	;
INSERT INTO #r_factor3 SELECT	'IA079'	,	150.14	;
INSERT INTO #r_factor3 SELECT	'IA081'	,	144.83	;
INSERT INTO #r_factor3 SELECT	'IA083'	,	153.61	;
INSERT INTO #r_factor3 SELECT	'IA085'	,	143.71	;
INSERT INTO #r_factor3 SELECT	'IA087'	,	173.31	;
INSERT INTO #r_factor3 SELECT	'IA089'	,	154.46	;
INSERT INTO #r_factor3 SELECT	'IA091'	,	143.75	;
INSERT INTO #r_factor3 SELECT	'IA093'	,	137.69	;
INSERT INTO #r_factor3 SELECT	'IA095'	,	167.43	;
INSERT INTO #r_factor3 SELECT	'IA097'	,	160.98	;
INSERT INTO #r_factor3 SELECT	'IA099'	,	164.52	;
INSERT INTO #r_factor3 SELECT	'IA101'	,	173.26	;
INSERT INTO #r_factor3 SELECT	'IA103'	,	167.8	;
INSERT INTO #r_factor3 SELECT	'IA105'	,	163.76	;
INSERT INTO #r_factor3 SELECT	'IA107'	,	170.73	;
INSERT INTO #r_factor3 SELECT	'IA109'	,	139.15	;
INSERT INTO #r_factor3 SELECT	'IA111'	,	175.36	;
INSERT INTO #r_factor3 SELECT	'IA113'	,	164.47	;
INSERT INTO #r_factor3 SELECT	'IA115'	,	171.09	;
INSERT INTO #r_factor3 SELECT	'IA117'	,	173.82	;
INSERT INTO #r_factor3 SELECT	'IA119'	,	124.14	;
INSERT INTO #r_factor3 SELECT	'IA121'	,	166.07	;
INSERT INTO #r_factor3 SELECT	'IA123'	,	170.4	;
INSERT INTO #r_factor3 SELECT	'IA125'	,	169.62	;
INSERT INTO #r_factor3 SELECT	'IA127'	,	159.86	;
INSERT INTO #r_factor3 SELECT	'IA129'	,	158.51	;
INSERT INTO #r_factor3 SELECT	'IA131'	,	150.67	;
INSERT INTO #r_factor3 SELECT	'IA133'	,	137.87	;
INSERT INTO #r_factor3 SELECT	'IA135'	,	173.95	;
INSERT INTO #r_factor3 SELECT	'IA137'	,	164.52	;
INSERT INTO #r_factor3 SELECT	'IA139'	,	168.64	;
INSERT INTO #r_factor3 SELECT	'IA141'	,	131.17	;
INSERT INTO #r_factor3 SELECT	'IA143'	,	128.83	;
INSERT INTO #r_factor3 SELECT	'IA145'	,	173.15	;
INSERT INTO #r_factor3 SELECT	'IA147'	,	137.22	;
INSERT INTO #r_factor3 SELECT	'IA149'	,	130.34	;
INSERT INTO #r_factor3 SELECT	'IA151'	,	140.45	;
INSERT INTO #r_factor3 SELECT	'IA153'	,	161.74	;
INSERT INTO #r_factor3 SELECT	'IA155'	,	151.45	;
INSERT INTO #r_factor3 SELECT	'IA157'	,	166.39	;
INSERT INTO #r_factor3 SELECT	'IA159'	,	177.22	;
INSERT INTO #r_factor3 SELECT	'IA161'	,	140.41	;
INSERT INTO #r_factor3 SELECT	'IA163'	,	165.68	;
INSERT INTO #r_factor3 SELECT	'IA165'	,	147.32	;
INSERT INTO #r_factor3 SELECT	'IA167'	,	127.43	;
INSERT INTO #r_factor3 SELECT	'IA169'	,	156.67	;
INSERT INTO #r_factor3 SELECT	'IA171'	,	161.87	;
INSERT INTO #r_factor3 SELECT	'IA173'	,	175.89	;
INSERT INTO #r_factor3 SELECT	'IA175'	,	172.09	;
INSERT INTO #r_factor3 SELECT	'IA177'	,	175.16	;
INSERT INTO #r_factor3 SELECT	'IA179'	,	173.66	;
INSERT INTO #r_factor3 SELECT	'IA181'	,	168.16	;
INSERT INTO #r_factor3 SELECT	'IA183'	,	170.73	;
INSERT INTO #r_factor3 SELECT	'IA185'	,	177.45	;
INSERT INTO #r_factor3 SELECT	'IA187'	,	146.6	;
INSERT INTO #r_factor3 SELECT	'IA189'	,	141.09	;
INSERT INTO #r_factor3 SELECT	'IA191'	,	157.38	;
INSERT INTO #r_factor3 SELECT	'IA193'	,	134.19	;
INSERT INTO #r_factor3 SELECT	'IA195'	,	146.43	;
INSERT INTO #r_factor3 SELECT	'IA197'	,	147.7	;
INSERT INTO #r_factor3 SELECT	'ID001'	,	9.9333	;
INSERT INTO #r_factor3 SELECT	'ID057'	,	17.503	;
INSERT INTO #r_factor3 SELECT	'ID600'	,	15.425	;
INSERT INTO #r_factor3 SELECT	'ID601'	,	13.998	;
INSERT INTO #r_factor3 SELECT	'ID604'	,	17.054	;
INSERT INTO #r_factor3 SELECT	'ID606'	,	16.336	;
INSERT INTO #r_factor3 SELECT	'ID608'	,	19.587	;
INSERT INTO #r_factor3 SELECT	'ID609'	,	16.223	;
INSERT INTO #r_factor3 SELECT	'ID611'	,	19.125	;
INSERT INTO #r_factor3 SELECT	'ID612'	,	20.164	;
INSERT INTO #r_factor3 SELECT	'ID617'	,	18.584	;
INSERT INTO #r_factor3 SELECT	'ID618'	,	20.162	;
INSERT INTO #r_factor3 SELECT	'ID620'	,	15.663	;
INSERT INTO #r_factor3 SELECT	'ID650'	,	10.03	;
INSERT INTO #r_factor3 SELECT	'ID652'	,	10.483	;
INSERT INTO #r_factor3 SELECT	'ID656'	,	10.125	;
INSERT INTO #r_factor3 SELECT	'ID659'	,	10.053	;
INSERT INTO #r_factor3 SELECT	'ID660'	,	10.141	;
INSERT INTO #r_factor3 SELECT	'ID662'	,	10.098	;
INSERT INTO #r_factor3 SELECT	'ID665'	,	9.992	;
INSERT INTO #r_factor3 SELECT	'ID670'	,	17.468	;
INSERT INTO #r_factor3 SELECT	'ID671'	,	18.186	;
INSERT INTO #r_factor3 SELECT	'ID673'	,	10.049	;
INSERT INTO #r_factor3 SELECT	'ID675'	,	8.2056	;
INSERT INTO #r_factor3 SELECT	'ID677'	,	7.4428	;
INSERT INTO #r_factor3 SELECT	'ID680'	,	10.088	;
INSERT INTO #r_factor3 SELECT	'ID681'	,	10.001	;
INSERT INTO #r_factor3 SELECT	'ID683'	,	10.098	;
INSERT INTO #r_factor3 SELECT	'ID685'	,	9.6932	;
INSERT INTO #r_factor3 SELECT	'ID700'	,	10.335	;
INSERT INTO #r_factor3 SELECT	'ID701'	,	9.6479	;
INSERT INTO #r_factor3 SELECT	'ID702'	,	9.9614	;
INSERT INTO #r_factor3 SELECT	'ID703'	,	9.8734	;
INSERT INTO #r_factor3 SELECT	'ID704'	,	9.8273	;
INSERT INTO #r_factor3 SELECT	'ID707'	,	9.8525	;
INSERT INTO #r_factor3 SELECT	'ID708'	,	9.853	;
INSERT INTO #r_factor3 SELECT	'ID709'	,	10.085	;
INSERT INTO #r_factor3 SELECT	'ID710'	,	10.052	;
INSERT INTO #r_factor3 SELECT	'ID711'	,	10.296	;
INSERT INTO #r_factor3 SELECT	'ID712'	,	9.9061	;
INSERT INTO #r_factor3 SELECT	'ID713'	,	10.189	;
INSERT INTO #r_factor3 SELECT	'ID714'	,	11.194	;
INSERT INTO #r_factor3 SELECT	'ID715'	,	10.541	;
INSERT INTO #r_factor3 SELECT	'ID716'	,	9.9981	;
INSERT INTO #r_factor3 SELECT	'ID720'	,	8.279	;
INSERT INTO #r_factor3 SELECT	'ID721'	,	9.6912	;
INSERT INTO #r_factor3 SELECT	'ID752'	,	9.3509	;
INSERT INTO #r_factor3 SELECT	'ID758'	,	10.015	;
INSERT INTO #r_factor3 SELECT	'ID761'	,	10.004	;
INSERT INTO #r_factor3 SELECT	'ID762'	,	10.04	;
INSERT INTO #r_factor3 SELECT	'ID763'	,	9.9957	;
INSERT INTO #r_factor3 SELECT	'ID765'	,	10.016	;
INSERT INTO #r_factor3 SELECT	'ID766'	,	10.047	;
INSERT INTO #r_factor3 SELECT	'ID769'	,	10.034	;
INSERT INTO #r_factor3 SELECT	'ID770'	,	10.013	;
INSERT INTO #r_factor3 SELECT	'ID772'	,	9.9991	;
INSERT INTO #r_factor3 SELECT	'ID780'	,	10.015	;
INSERT INTO #r_factor3 SELECT	'ID782'	,	10.022	;
INSERT INTO #r_factor3 SELECT	'IL001'	,	180.92	;
INSERT INTO #r_factor3 SELECT	'IL003'	,	249.31	;
INSERT INTO #r_factor3 SELECT	'IL005'	,	192.87	;
INSERT INTO #r_factor3 SELECT	'IL007'	,	146.7	;
INSERT INTO #r_factor3 SELECT	'IL009'	,	178.38	;
INSERT INTO #r_factor3 SELECT	'IL011'	,	163	;
INSERT INTO #r_factor3 SELECT	'IL013'	,	192.63	;
INSERT INTO #r_factor3 SELECT	'IL015'	,	157.91	;
INSERT INTO #r_factor3 SELECT	'IL017'	,	175.28	;
INSERT INTO #r_factor3 SELECT	'IL019'	,	168.95	;
INSERT INTO #r_factor3 SELECT	'IL021'	,	177.31	;
INSERT INTO #r_factor3 SELECT	'IL023'	,	176.79	;
INSERT INTO #r_factor3 SELECT	'IL025'	,	193.32	;
INSERT INTO #r_factor3 SELECT	'IL027'	,	198.71	;
INSERT INTO #r_factor3 SELECT	'IL029'	,	175.52	;
INSERT INTO #r_factor3 SELECT	'IL031'	,	151.08	;
INSERT INTO #r_factor3 SELECT	'IL033'	,	183.32	;
INSERT INTO #r_factor3 SELECT	'IL035'	,	179.81	;
INSERT INTO #r_factor3 SELECT	'IL037'	,	154.13	;
INSERT INTO #r_factor3 SELECT	'IL039'	,	170.25	;
INSERT INTO #r_factor3 SELECT	'IL041'	,	172.52	;
INSERT INTO #r_factor3 SELECT	'IL043'	,	152.4	;
INSERT INTO #r_factor3 SELECT	'IL045'	,	172.36	;
INSERT INTO #r_factor3 SELECT	'IL047'	,	198.97	;
INSERT INTO #r_factor3 SELECT	'IL049'	,	186.01	;
INSERT INTO #r_factor3 SELECT	'IL051'	,	188.79	;
INSERT INTO #r_factor3 SELECT	'IL053'	,	165.71	;
INSERT INTO #r_factor3 SELECT	'IL055'	,	215.15	;
INSERT INTO #r_factor3 SELECT	'IL057'	,	171.96	;
INSERT INTO #r_factor3 SELECT	'IL059'	,	214.53	;
INSERT INTO #r_factor3 SELECT	'IL061'	,	186.37	;
INSERT INTO #r_factor3 SELECT	'IL063'	,	160.96	;
INSERT INTO #r_factor3 SELECT	'IL065'	,	209.53	;
INSERT INTO #r_factor3 SELECT	'IL067'	,	176.2	;
INSERT INTO #r_factor3 SELECT	'IL069'	,	220.63	;
INSERT INTO #r_factor3 SELECT	'IL071'	,	173.09	;
INSERT INTO #r_factor3 SELECT	'IL073'	,	165.82	;
INSERT INTO #r_factor3 SELECT	'IL075'	,	162.94	;
INSERT INTO #r_factor3 SELECT	'IL077'	,	224.97	;
INSERT INTO #r_factor3 SELECT	'IL079'	,	185.63	;
INSERT INTO #r_factor3 SELECT	'IL081'	,	204.57	;
INSERT INTO #r_factor3 SELECT	'IL083'	,	192.11	;
INSERT INTO #r_factor3 SELECT	'IL085'	,	157.36	;
INSERT INTO #r_factor3 SELECT	'IL087'	,	233.43	;
INSERT INTO #r_factor3 SELECT	'IL089'	,	152.49	;
INSERT INTO #r_factor3 SELECT	'IL091'	,	160.18	;
INSERT INTO #r_factor3 SELECT	'IL093'	,	157.62	;
INSERT INTO #r_factor3 SELECT	'IL095'	,	169.27	;
INSERT INTO #r_factor3 SELECT	'IL097'	,	139.32	;
INSERT INTO #r_factor3 SELECT	'IL099'	,	161.56	;
INSERT INTO #r_factor3 SELECT	'IL101'	,	189.54	;
INSERT INTO #r_factor3 SELECT	'IL103'	,	158.38	;
INSERT INTO #r_factor3 SELECT	'IL105'	,	164.64	;
INSERT INTO #r_factor3 SELECT	'IL107'	,	171.54	;
INSERT INTO #r_factor3 SELECT	'IL109'	,	174.22	;
INSERT INTO #r_factor3 SELECT	'IL111'	,	143.01	;
INSERT INTO #r_factor3 SELECT	'IL113'	,	168.05	;
INSERT INTO #r_factor3 SELECT	'IL115'	,	172.9	;
INSERT INTO #r_factor3 SELECT	'IL117'	,	185.85	;
INSERT INTO #r_factor3 SELECT	'IL119'	,	195.6	;
INSERT INTO #r_factor3 SELECT	'IL121'	,	196.46	;
INSERT INTO #r_factor3 SELECT	'IL123'	,	165.44	;
INSERT INTO #r_factor3 SELECT	'IL125'	,	172.16	;
INSERT INTO #r_factor3 SELECT	'IL127'	,	238.45	;
INSERT INTO #r_factor3 SELECT	'IL129'	,	173.24	;
INSERT INTO #r_factor3 SELECT	'IL131'	,	169.64	;
INSERT INTO #r_factor3 SELECT	'IL133'	,	209.26	;
INSERT INTO #r_factor3 SELECT	'IL135'	,	184.88	;
INSERT INTO #r_factor3 SELECT	'IL137'	,	177.87	;
INSERT INTO #r_factor3 SELECT	'IL139'	,	174.64	;
INSERT INTO #r_factor3 SELECT	'IL141'	,	154.43	;
INSERT INTO #r_factor3 SELECT	'IL143'	,	168.26	;
INSERT INTO #r_factor3 SELECT	'IL145'	,	213.49	;
INSERT INTO #r_factor3 SELECT	'IL147'	,	170.89	;
INSERT INTO #r_factor3 SELECT	'IL149'	,	184.99	;
INSERT INTO #r_factor3 SELECT	'IL151'	,	229.19	;
INSERT INTO #r_factor3 SELECT	'IL153'	,	246.61	;
INSERT INTO #r_factor3 SELECT	'IL155'	,	163.98	;
INSERT INTO #r_factor3 SELECT	'IL157'	,	215.77	;
INSERT INTO #r_factor3 SELECT	'IL159'	,	192.86	;
INSERT INTO #r_factor3 SELECT	'IL161'	,	166.79	;
INSERT INTO #r_factor3 SELECT	'IL163'	,	203.18	;
INSERT INTO #r_factor3 SELECT	'IL165'	,	220.18	;
INSERT INTO #r_factor3 SELECT	'IL167'	,	175.27	;
INSERT INTO #r_factor3 SELECT	'IL169'	,	175.7	;
INSERT INTO #r_factor3 SELECT	'IL171'	,	181.06	;
INSERT INTO #r_factor3 SELECT	'IL173'	,	179.06	;
INSERT INTO #r_factor3 SELECT	'IL175'	,	166.4	;
INSERT INTO #r_factor3 SELECT	'IL177'	,	153.14	;
INSERT INTO #r_factor3 SELECT	'IL179'	,	169.3	;
INSERT INTO #r_factor3 SELECT	'IL181'	,	238.46	;
INSERT INTO #r_factor3 SELECT	'IL183'	,	166.71	;
INSERT INTO #r_factor3 SELECT	'IL185'	,	196.34	;
INSERT INTO #r_factor3 SELECT	'IL187'	,	171.65	;
INSERT INTO #r_factor3 SELECT	'IL189'	,	204.62	;
INSERT INTO #r_factor3 SELECT	'IL191'	,	200.33	;
INSERT INTO #r_factor3 SELECT	'IL193'	,	205.88	;
INSERT INTO #r_factor3 SELECT	'IL195'	,	161.1	;
INSERT INTO #r_factor3 SELECT	'IL197'	,	157.5	;
INSERT INTO #r_factor3 SELECT	'IL199'	,	224.71	;
INSERT INTO #r_factor3 SELECT	'IL201'	,	149.29	;
INSERT INTO #r_factor3 SELECT	'IL203'	,	166.8	;
INSERT INTO #r_factor3 SELECT	'IN001'	,	127.51	;
INSERT INTO #r_factor3 SELECT	'IN003'	,	124.61	;
INSERT INTO #r_factor3 SELECT	'IN005'	,	164.38	;
INSERT INTO #r_factor3 SELECT	'IN007'	,	160.35	;
INSERT INTO #r_factor3 SELECT	'IN009'	,	136.98	;
INSERT INTO #r_factor3 SELECT	'IN011'	,	155.26	;
INSERT INTO #r_factor3 SELECT	'IN013'	,	168.66	;
INSERT INTO #r_factor3 SELECT	'IN015'	,	152.87	;
INSERT INTO #r_factor3 SELECT	'IN017'	,	150.38	;
INSERT INTO #r_factor3 SELECT	'IN019'	,	172.98	;
INSERT INTO #r_factor3 SELECT	'IN021'	,	173.34	;
INSERT INTO #r_factor3 SELECT	'IN023'	,	153.01	;
INSERT INTO #r_factor3 SELECT	'IN025'	,	183.14	;
INSERT INTO #r_factor3 SELECT	'IN027'	,	183.38	;
INSERT INTO #r_factor3 SELECT	'IN029'	,	156.79	;
INSERT INTO #r_factor3 SELECT	'IN031'	,	158.24	;
INSERT INTO #r_factor3 SELECT	'IN033'	,	120.89	;
INSERT INTO #r_factor3 SELECT	'IN035'	,	141.56	;
INSERT INTO #r_factor3 SELECT	'IN037'	,	186.59	;
INSERT INTO #r_factor3 SELECT	'IN039'	,	132.64	;
INSERT INTO #r_factor3 SELECT	'IN041'	,	149.86	;
INSERT INTO #r_factor3 SELECT	'IN043'	,	176.64	;
INSERT INTO #r_factor3 SELECT	'IN045'	,	163.77	;
INSERT INTO #r_factor3 SELECT	'IN047'	,	152.55	;
INSERT INTO #r_factor3 SELECT	'IN049'	,	148.65	;
INSERT INTO #r_factor3 SELECT	'IN051'	,	195.12	;
INSERT INTO #r_factor3 SELECT	'IN053'	,	141.57	;
INSERT INTO #r_factor3 SELECT	'IN055'	,	177.07	;
INSERT INTO #r_factor3 SELECT	'IN057'	,	150.29	;
INSERT INTO #r_factor3 SELECT	'IN059'	,	150.95	;
INSERT INTO #r_factor3 SELECT	'IN061'	,	180.59	;
INSERT INTO #r_factor3 SELECT	'IN063'	,	160.42	;
INSERT INTO #r_factor3 SELECT	'IN065'	,	146.8	;
INSERT INTO #r_factor3 SELECT	'IN067'	,	148.52	;
INSERT INTO #r_factor3 SELECT	'IN069'	,	135.51	;
INSERT INTO #r_factor3 SELECT	'IN071'	,	171.13	;
INSERT INTO #r_factor3 SELECT	'IN073'	,	156.25	;
INSERT INTO #r_factor3 SELECT	'IN075'	,	132.82	;
INSERT INTO #r_factor3 SELECT	'IN077'	,	166.46	;
INSERT INTO #r_factor3 SELECT	'IN079'	,	165.14	;
INSERT INTO #r_factor3 SELECT	'IN081'	,	160.99	;
INSERT INTO #r_factor3 SELECT	'IN083'	,	186.97	;
INSERT INTO #r_factor3 SELECT	'IN085'	,	138.57	;
INSERT INTO #r_factor3 SELECT	'IN087'	,	124.7	;
INSERT INTO #r_factor3 SELECT	'IN089'	,	154.67	;
INSERT INTO #r_factor3 SELECT	'IN091'	,	148.75	;
INSERT INTO #r_factor3 SELECT	'IN093'	,	176.25	;
INSERT INTO #r_factor3 SELECT	'IN095'	,	146.46	;
INSERT INTO #r_factor3 SELECT	'IN097'	,	155.36	;
INSERT INTO #r_factor3 SELECT	'IN099'	,	146.12	;
INSERT INTO #r_factor3 SELECT	'IN101'	,	180.75	;
INSERT INTO #r_factor3 SELECT	'IN103'	,	146.67	;
INSERT INTO #r_factor3 SELECT	'IN105'	,	172.76	;
INSERT INTO #r_factor3 SELECT	'IN107'	,	161.04	;
INSERT INTO #r_factor3 SELECT	'IN109'	,	165.52	;
INSERT INTO #r_factor3 SELECT	'IN111'	,	158.89	;
INSERT INTO #r_factor3 SELECT	'IN113'	,	126.98	;
INSERT INTO #r_factor3 SELECT	'IN115'	,	160	;
INSERT INTO #r_factor3 SELECT	'IN117'	,	180.02	;
INSERT INTO #r_factor3 SELECT	'IN119'	,	172.89	;
INSERT INTO #r_factor3 SELECT	'IN121'	,	168.13	;
INSERT INTO #r_factor3 SELECT	'IN123'	,	188.75	;
INSERT INTO #r_factor3 SELECT	'IN125'	,	189.63	;
INSERT INTO #r_factor3 SELECT	'IN127'	,	152.3	;
INSERT INTO #r_factor3 SELECT	'IN129'	,	203.14	;
INSERT INTO #r_factor3 SELECT	'IN131'	,	152.7	;
INSERT INTO #r_factor3 SELECT	'IN133'	,	166.54	;
INSERT INTO #r_factor3 SELECT	'IN135'	,	137.46	;
INSERT INTO #r_factor3 SELECT	'IN137'	,	159.88	;
INSERT INTO #r_factor3 SELECT	'IN139'	,	151.92	;
INSERT INTO #r_factor3 SELECT	'IN141'	,	141.34	;
INSERT INTO #r_factor3 SELECT	'IN143'	,	170.87	;
INSERT INTO #r_factor3 SELECT	'IN145'	,	156.78	;
INSERT INTO #r_factor3 SELECT	'IN147'	,	192.83	;
INSERT INTO #r_factor3 SELECT	'IN149'	,	150.98	;
INSERT INTO #r_factor3 SELECT	'IN151'	,	118.1	;
INSERT INTO #r_factor3 SELECT	'IN153'	,	179.12	;
INSERT INTO #r_factor3 SELECT	'IN155'	,	162.38	;
INSERT INTO #r_factor3 SELECT	'IN157'	,	157.65	;
INSERT INTO #r_factor3 SELECT	'IN159'	,	148.66	;
INSERT INTO #r_factor3 SELECT	'IN161'	,	148.58	;
INSERT INTO #r_factor3 SELECT	'IN163'	,	199.07	;
INSERT INTO #r_factor3 SELECT	'IN165'	,	168.86	;
INSERT INTO #r_factor3 SELECT	'IN167'	,	174.11	;
INSERT INTO #r_factor3 SELECT	'IN169'	,	141.37	;
INSERT INTO #r_factor3 SELECT	'IN171'	,	162.54	;
INSERT INTO #r_factor3 SELECT	'IN173'	,	194.28	;
INSERT INTO #r_factor3 SELECT	'IN175'	,	175.61	;
INSERT INTO #r_factor3 SELECT	'IN177'	,	144.02	;
INSERT INTO #r_factor3 SELECT	'IN179'	,	132.09	;
INSERT INTO #r_factor3 SELECT	'IN181'	,	155.48	;
INSERT INTO #r_factor3 SELECT	'IN183'	,	131.67	;
INSERT INTO #r_factor3 SELECT	'KS001'	,	219.71	;
INSERT INTO #r_factor3 SELECT	'KS003'	,	207.95	;
INSERT INTO #r_factor3 SELECT	'KS005'	,	190.67	;
INSERT INTO #r_factor3 SELECT	'KS007'	,	163.49	;
INSERT INTO #r_factor3 SELECT	'KS009'	,	143.95	;
INSERT INTO #r_factor3 SELECT	'KS011'	,	222.23	;
INSERT INTO #r_factor3 SELECT	'KS013'	,	185.31	;
INSERT INTO #r_factor3 SELECT	'KS015'	,	203.86	;
INSERT INTO #r_factor3 SELECT	'KS017'	,	195.99	;
INSERT INTO #r_factor3 SELECT	'KS019'	,	230.21	;
INSERT INTO #r_factor3 SELECT	'KS021'	,	246.8	;
INSERT INTO #r_factor3 SELECT	'KS023'	,	69.726	;
INSERT INTO #r_factor3 SELECT	'KS025'	,	127.48	;
INSERT INTO #r_factor3 SELECT	'KS027'	,	168.75	;
INSERT INTO #r_factor3 SELECT	'KS029'	,	152.39	;
INSERT INTO #r_factor3 SELECT	'KS031'	,	204.15	;
INSERT INTO #r_factor3 SELECT	'KS033'	,	145.85	;
INSERT INTO #r_factor3 SELECT	'KS035'	,	215.32	;
INSERT INTO #r_factor3 SELECT	'KS037'	,	234.27	;
INSERT INTO #r_factor3 SELECT	'KS039'	,	97.496	;
INSERT INTO #r_factor3 SELECT	'KS041'	,	176.85	;
INSERT INTO #r_factor3 SELECT	'KS043'	,	189.4	;
INSERT INTO #r_factor3 SELECT	'KS045'	,	197.34	;
INSERT INTO #r_factor3 SELECT	'KS047'	,	131.66	;
INSERT INTO #r_factor3 SELECT	'KS049'	,	221.47	;
INSERT INTO #r_factor3 SELECT	'KS051'	,	124.98	;
INSERT INTO #r_factor3 SELECT	'KS053'	,	153.45	;
INSERT INTO #r_factor3 SELECT	'KS055'	,	95.564	;
INSERT INTO #r_factor3 SELECT	'KS057'	,	114.99	;
INSERT INTO #r_factor3 SELECT	'KS059'	,	200.56	;
INSERT INTO #r_factor3 SELECT	'KS061'	,	180.91	;
INSERT INTO #r_factor3 SELECT	'KS063'	,	99.062	;
INSERT INTO #r_factor3 SELECT	'KS065'	,	111.06	;
INSERT INTO #r_factor3 SELECT	'KS067'	,	84.875	;
INSERT INTO #r_factor3 SELECT	'KS069'	,	101.78	;
INSERT INTO #r_factor3 SELECT	'KS071'	,	72.922	;
INSERT INTO #r_factor3 SELECT	'KS073'	,	208.93	;
INSERT INTO #r_factor3 SELECT	'KS075'	,	71.523	;
INSERT INTO #r_factor3 SELECT	'KS077'	,	181.69	;
INSERT INTO #r_factor3 SELECT	'KS079'	,	185.4	;
INSERT INTO #r_factor3 SELECT	'KS081'	,	96.464	;
INSERT INTO #r_factor3 SELECT	'KS083'	,	111.53	;
INSERT INTO #r_factor3 SELECT	'KS085'	,	187.76	;
INSERT INTO #r_factor3 SELECT	'KS087'	,	193.06	;
INSERT INTO #r_factor3 SELECT	'KS089'	,	137.18	;
INSERT INTO #r_factor3 SELECT	'KS091'	,	199.18	;
INSERT INTO #r_factor3 SELECT	'KS093'	,	83.904	;
INSERT INTO #r_factor3 SELECT	'KS095'	,	174.73	;
INSERT INTO #r_factor3 SELECT	'KS097'	,	138.06	;
INSERT INTO #r_factor3 SELECT	'KS099'	,	244.04	;
INSERT INTO #r_factor3 SELECT	'KS101'	,	98.934	;
INSERT INTO #r_factor3 SELECT	'KS103'	,	195.61	;
INSERT INTO #r_factor3 SELECT	'KS105'	,	148.24	;
INSERT INTO #r_factor3 SELECT	'KS107'	,	210.58	;
INSERT INTO #r_factor3 SELECT	'KS109'	,	85.092	;
INSERT INTO #r_factor3 SELECT	'KS111'	,	197.23	;
INSERT INTO #r_factor3 SELECT	'KS113'	,	174.54	;
INSERT INTO #r_factor3 SELECT	'KS115'	,	186.74	;
INSERT INTO #r_factor3 SELECT	'KS117'	,	172.81	;
INSERT INTO #r_factor3 SELECT	'KS119'	,	112.5	;
INSERT INTO #r_factor3 SELECT	'KS121'	,	202.33	;
INSERT INTO #r_factor3 SELECT	'KS123'	,	143.62	;
INSERT INTO #r_factor3 SELECT	'KS125'	,	238.13	;
INSERT INTO #r_factor3 SELECT	'KS127'	,	187.51	;
INSERT INTO #r_factor3 SELECT	'KS129'	,	75.714	;
INSERT INTO #r_factor3 SELECT	'KS131'	,	180.47	;
INSERT INTO #r_factor3 SELECT	'KS133'	,	230.78	;
INSERT INTO #r_factor3 SELECT	'KS135'	,	110.23	;
INSERT INTO #r_factor3 SELECT	'KS137'	,	107.23	;
INSERT INTO #r_factor3 SELECT	'KS139'	,	197.41	;
INSERT INTO #r_factor3 SELECT	'KS141'	,	134.12	;
INSERT INTO #r_factor3 SELECT	'KS143'	,	159.73	;
INSERT INTO #r_factor3 SELECT	'KS145'	,	131.37	;
INSERT INTO #r_factor3 SELECT	'KS147'	,	119.76	;
INSERT INTO #r_factor3 SELECT	'KS149'	,	182.21	;
INSERT INTO #r_factor3 SELECT	'KS151'	,	155.61	;
INSERT INTO #r_factor3 SELECT	'KS153'	,	85.033	;
INSERT INTO #r_factor3 SELECT	'KS155'	,	170.12	;
INSERT INTO #r_factor3 SELECT	'KS157'	,	146.7	;
INSERT INTO #r_factor3 SELECT	'KS159'	,	160.02	;
INSERT INTO #r_factor3 SELECT	'KS161'	,	177.71	;
INSERT INTO #r_factor3 SELECT	'KS163'	,	124.06	;
INSERT INTO #r_factor3 SELECT	'KS165'	,	126.48	;
INSERT INTO #r_factor3 SELECT	'KS167'	,	138.64	;
INSERT INTO #r_factor3 SELECT	'KS169'	,	167.25	;
INSERT INTO #r_factor3 SELECT	'KS171'	,	91.243	;
INSERT INTO #r_factor3 SELECT	'KS173'	,	193.84	;
INSERT INTO #r_factor3 SELECT	'KS175'	,	102.27	;
INSERT INTO #r_factor3 SELECT	'KS177'	,	192.3	;
INSERT INTO #r_factor3 SELECT	'KS179'	,	99.612	;
INSERT INTO #r_factor3 SELECT	'KS181'	,	75.212	;
INSERT INTO #r_factor3 SELECT	'KS183'	,	128.6	;
INSERT INTO #r_factor3 SELECT	'KS185'	,	150.45	;
INSERT INTO #r_factor3 SELECT	'KS187'	,	73.072	;
INSERT INTO #r_factor3 SELECT	'KS189'	,	90.149	;
INSERT INTO #r_factor3 SELECT	'KS191'	,	201.06	;
INSERT INTO #r_factor3 SELECT	'KS193'	,	86.022	;
INSERT INTO #r_factor3 SELECT	'KS195'	,	112.06	;
INSERT INTO #r_factor3 SELECT	'KS197'	,	189.07	;
INSERT INTO #r_factor3 SELECT	'KS199'	,	76.43	;
INSERT INTO #r_factor3 SELECT	'KS201'	,	160.06	;
INSERT INTO #r_factor3 SELECT	'KS203'	,	83.382	;
INSERT INTO #r_factor3 SELECT	'KS205'	,	225.58	;
INSERT INTO #r_factor3 SELECT	'KS207'	,	215.65	;
INSERT INTO #r_factor3 SELECT	'KS209'	,	197.47	;
INSERT INTO #r_factor3 SELECT	'KY001'	,	188.7	;
INSERT INTO #r_factor3 SELECT	'KY003'	,	206.44	;
INSERT INTO #r_factor3 SELECT	'KY011'	,	155.66	;
INSERT INTO #r_factor3 SELECT	'KY025'	,	152.93	;
INSERT INTO #r_factor3 SELECT	'KY033'	,	220.33	;
INSERT INTO #r_factor3 SELECT	'KY043'	,	149.27	;
INSERT INTO #r_factor3 SELECT	'KY045'	,	173.9	;
INSERT INTO #r_factor3 SELECT	'KY047'	,	218.7	;
INSERT INTO #r_factor3 SELECT	'KY049'	,	160.37	;
INSERT INTO #r_factor3 SELECT	'KY051'	,	158.51	;
INSERT INTO #r_factor3 SELECT	'KY053'	,	195.18	;
INSERT INTO #r_factor3 SELECT	'KY055'	,	220.68	;
INSERT INTO #r_factor3 SELECT	'KY057'	,	198.95	;
INSERT INTO #r_factor3 SELECT	'KY063'	,	149.94	;
INSERT INTO #r_factor3 SELECT	'KY069'	,	154.21	;
INSERT INTO #r_factor3 SELECT	'KY075'	,	257.51	;
INSERT INTO #r_factor3 SELECT	'KY083'	,	248	;
INSERT INTO #r_factor3 SELECT	'KY085'	,	197.34	;
INSERT INTO #r_factor3 SELECT	'KY097'	,	160.19	;
INSERT INTO #r_factor3 SELECT	'KY101'	,	202.05	;
INSERT INTO #r_factor3 SELECT	'KY107'	,	210.32	;
INSERT INTO #r_factor3 SELECT	'KY111'	,	175.67	;
INSERT INTO #r_factor3 SELECT	'KY135'	,	151.02	;
INSERT INTO #r_factor3 SELECT	'KY139'	,	230.06	;
INSERT INTO #r_factor3 SELECT	'KY141'	,	210.68	;
INSERT INTO #r_factor3 SELECT	'KY151'	,	162.55	;
INSERT INTO #r_factor3 SELECT	'KY155'	,	176.93	;
INSERT INTO #r_factor3 SELECT	'KY161'	,	154.16	;
INSERT INTO #r_factor3 SELECT	'KY169'	,	199.38	;
INSERT INTO #r_factor3 SELECT	'KY171'	,	203.73	;
INSERT INTO #r_factor3 SELECT	'KY173'	,	157.79	;
INSERT INTO #r_factor3 SELECT	'KY179'	,	177.5	;
INSERT INTO #r_factor3 SELECT	'KY183'	,	199.73	;
INSERT INTO #r_factor3 SELECT	'KY185'	,	171.02	;
INSERT INTO #r_factor3 SELECT	'KY195'	,	138.04	;
INSERT INTO #r_factor3 SELECT	'KY199'	,	171.2	;
INSERT INTO #r_factor3 SELECT	'KY207'	,	186.06	;
INSERT INTO #r_factor3 SELECT	'KY209'	,	163.45	;
INSERT INTO #r_factor3 SELECT	'KY211'	,	170.22	;
INSERT INTO #r_factor3 SELECT	'KY213'	,	209.95	;
INSERT INTO #r_factor3 SELECT	'KY219'	,	214.98	;
INSERT INTO #r_factor3 SELECT	'KY227'	,	204.18	;
INSERT INTO #r_factor3 SELECT	'KY229'	,	173.57	;
INSERT INTO #r_factor3 SELECT	'KY231'	,	184.51	;
INSERT INTO #r_factor3 SELECT	'KY601'	,	168.08	;
INSERT INTO #r_factor3 SELECT	'KY602'	,	245.99	;
INSERT INTO #r_factor3 SELECT	'KY603'	,	156.96	;
INSERT INTO #r_factor3 SELECT	'KY604'	,	159.23	;
INSERT INTO #r_factor3 SELECT	'KY605'	,	146.69	;
INSERT INTO #r_factor3 SELECT	'KY606'	,	169.64	;
INSERT INTO #r_factor3 SELECT	'KY607'	,	190.06	;
INSERT INTO #r_factor3 SELECT	'KY608'	,	176.59	;
INSERT INTO #r_factor3 SELECT	'KY610'	,	239.68	;
INSERT INTO #r_factor3 SELECT	'KY611'	,	252.54	;
INSERT INTO #r_factor3 SELECT	'KY612'	,	163.87	;
INSERT INTO #r_factor3 SELECT	'KY615'	,	196.63	;
INSERT INTO #r_factor3 SELECT	'KY616'	,	158.36	;
INSERT INTO #r_factor3 SELECT	'KY618'	,	167.46	;
INSERT INTO #r_factor3 SELECT	'KY619'	,	159.69	;
INSERT INTO #r_factor3 SELECT	'KY620'	,	186.77	;
INSERT INTO #r_factor3 SELECT	'KY621'	,	187.46	;
INSERT INTO #r_factor3 SELECT	'KY622'	,	167.39	;
INSERT INTO #r_factor3 SELECT	'KY623'	,	159.62	;
INSERT INTO #r_factor3 SELECT	'KY624'	,	165.83	;
INSERT INTO #r_factor3 SELECT	'KY626'	,	146.63	;
INSERT INTO #r_factor3 SELECT	'KY627'	,	164.19	;
INSERT INTO #r_factor3 SELECT	'KY628'	,	164.73	;
INSERT INTO #r_factor3 SELECT	'KY629'	,	228.31	;
INSERT INTO #r_factor3 SELECT	'KY630'	,	173.63	;
INSERT INTO #r_factor3 SELECT	'KY631'	,	204.6	;
INSERT INTO #r_factor3 SELECT	'KY633'	,	152.51	;
INSERT INTO #r_factor3 SELECT	'KY634'	,	155.82	;
INSERT INTO #r_factor3 SELECT	'KY635'	,	210	;
INSERT INTO #r_factor3 SELECT	'KY637'	,	156.39	;
INSERT INTO #r_factor3 SELECT	'KY638'	,	155.14	;
INSERT INTO #r_factor3 SELECT	'KY639'	,	145.73	;
INSERT INTO #r_factor3 SELECT	'KY640'	,	144.16	;
INSERT INTO #r_factor3 SELECT	'KY641'	,	150.91	;
INSERT INTO #r_factor3 SELECT	'KY643'	,	163.3	;
INSERT INTO #r_factor3 SELECT	'KY645'	,	153.38	;
INSERT INTO #r_factor3 SELECT	'KY646'	,	201.97	;
INSERT INTO #r_factor3 SELECT	'KY647'	,	195.87	;
INSERT INTO #r_factor3 SELECT	'KY648'	,	200.05	;
INSERT INTO #r_factor3 SELECT	'KY709'	,	201.7	;
INSERT INTO #r_factor3 SELECT	'LA001'	,	609.06	;
INSERT INTO #r_factor3 SELECT	'LA003'	,	541.47	;
INSERT INTO #r_factor3 SELECT	'LA005'	,	681.99	;
INSERT INTO #r_factor3 SELECT	'LA007'	,	694.27	;
INSERT INTO #r_factor3 SELECT	'LA009'	,	510.88	;
INSERT INTO #r_factor3 SELECT	'LA011'	,	525.67	;
INSERT INTO #r_factor3 SELECT	'LA013'	,	400.65	;
INSERT INTO #r_factor3 SELECT	'LA015'	,	375.18	;
INSERT INTO #r_factor3 SELECT	'LA017'	,	375.3	;
INSERT INTO #r_factor3 SELECT	'LA019'	,	574.01	;
INSERT INTO #r_factor3 SELECT	'LA021'	,	428.28	;
INSERT INTO #r_factor3 SELECT	'LA023'	,	605.59	;
INSERT INTO #r_factor3 SELECT	'LA025'	,	462.35	;
INSERT INTO #r_factor3 SELECT	'LA027'	,	377.45	;
INSERT INTO #r_factor3 SELECT	'LA029'	,	483.73	;
INSERT INTO #r_factor3 SELECT	'LA031'	,	405.92	;
INSERT INTO #r_factor3 SELECT	'LA033'	,	625.09	;
INSERT INTO #r_factor3 SELECT	'LA035'	,	394.05	;
INSERT INTO #r_factor3 SELECT	'LA037'	,	570.68	;
INSERT INTO #r_factor3 SELECT	'LA039'	,	545.11	;
INSERT INTO #r_factor3 SELECT	'LA041'	,	432.29	;
INSERT INTO #r_factor3 SELECT	'LA043'	,	453.43	;
INSERT INTO #r_factor3 SELECT	'LA045'	,	662.91	;
INSERT INTO #r_factor3 SELECT	'LA047'	,	655.87	;
INSERT INTO #r_factor3 SELECT	'LA049'	,	407.72	;
INSERT INTO #r_factor3 SELECT	'LA051'	,	714.3	;
INSERT INTO #r_factor3 SELECT	'LA053'	,	594.2	;
INSERT INTO #r_factor3 SELECT	'LA055'	,	628	;
INSERT INTO #r_factor3 SELECT	'LA057'	,	711.85	;
INSERT INTO #r_factor3 SELECT	'LA059'	,	455.74	;
INSERT INTO #r_factor3 SELECT	'LA061'	,	393.76	;
INSERT INTO #r_factor3 SELECT	'LA063'	,	660.3	;
INSERT INTO #r_factor3 SELECT	'LA065'	,	415.77	;
INSERT INTO #r_factor3 SELECT	'LA067'	,	391.03	;
INSERT INTO #r_factor3 SELECT	'LA069'	,	436.09	;
INSERT INTO #r_factor3 SELECT	'LA071'	,	710.49	;
INSERT INTO #r_factor3 SELECT	'LA073'	,	405.05	;
INSERT INTO #r_factor3 SELECT	'LA075'	,	702.11	;
INSERT INTO #r_factor3 SELECT	'LA077'	,	576.59	;
INSERT INTO #r_factor3 SELECT	'LA079'	,	486.5	;
INSERT INTO #r_factor3 SELECT	'LA081'	,	409.61	;
INSERT INTO #r_factor3 SELECT	'LA083'	,	411.61	;
INSERT INTO #r_factor3 SELECT	'LA085'	,	437.71	;
INSERT INTO #r_factor3 SELECT	'LA087'	,	695.93	;
INSERT INTO #r_factor3 SELECT	'LA089'	,	714.87	;
INSERT INTO #r_factor3 SELECT	'LA091'	,	583.64	;
INSERT INTO #r_factor3 SELECT	'LA093'	,	700.29	;
INSERT INTO #r_factor3 SELECT	'LA095'	,	706.42	;
INSERT INTO #r_factor3 SELECT	'LA097'	,	581.69	;
INSERT INTO #r_factor3 SELECT	'LA099'	,	653.16	;
INSERT INTO #r_factor3 SELECT	'LA101'	,	684.58	;
INSERT INTO #r_factor3 SELECT	'LA103'	,	681.3	;
INSERT INTO #r_factor3 SELECT	'LA105'	,	632.4	;
INSERT INTO #r_factor3 SELECT	'LA107'	,	442.13	;
INSERT INTO #r_factor3 SELECT	'LA109'	,	706.16	;
INSERT INTO #r_factor3 SELECT	'LA111'	,	386.61	;
INSERT INTO #r_factor3 SELECT	'LA113'	,	639.54	;
INSERT INTO #r_factor3 SELECT	'LA115'	,	481.05	;
INSERT INTO #r_factor3 SELECT	'LA117'	,	594.36	;
INSERT INTO #r_factor3 SELECT	'LA119'	,	378.12	;
INSERT INTO #r_factor3 SELECT	'LA121'	,	630.47	;
INSERT INTO #r_factor3 SELECT	'LA123'	,	391.79	;
INSERT INTO #r_factor3 SELECT	'LA125'	,	554.27	;
INSERT INTO #r_factor3 SELECT	'LA127'	,	428.57	;
INSERT INTO #r_factor3 SELECT	'MA001'	,	128.99	;
INSERT INTO #r_factor3 SELECT	'MA003'	,	114.64	;
INSERT INTO #r_factor3 SELECT	'MA007'	,	148.16	;
INSERT INTO #r_factor3 SELECT	'MA011'	,	106.46	;
INSERT INTO #r_factor3 SELECT	'MA017'	,	112.17	;
INSERT INTO #r_factor3 SELECT	'MA019'	,	145.92	;
INSERT INTO #r_factor3 SELECT	'MA023'	,	124.07	;
INSERT INTO #r_factor3 SELECT	'MA602'	,	128.75	;
INSERT INTO #r_factor3 SELECT	'MA603'	,	139.64	;
INSERT INTO #r_factor3 SELECT	'MA605'	,	107.95	;
INSERT INTO #r_factor3 SELECT	'MA606'	,	110.9	;
INSERT INTO #r_factor3 SELECT	'MA607'	,	124.36	;
INSERT INTO #r_factor3 SELECT	'MA608'	,	118.39	;
INSERT INTO #r_factor3 SELECT	'MA609'	,	117.16	;
INSERT INTO #r_factor3 SELECT	'MA610'	,	121.64	;
INSERT INTO #r_factor3 SELECT	'MA613'	,	114.13	;
INSERT INTO #r_factor3 SELECT	'MA614'	,	109.5	;
INSERT INTO #r_factor3 SELECT	'MA615'	,	123.57	;
INSERT INTO #r_factor3 SELECT	'MA616'	,	119.44	;
INSERT INTO #r_factor3 SELECT	'MD001'	,	115.38	;
INSERT INTO #r_factor3 SELECT	'MD003'	,	185.93	;
INSERT INTO #r_factor3 SELECT	'MD005'	,	176.49	;
INSERT INTO #r_factor3 SELECT	'MD009'	,	192.9	;
INSERT INTO #r_factor3 SELECT	'MD011'	,	188.49	;
INSERT INTO #r_factor3 SELECT	'MD013'	,	157.09	;
INSERT INTO #r_factor3 SELECT	'MD015'	,	181.82	;
INSERT INTO #r_factor3 SELECT	'MD017'	,	189.47	;
INSERT INTO #r_factor3 SELECT	'MD019'	,	195.52	;
INSERT INTO #r_factor3 SELECT	'MD021'	,	148.87	;
INSERT INTO #r_factor3 SELECT	'MD023'	,	113.52	;
INSERT INTO #r_factor3 SELECT	'MD027'	,	175.33	;
INSERT INTO #r_factor3 SELECT	'MD029'	,	186.17	;
INSERT INTO #r_factor3 SELECT	'MD031'	,	170.11	;
INSERT INTO #r_factor3 SELECT	'MD033'	,	184.9	;
INSERT INTO #r_factor3 SELECT	'MD035'	,	187.69	;
INSERT INTO #r_factor3 SELECT	'MD037'	,	199.37	;
INSERT INTO #r_factor3 SELECT	'MD039'	,	208.33	;
INSERT INTO #r_factor3 SELECT	'MD041'	,	190.47	;
INSERT INTO #r_factor3 SELECT	'MD043'	,	131.32	;
INSERT INTO #r_factor3 SELECT	'MD045'	,	194.44	;
INSERT INTO #r_factor3 SELECT	'MD047'	,	199.5	;
INSERT INTO #r_factor3 SELECT	'MD510'	,	181.4	;
INSERT INTO #r_factor3 SELECT	'MD600'	,	179.99	;
INSERT INTO #r_factor3 SELECT	'MD601'	,	184.94	;
INSERT INTO #r_factor3 SELECT	'ME005'	,	95.08	;
INSERT INTO #r_factor3 SELECT	'ME011'	,	86.778	;
INSERT INTO #r_factor3 SELECT	'ME027'	,	87	;
INSERT INTO #r_factor3 SELECT	'ME031'	,	100.26	;
INSERT INTO #r_factor3 SELECT	'ME601'	,	93.238	;
INSERT INTO #r_factor3 SELECT	'ME602'	,	81.767	;
INSERT INTO #r_factor3 SELECT	'ME606'	,	91.541	;
INSERT INTO #r_factor3 SELECT	'ME607'	,	79.807	;
INSERT INTO #r_factor3 SELECT	'ME608'	,	79.57	;
INSERT INTO #r_factor3 SELECT	'ME610'	,	79.971	;
INSERT INTO #r_factor3 SELECT	'ME611'	,	88.567	;
INSERT INTO #r_factor3 SELECT	'ME612'	,	82.685	;
INSERT INTO #r_factor3 SELECT	'ME613'	,	84.948	;
INSERT INTO #r_factor3 SELECT	'ME614'	,	79.835	;
INSERT INTO #r_factor3 SELECT	'ME615'	,	79.843	;
INSERT INTO #r_factor3 SELECT	'ME617'	,	86.285	;
INSERT INTO #r_factor3 SELECT	'ME619'	,	77.321	;
INSERT INTO #r_factor3 SELECT	'ME620'	,	77.381	;
INSERT INTO #r_factor3 SELECT	'ME621'	,	77.17	;
INSERT INTO #r_factor3 SELECT	'ME622'	,	82.306	;
INSERT INTO #r_factor3 SELECT	'MI001'	,	77.892	;
INSERT INTO #r_factor3 SELECT	'MI003'	,	80.691	;
INSERT INTO #r_factor3 SELECT	'MI005'	,	107.06	;
INSERT INTO #r_factor3 SELECT	'MI007'	,	76.356	;
INSERT INTO #r_factor3 SELECT	'MI009'	,	80.053	;
INSERT INTO #r_factor3 SELECT	'MI011'	,	80.271	;
INSERT INTO #r_factor3 SELECT	'MI013'	,	84.955	;
INSERT INTO #r_factor3 SELECT	'MI015'	,	101.44	;
INSERT INTO #r_factor3 SELECT	'MI017'	,	82.036	;
INSERT INTO #r_factor3 SELECT	'MI021'	,	135.91	;
INSERT INTO #r_factor3 SELECT	'MI023'	,	114.15	;
INSERT INTO #r_factor3 SELECT	'MI025'	,	106.39	;
INSERT INTO #r_factor3 SELECT	'MI027'	,	128.77	;
INSERT INTO #r_factor3 SELECT	'MI029'	,	79.614	;
INSERT INTO #r_factor3 SELECT	'MI031'	,	77.7	;
INSERT INTO #r_factor3 SELECT	'MI033'	,	75.284	;
INSERT INTO #r_factor3 SELECT	'MI035'	,	82.415	;
INSERT INTO #r_factor3 SELECT	'MI037'	,	93.297	;
INSERT INTO #r_factor3 SELECT	'MI039'	,	79.966	;
INSERT INTO #r_factor3 SELECT	'MI041'	,	81.993	;
INSERT INTO #r_factor3 SELECT	'MI043'	,	84.926	;
INSERT INTO #r_factor3 SELECT	'MI045'	,	99.242	;
INSERT INTO #r_factor3 SELECT	'MI047'	,	78.666	;
INSERT INTO #r_factor3 SELECT	'MI049'	,	89.334	;
INSERT INTO #r_factor3 SELECT	'MI051'	,	81.427	;
INSERT INTO #r_factor3 SELECT	'MI053'	,	92.502	;
INSERT INTO #r_factor3 SELECT	'MI055'	,	81.176	;
INSERT INTO #r_factor3 SELECT	'MI057'	,	88.027	;
INSERT INTO #r_factor3 SELECT	'MI059'	,	109.19	;
INSERT INTO #r_factor3 SELECT	'MI061'	,	85.208	;
INSERT INTO #r_factor3 SELECT	'MI063'	,	79.569	;
INSERT INTO #r_factor3 SELECT	'MI065'	,	97.995	;
INSERT INTO #r_factor3 SELECT	'MI067'	,	94.723	;
INSERT INTO #r_factor3 SELECT	'MI069'	,	79.225	;
INSERT INTO #r_factor3 SELECT	'MI071'	,	87.288	;
INSERT INTO #r_factor3 SELECT	'MI073'	,	84.855	;
INSERT INTO #r_factor3 SELECT	'MI075'	,	102.61	;
INSERT INTO #r_factor3 SELECT	'MI077'	,	112.5	;
INSERT INTO #r_factor3 SELECT	'MI079'	,	80.51	;
INSERT INTO #r_factor3 SELECT	'MI081'	,	94.875	;
INSERT INTO #r_factor3 SELECT	'MI087'	,	86.412	;
INSERT INTO #r_factor3 SELECT	'MI089'	,	80.97	;
INSERT INTO #r_factor3 SELECT	'MI091'	,	104.66	;
INSERT INTO #r_factor3 SELECT	'MI093'	,	96.871	;
INSERT INTO #r_factor3 SELECT	'MI095'	,	78.459	;
INSERT INTO #r_factor3 SELECT	'MI097'	,	77.839	;
INSERT INTO #r_factor3 SELECT	'MI099'	,	91.032	;
INSERT INTO #r_factor3 SELECT	'MI103'	,	83.259	;
INSERT INTO #r_factor3 SELECT	'MI105'	,	85.648	;
INSERT INTO #r_factor3 SELECT	'MI107'	,	86.037	;
INSERT INTO #r_factor3 SELECT	'MI109'	,	84.549	;
INSERT INTO #r_factor3 SELECT	'MI111'	,	83.56	;
INSERT INTO #r_factor3 SELECT	'MI113'	,	81.384	;
INSERT INTO #r_factor3 SELECT	'MI115'	,	101.35	;
INSERT INTO #r_factor3 SELECT	'MI117'	,	89.267	;
INSERT INTO #r_factor3 SELECT	'MI119'	,	77.985	;
INSERT INTO #r_factor3 SELECT	'MI121'	,	92.675	;
INSERT INTO #r_factor3 SELECT	'MI123'	,	88.156	;
INSERT INTO #r_factor3 SELECT	'MI125'	,	93.723	;
INSERT INTO #r_factor3 SELECT	'MI127'	,	88.689	;
INSERT INTO #r_factor3 SELECT	'MI129'	,	80.067	;
INSERT INTO #r_factor3 SELECT	'MI131'	,	88.765	;
INSERT INTO #r_factor3 SELECT	'MI133'	,	83.421	;
INSERT INTO #r_factor3 SELECT	'MI135'	,	79.246	;
INSERT INTO #r_factor3 SELECT	'MI137'	,	79.186	;
INSERT INTO #r_factor3 SELECT	'MI139'	,	97.878	;
INSERT INTO #r_factor3 SELECT	'MI141'	,	76.005	;
INSERT INTO #r_factor3 SELECT	'MI143'	,	80.64	;
INSERT INTO #r_factor3 SELECT	'MI145'	,	85.901	;
INSERT INTO #r_factor3 SELECT	'MI147'	,	86.48	;
INSERT INTO #r_factor3 SELECT	'MI149'	,	121.44	;
INSERT INTO #r_factor3 SELECT	'MI151'	,	81.454	;
INSERT INTO #r_factor3 SELECT	'MI153'	,	80.176	;
INSERT INTO #r_factor3 SELECT	'MI155'	,	91.933	;
INSERT INTO #r_factor3 SELECT	'MI157'	,	82.479	;
INSERT INTO #r_factor3 SELECT	'MI159'	,	120.86	;
INSERT INTO #r_factor3 SELECT	'MI161'	,	100.39	;
INSERT INTO #r_factor3 SELECT	'MI163'	,	98.198	;
INSERT INTO #r_factor3 SELECT	'MI600'	,	83.323	;
INSERT INTO #r_factor3 SELECT	'MI605'	,	82.004	;
INSERT INTO #r_factor3 SELECT	'MI606'	,	81.122	;
INSERT INTO #r_factor3 SELECT	'MI614'	,	82.732	;
INSERT INTO #r_factor3 SELECT	'MN001'	,	88.502	;
INSERT INTO #r_factor3 SELECT	'MN003'	,	107.87	;
INSERT INTO #r_factor3 SELECT	'MN005'	,	79.517	;
INSERT INTO #r_factor3 SELECT	'MN007'	,	74.534	;
INSERT INTO #r_factor3 SELECT	'MN009'	,	93.458	;
INSERT INTO #r_factor3 SELECT	'MN011'	,	87.689	;
INSERT INTO #r_factor3 SELECT	'MN013'	,	125.67	;
INSERT INTO #r_factor3 SELECT	'MN015'	,	117	;
INSERT INTO #r_factor3 SELECT	'MN017'	,	93.357	;
INSERT INTO #r_factor3 SELECT	'MN019'	,	109.37	;
INSERT INTO #r_factor3 SELECT	'MN021'	,	83.23	;
INSERT INTO #r_factor3 SELECT	'MN023'	,	95.685	;
INSERT INTO #r_factor3 SELECT	'MN025'	,	108.94	;
INSERT INTO #r_factor3 SELECT	'MN027'	,	73.967	;
INSERT INTO #r_factor3 SELECT	'MN029'	,	75.7	;
INSERT INTO #r_factor3 SELECT	'MN031'	,	84.402	;
INSERT INTO #r_factor3 SELECT	'MN033'	,	121.07	;
INSERT INTO #r_factor3 SELECT	'MN035'	,	86.62	;
INSERT INTO #r_factor3 SELECT	'MN037'	,	122.5	;
INSERT INTO #r_factor3 SELECT	'MN039'	,	143.34	;
INSERT INTO #r_factor3 SELECT	'MN041'	,	87.332	;
INSERT INTO #r_factor3 SELECT	'MN043'	,	133.62	;
INSERT INTO #r_factor3 SELECT	'MN045'	,	155.06	;
INSERT INTO #r_factor3 SELECT	'MN047'	,	141.33	;
INSERT INTO #r_factor3 SELECT	'MN049'	,	135.67	;
INSERT INTO #r_factor3 SELECT	'MN051'	,	85.369	;
INSERT INTO #r_factor3 SELECT	'MN053'	,	109.46	;
INSERT INTO #r_factor3 SELECT	'MN055'	,	156.43	;
INSERT INTO #r_factor3 SELECT	'MN057'	,	81.105	;
INSERT INTO #r_factor3 SELECT	'MN059'	,	102.34	;
INSERT INTO #r_factor3 SELECT	'MN061'	,	82.431	;
INSERT INTO #r_factor3 SELECT	'MN063'	,	127.23	;
INSERT INTO #r_factor3 SELECT	'MN065'	,	95.857	;
INSERT INTO #r_factor3 SELECT	'MN067'	,	96.209	;
INSERT INTO #r_factor3 SELECT	'MN069'	,	63.738	;
INSERT INTO #r_factor3 SELECT	'MN073'	,	93.027	;
INSERT INTO #r_factor3 SELECT	'MN075'	,	86.514	;
INSERT INTO #r_factor3 SELECT	'MN077'	,	69.23	;
INSERT INTO #r_factor3 SELECT	'MN079'	,	121.79	;
INSERT INTO #r_factor3 SELECT	'MN081'	,	101.35	;
INSERT INTO #r_factor3 SELECT	'MN083'	,	104.24	;
INSERT INTO #r_factor3 SELECT	'MN085'	,	104.37	;
INSERT INTO #r_factor3 SELECT	'MN087'	,	75.046	;
INSERT INTO #r_factor3 SELECT	'MN089'	,	66.184	;
INSERT INTO #r_factor3 SELECT	'MN091'	,	129.19	;
INSERT INTO #r_factor3 SELECT	'MN093'	,	98.201	;
INSERT INTO #r_factor3 SELECT	'MN095'	,	93.288	;
INSERT INTO #r_factor3 SELECT	'MN097'	,	89.53	;
INSERT INTO #r_factor3 SELECT	'MN099'	,	149.42	;
INSERT INTO #r_factor3 SELECT	'MN101'	,	117.29	;
INSERT INTO #r_factor3 SELECT	'MN103'	,	117.72	;
INSERT INTO #r_factor3 SELECT	'MN105'	,	125.21	;
INSERT INTO #r_factor3 SELECT	'MN107'	,	70.075	;
INSERT INTO #r_factor3 SELECT	'MN109'	,	150.39	;
INSERT INTO #r_factor3 SELECT	'MN111'	,	83.311	;
INSERT INTO #r_factor3 SELECT	'MN113'	,	68.326	;
INSERT INTO #r_factor3 SELECT	'MN115'	,	99.051	;
INSERT INTO #r_factor3 SELECT	'MN117'	,	111.52	;
INSERT INTO #r_factor3 SELECT	'MN119'	,	68.541	;
INSERT INTO #r_factor3 SELECT	'MN121'	,	90.134	;
INSERT INTO #r_factor3 SELECT	'MN123'	,	115.05	;
INSERT INTO #r_factor3 SELECT	'MN125'	,	68.983	;
INSERT INTO #r_factor3 SELECT	'MN127'	,	108.37	;
INSERT INTO #r_factor3 SELECT	'MN129'	,	102.31	;
INSERT INTO #r_factor3 SELECT	'MN131'	,	126.33	;
INSERT INTO #r_factor3 SELECT	'MN133'	,	119.88	;
INSERT INTO #r_factor3 SELECT	'MN135'	,	66.171	;
INSERT INTO #r_factor3 SELECT	'MN139'	,	116.94	;
INSERT INTO #r_factor3 SELECT	'MN141'	,	98.808	;
INSERT INTO #r_factor3 SELECT	'MN143'	,	111.36	;
INSERT INTO #r_factor3 SELECT	'MN145'	,	92.674	;
INSERT INTO #r_factor3 SELECT	'MN147'	,	135.93	;
INSERT INTO #r_factor3 SELECT	'MN149'	,	88.22	;
INSERT INTO #r_factor3 SELECT	'MN151'	,	92.143	;
INSERT INTO #r_factor3 SELECT	'MN153'	,	87.61	;
INSERT INTO #r_factor3 SELECT	'MN155'	,	84.639	;
INSERT INTO #r_factor3 SELECT	'MN157'	,	148.24	;
INSERT INTO #r_factor3 SELECT	'MN159'	,	84.274	;
INSERT INTO #r_factor3 SELECT	'MN161'	,	130.03	;
INSERT INTO #r_factor3 SELECT	'MN163'	,	118.88	;
INSERT INTO #r_factor3 SELECT	'MN165'	,	123.96	;
INSERT INTO #r_factor3 SELECT	'MN167'	,	79.915	;
INSERT INTO #r_factor3 SELECT	'MN169'	,	155.02	;
INSERT INTO #r_factor3 SELECT	'MN171'	,	100.85	;
INSERT INTO #r_factor3 SELECT	'MN173'	,	98.361	;
INSERT INTO #r_factor3 SELECT	'MN613'	,	81.744	;
INSERT INTO #r_factor3 SELECT	'MN615'	,	90.826	;
INSERT INTO #r_factor3 SELECT	'MN617'	,	85.889	;
INSERT INTO #r_factor3 SELECT	'MN619'	,	88.635	;
INSERT INTO #r_factor3 SELECT	'MN621'	,	84.28	;
INSERT INTO #r_factor3 SELECT	'MN625'	,	77.898	;
INSERT INTO #r_factor3 SELECT	'MN627'	,	79.49	;
INSERT INTO #r_factor3 SELECT	'MO001'	,	183.93	;
INSERT INTO #r_factor3 SELECT	'MO003'	,	188.84	;
INSERT INTO #r_factor3 SELECT	'MO005'	,	176.76	;
INSERT INTO #r_factor3 SELECT	'MO007'	,	198.29	;
INSERT INTO #r_factor3 SELECT	'MO009'	,	250.95	;
INSERT INTO #r_factor3 SELECT	'MO011'	,	235.38	;
INSERT INTO #r_factor3 SELECT	'MO013'	,	211.7	;
INSERT INTO #r_factor3 SELECT	'MO015'	,	216.07	;
INSERT INTO #r_factor3 SELECT	'MO017'	,	244.15	;
INSERT INTO #r_factor3 SELECT	'MO019'	,	202.77	;
INSERT INTO #r_factor3 SELECT	'MO021'	,	192.63	;
INSERT INTO #r_factor3 SELECT	'MO023'	,	255.71	;
INSERT INTO #r_factor3 SELECT	'MO025'	,	194.2	;
INSERT INTO #r_factor3 SELECT	'MO027'	,	204.05	;
INSERT INTO #r_factor3 SELECT	'MO029'	,	223.34	;
INSERT INTO #r_factor3 SELECT	'MO031'	,	243.42	;
INSERT INTO #r_factor3 SELECT	'MO033'	,	197.41	;
INSERT INTO #r_factor3 SELECT	'MO035'	,	248.16	;
INSERT INTO #r_factor3 SELECT	'MO037'	,	202.51	;
INSERT INTO #r_factor3 SELECT	'MO039'	,	228.11	;
INSERT INTO #r_factor3 SELECT	'MO041'	,	196.7	;
INSERT INTO #r_factor3 SELECT	'MO043'	,	242.72	;
INSERT INTO #r_factor3 SELECT	'MO045'	,	177.94	;
INSERT INTO #r_factor3 SELECT	'MO047'	,	196.75	;
INSERT INTO #r_factor3 SELECT	'MO049'	,	194.35	;
INSERT INTO #r_factor3 SELECT	'MO051'	,	212.26	;
INSERT INTO #r_factor3 SELECT	'MO053'	,	205.84	;
INSERT INTO #r_factor3 SELECT	'MO055'	,	220.31	;
INSERT INTO #r_factor3 SELECT	'MO057'	,	236.57	;
INSERT INTO #r_factor3 SELECT	'MO059'	,	228.6	;
INSERT INTO #r_factor3 SELECT	'MO061'	,	190.12	;
INSERT INTO #r_factor3 SELECT	'MO063'	,	190.98	;
INSERT INTO #r_factor3 SELECT	'MO065'	,	229.18	;
INSERT INTO #r_factor3 SELECT	'MO067'	,	241.17	;
INSERT INTO #r_factor3 SELECT	'MO069'	,	267.46	;
INSERT INTO #r_factor3 SELECT	'MO071'	,	208.28	;
INSERT INTO #r_factor3 SELECT	'MO073'	,	210.56	;
INSERT INTO #r_factor3 SELECT	'MO075'	,	186.06	;
INSERT INTO #r_factor3 SELECT	'MO077'	,	237.85	;
INSERT INTO #r_factor3 SELECT	'MO079'	,	187.41	;
INSERT INTO #r_factor3 SELECT	'MO081'	,	184.03	;
INSERT INTO #r_factor3 SELECT	'MO083'	,	210.51	;
INSERT INTO #r_factor3 SELECT	'MO085'	,	223.78	;
INSERT INTO #r_factor3 SELECT	'MO087'	,	184.86	;
INSERT INTO #r_factor3 SELECT	'MO089'	,	201.24	;
INSERT INTO #r_factor3 SELECT	'MO091'	,	246.29	;
INSERT INTO #r_factor3 SELECT	'MO093'	,	231.53	;
INSERT INTO #r_factor3 SELECT	'MO095'	,	198.84	;
INSERT INTO #r_factor3 SELECT	'MO097'	,	245.69	;
INSERT INTO #r_factor3 SELECT	'MO099'	,	209.68	;
INSERT INTO #r_factor3 SELECT	'MO101'	,	203.07	;
INSERT INTO #r_factor3 SELECT	'MO103'	,	183.4	;
INSERT INTO #r_factor3 SELECT	'MO105'	,	228.97	;
INSERT INTO #r_factor3 SELECT	'MO107'	,	199.8	;
INSERT INTO #r_factor3 SELECT	'MO109'	,	244.7	;
INSERT INTO #r_factor3 SELECT	'MO111'	,	182.04	;
INSERT INTO #r_factor3 SELECT	'MO113'	,	196.87	;
INSERT INTO #r_factor3 SELECT	'MO115'	,	190.7	;
INSERT INTO #r_factor3 SELECT	'MO117'	,	192.52	;
INSERT INTO #r_factor3 SELECT	'MO119'	,	256.52	;
INSERT INTO #r_factor3 SELECT	'MO121'	,	190.22	;
INSERT INTO #r_factor3 SELECT	'MO123'	,	235.93	;
INSERT INTO #r_factor3 SELECT	'MO125'	,	219.5	;
INSERT INTO #r_factor3 SELECT	'MO127'	,	186.34	;
INSERT INTO #r_factor3 SELECT	'MO129'	,	182.6	;
INSERT INTO #r_factor3 SELECT	'MO131'	,	219.67	;
INSERT INTO #r_factor3 SELECT	'MO133'	,	255.41	;
INSERT INTO #r_factor3 SELECT	'MO135'	,	210.06	;
INSERT INTO #r_factor3 SELECT	'MO137'	,	194.15	;
INSERT INTO #r_factor3 SELECT	'MO139'	,	200.75	;
INSERT INTO #r_factor3 SELECT	'MO141'	,	214.72	;
INSERT INTO #r_factor3 SELECT	'MO143'	,	260.78	;
INSERT INTO #r_factor3 SELECT	'MO145'	,	252.05	;
INSERT INTO #r_factor3 SELECT	'MO147'	,	181.96	;
INSERT INTO #r_factor3 SELECT	'MO149'	,	250.29	;
INSERT INTO #r_factor3 SELECT	'MO151'	,	211.88	;
INSERT INTO #r_factor3 SELECT	'MO153'	,	245.68	;
INSERT INTO #r_factor3 SELECT	'MO155'	,	268.04	;
INSERT INTO #r_factor3 SELECT	'MO157'	,	228.01	;
INSERT INTO #r_factor3 SELECT	'MO159'	,	206.66	;
INSERT INTO #r_factor3 SELECT	'MO161'	,	224.44	;
INSERT INTO #r_factor3 SELECT	'MO163'	,	192.64	;
INSERT INTO #r_factor3 SELECT	'MO165'	,	195.24	;
INSERT INTO #r_factor3 SELECT	'MO167'	,	230.01	;
INSERT INTO #r_factor3 SELECT	'MO169'	,	226.46	;
INSERT INTO #r_factor3 SELECT	'MO171'	,	180.59	;
INSERT INTO #r_factor3 SELECT	'MO173'	,	191.08	;
INSERT INTO #r_factor3 SELECT	'MO175'	,	197.23	;
INSERT INTO #r_factor3 SELECT	'MO177'	,	197.24	;
INSERT INTO #r_factor3 SELECT	'MO179'	,	237.18	;
INSERT INTO #r_factor3 SELECT	'MO181'	,	253.6	;
INSERT INTO #r_factor3 SELECT	'MO183'	,	199.51	;
INSERT INTO #r_factor3 SELECT	'MO185'	,	219.87	;
INSERT INTO #r_factor3 SELECT	'MO187'	,	223.78	;
INSERT INTO #r_factor3 SELECT	'MO189'	,	200.5	;
INSERT INTO #r_factor3 SELECT	'MO193'	,	221.27	;
INSERT INTO #r_factor3 SELECT	'MO195'	,	200.85	;
INSERT INTO #r_factor3 SELECT	'MO197'	,	179.4	;
INSERT INTO #r_factor3 SELECT	'MO199'	,	178.59	;
INSERT INTO #r_factor3 SELECT	'MO201'	,	252.79	;
INSERT INTO #r_factor3 SELECT	'MO203'	,	240.84	;
INSERT INTO #r_factor3 SELECT	'MO205'	,	188.85	;
INSERT INTO #r_factor3 SELECT	'MO207'	,	255.78	;
INSERT INTO #r_factor3 SELECT	'MO209'	,	247.85	;
INSERT INTO #r_factor3 SELECT	'MO211'	,	184.97	;
INSERT INTO #r_factor3 SELECT	'MO213'	,	247.11	;
INSERT INTO #r_factor3 SELECT	'MO215'	,	235.16	;
INSERT INTO #r_factor3 SELECT	'MO217'	,	224.01	;
INSERT INTO #r_factor3 SELECT	'MO219'	,	201.82	;
INSERT INTO #r_factor3 SELECT	'MO221'	,	218.95	;
INSERT INTO #r_factor3 SELECT	'MO223'	,	247.71	;
INSERT INTO #r_factor3 SELECT	'MO225'	,	235.58	;
INSERT INTO #r_factor3 SELECT	'MO227'	,	181.36	;
INSERT INTO #r_factor3 SELECT	'MO229'	,	235.12	;
INSERT INTO #r_factor3 SELECT	'MS001'	,	485.48	;
INSERT INTO #r_factor3 SELECT	'MS003'	,	291.98	;
INSERT INTO #r_factor3 SELECT	'MS005'	,	529.27	;
INSERT INTO #r_factor3 SELECT	'MS007'	,	391.29	;
INSERT INTO #r_factor3 SELECT	'MS009'	,	299.37	;
INSERT INTO #r_factor3 SELECT	'MS011'	,	355.38	;
INSERT INTO #r_factor3 SELECT	'MS013'	,	346.97	;
INSERT INTO #r_factor3 SELECT	'MS015'	,	370.54	;
INSERT INTO #r_factor3 SELECT	'MS017'	,	345.9	;
INSERT INTO #r_factor3 SELECT	'MS019'	,	376.87	;
INSERT INTO #r_factor3 SELECT	'MS021'	,	445.03	;
INSERT INTO #r_factor3 SELECT	'MS023'	,	465.87	;
INSERT INTO #r_factor3 SELECT	'MS025'	,	358.69	;
INSERT INTO #r_factor3 SELECT	'MS027'	,	337	;
INSERT INTO #r_factor3 SELECT	'MS029'	,	463.86	;
INSERT INTO #r_factor3 SELECT	'MS031'	,	501.92	;
INSERT INTO #r_factor3 SELECT	'MS033'	,	302.1	;
INSERT INTO #r_factor3 SELECT	'MS035'	,	553.98	;
INSERT INTO #r_factor3 SELECT	'MS037'	,	494.17	;
INSERT INTO #r_factor3 SELECT	'MS039'	,	600.65	;
INSERT INTO #r_factor3 SELECT	'MS041'	,	551.25	;
INSERT INTO #r_factor3 SELECT	'MS043'	,	356.7	;
INSERT INTO #r_factor3 SELECT	'MS045'	,	677.14	;
INSERT INTO #r_factor3 SELECT	'MS047'	,	663.3	;
INSERT INTO #r_factor3 SELECT	'MS049'	,	429.48	;
INSERT INTO #r_factor3 SELECT	'MS051'	,	385.93	;
INSERT INTO #r_factor3 SELECT	'MS053'	,	381.49	;
INSERT INTO #r_factor3 SELECT	'MS055'	,	394.01	;
INSERT INTO #r_factor3 SELECT	'MS057'	,	321.64	;
INSERT INTO #r_factor3 SELECT	'MS059'	,	638.46	;
INSERT INTO #r_factor3 SELECT	'MS061'	,	468.68	;
INSERT INTO #r_factor3 SELECT	'MS063'	,	465.77	;
INSERT INTO #r_factor3 SELECT	'MS065'	,	504.92	;
INSERT INTO #r_factor3 SELECT	'MS067'	,	505.62	;
INSERT INTO #r_factor3 SELECT	'MS069'	,	412.33	;
INSERT INTO #r_factor3 SELECT	'MS071'	,	323.42	;
INSERT INTO #r_factor3 SELECT	'MS073'	,	548.68	;
INSERT INTO #r_factor3 SELECT	'MS075'	,	437.24	;
INSERT INTO #r_factor3 SELECT	'MS077'	,	503.38	;
INSERT INTO #r_factor3 SELECT	'MS079'	,	410.36	;
INSERT INTO #r_factor3 SELECT	'MS081'	,	322.46	;
INSERT INTO #r_factor3 SELECT	'MS083'	,	365.41	;
INSERT INTO #r_factor3 SELECT	'MS085'	,	498.81	;
INSERT INTO #r_factor3 SELECT	'MS087'	,	367.5	;
INSERT INTO #r_factor3 SELECT	'MS089'	,	410.83	;
INSERT INTO #r_factor3 SELECT	'MS091'	,	541.53	;
INSERT INTO #r_factor3 SELECT	'MS093'	,	303.67	;
INSERT INTO #r_factor3 SELECT	'MS095'	,	344.94	;
INSERT INTO #r_factor3 SELECT	'MS097'	,	369.09	;
INSERT INTO #r_factor3 SELECT	'MS099'	,	412.73	;
INSERT INTO #r_factor3 SELECT	'MS101'	,	437.45	;
INSERT INTO #r_factor3 SELECT	'MS103'	,	388.43	;
INSERT INTO #r_factor3 SELECT	'MS105'	,	371.75	;
INSERT INTO #r_factor3 SELECT	'MS107'	,	326.15	;
INSERT INTO #r_factor3 SELECT	'MS109'	,	619.79	;
INSERT INTO #r_factor3 SELECT	'MS111'	,	557.62	;
INSERT INTO #r_factor3 SELECT	'MS113'	,	538.37	;
INSERT INTO #r_factor3 SELECT	'MS115'	,	328.83	;
INSERT INTO #r_factor3 SELECT	'MS117'	,	302.43	;
INSERT INTO #r_factor3 SELECT	'MS119'	,	334.29	;
INSERT INTO #r_factor3 SELECT	'MS121'	,	439.55	;
INSERT INTO #r_factor3 SELECT	'MS123'	,	434.76	;
INSERT INTO #r_factor3 SELECT	'MS125'	,	389.19	;
INSERT INTO #r_factor3 SELECT	'MS127'	,	469.97	;
INSERT INTO #r_factor3 SELECT	'MS129'	,	466.62	;
INSERT INTO #r_factor3 SELECT	'MS131'	,	619.52	;
INSERT INTO #r_factor3 SELECT	'MS133'	,	362.84	;
INSERT INTO #r_factor3 SELECT	'MS135'	,	348.85	;
INSERT INTO #r_factor3 SELECT	'MS137'	,	311.13	;
INSERT INTO #r_factor3 SELECT	'MS139'	,	299.02	;
INSERT INTO #r_factor3 SELECT	'MS141'	,	295.12	;
INSERT INTO #r_factor3 SELECT	'MS143'	,	314.07	;
INSERT INTO #r_factor3 SELECT	'MS145'	,	312.46	;
INSERT INTO #r_factor3 SELECT	'MS147'	,	547.23	;
INSERT INTO #r_factor3 SELECT	'MS149'	,	416.19	;
INSERT INTO #r_factor3 SELECT	'MS151'	,	373.24	;
INSERT INTO #r_factor3 SELECT	'MS153'	,	502.77	;
INSERT INTO #r_factor3 SELECT	'MS155'	,	363.34	;
INSERT INTO #r_factor3 SELECT	'MS157'	,	519.09	;
INSERT INTO #r_factor3 SELECT	'MS159'	,	391.39	;
INSERT INTO #r_factor3 SELECT	'MS161'	,	343.68	;
INSERT INTO #r_factor3 SELECT	'MS163'	,	398.28	;
INSERT INTO #r_factor3 SELECT	'MT011'	,	25.385	;
INSERT INTO #r_factor3 SELECT	'MT017'	,	21.896	;
INSERT INTO #r_factor3 SELECT	'MT021'	,	31.665	;
INSERT INTO #r_factor3 SELECT	'MT025'	,	27.811	;
INSERT INTO #r_factor3 SELECT	'MT027'	,	11.119	;
INSERT INTO #r_factor3 SELECT	'MT033'	,	25.548	;
INSERT INTO #r_factor3 SELECT	'MT041'	,	14.52	;
INSERT INTO #r_factor3 SELECT	'MT051'	,	13.635	;
INSERT INTO #r_factor3 SELECT	'MT055'	,	35.976	;
INSERT INTO #r_factor3 SELECT	'MT065'	,	14.987	;
INSERT INTO #r_factor3 SELECT	'MT069'	,	15.659	;
INSERT INTO #r_factor3 SELECT	'MT079'	,	25.244	;
INSERT INTO #r_factor3 SELECT	'MT083'	,	31.325	;
INSERT INTO #r_factor3 SELECT	'MT091'	,	23.228	;
INSERT INTO #r_factor3 SELECT	'MT101'	,	13.756	;
INSERT INTO #r_factor3 SELECT	'MT103'	,	19.167	;
INSERT INTO #r_factor3 SELECT	'MT105'	,	28.627	;
INSERT INTO #r_factor3 SELECT	'MT109'	,	29.926	;
INSERT INTO #r_factor3 SELECT	'MT111'	,	14.35	;
INSERT INTO #r_factor3 SELECT	'MT600'	,	15.297	;
INSERT INTO #r_factor3 SELECT	'MT602'	,	9.9904	;
INSERT INTO #r_factor3 SELECT	'MT603'	,	10.148	;
INSERT INTO #r_factor3 SELECT	'MT604'	,	9.7323	;
INSERT INTO #r_factor3 SELECT	'MT605'	,	9.1591	;
INSERT INTO #r_factor3 SELECT	'MT606'	,	10.06	;
INSERT INTO #r_factor3 SELECT	'MT607'	,	15.383	;
INSERT INTO #r_factor3 SELECT	'MT608'	,	14.432	;
INSERT INTO #r_factor3 SELECT	'MT609'	,	10.059	;
INSERT INTO #r_factor3 SELECT	'MT610'	,	8.0339	;
INSERT INTO #r_factor3 SELECT	'MT611'	,	10.429	;
INSERT INTO #r_factor3 SELECT	'MT612'	,	9.5258	;
INSERT INTO #r_factor3 SELECT	'MT613'	,	9.9842	;
INSERT INTO #r_factor3 SELECT	'MT614'	,	10.033	;
INSERT INTO #r_factor3 SELECT	'MT615'	,	10.736	;
INSERT INTO #r_factor3 SELECT	'MT616'	,	9.3832	;
INSERT INTO #r_factor3 SELECT	'MT617'	,	11.816	;
INSERT INTO #r_factor3 SELECT	'MT618'	,	6.3192	;
INSERT INTO #r_factor3 SELECT	'MT619'	,	14.667	;
INSERT INTO #r_factor3 SELECT	'MT621'	,	9.547	;
INSERT INTO #r_factor3 SELECT	'MT622'	,	10.036	;
INSERT INTO #r_factor3 SELECT	'MT623'	,	10.012	;
INSERT INTO #r_factor3 SELECT	'MT624'	,	10.044	;
INSERT INTO #r_factor3 SELECT	'MT627'	,	10.016	;
INSERT INTO #r_factor3 SELECT	'MT629'	,	9.0407	;
INSERT INTO #r_factor3 SELECT	'MT630'	,	10.154	;
INSERT INTO #r_factor3 SELECT	'MT631'	,	10.083	;
INSERT INTO #r_factor3 SELECT	'MT632'	,	10.454	;
INSERT INTO #r_factor3 SELECT	'MT633'	,	11.871	;
INSERT INTO #r_factor3 SELECT	'MT634'	,	9.7104	;
INSERT INTO #r_factor3 SELECT	'MT635'	,	9.6253	;
INSERT INTO #r_factor3 SELECT	'MT636'	,	9.9765	;
INSERT INTO #r_factor3 SELECT	'MT637'	,	10.018	;
INSERT INTO #r_factor3 SELECT	'MT638'	,	10.253	;
INSERT INTO #r_factor3 SELECT	'MT639'	,	9.9876	;
INSERT INTO #r_factor3 SELECT	'MT640'	,	9.993	;
INSERT INTO #r_factor3 SELECT	'MT641'	,	19.326	;
INSERT INTO #r_factor3 SELECT	'MT642'	,	9.9942	;
INSERT INTO #r_factor3 SELECT	'MT643'	,	21.096	;
INSERT INTO #r_factor3 SELECT	'MT644'	,	10.021	;
INSERT INTO #r_factor3 SELECT	'MT645'	,	10.088	;
INSERT INTO #r_factor3 SELECT	'MT647'	,	9.6406	;
INSERT INTO #r_factor3 SELECT	'MT649'	,	19.215	;
INSERT INTO #r_factor3 SELECT	'MT651'	,	8.2284	;
INSERT INTO #r_factor3 SELECT	'MT655'	,	10.511	;
INSERT INTO #r_factor3 SELECT	'MT657'	,	11.008	;
INSERT INTO #r_factor3 SELECT	'MT661'	,	25.171	;
INSERT INTO #r_factor3 SELECT	'MT663'	,	31.271	;
INSERT INTO #r_factor3 SELECT	'MT664'	,	10.007	;
INSERT INTO #r_factor3 SELECT	'MT666'	,	10.985	;
INSERT INTO #r_factor3 SELECT	'MT669'	,	9.992	;
INSERT INTO #r_factor3 SELECT	'MT670'	,	9.8883	;
INSERT INTO #r_factor3 SELECT	'NC001'	,	214.93	;
INSERT INTO #r_factor3 SELECT	'NC003'	,	195.95	;
INSERT INTO #r_factor3 SELECT	'NC005'	,	152.23	;
INSERT INTO #r_factor3 SELECT	'NC007'	,	274.24	;
INSERT INTO #r_factor3 SELECT	'NC009'	,	149.71	;
INSERT INTO #r_factor3 SELECT	'NC011'	,	169.97	;
INSERT INTO #r_factor3 SELECT	'NC013'	,	337.2	;
INSERT INTO #r_factor3 SELECT	'NC015'	,	285.15	;
INSERT INTO #r_factor3 SELECT	'NC017'	,	364.57	;
INSERT INTO #r_factor3 SELECT	'NC019'	,	385.12	;
INSERT INTO #r_factor3 SELECT	'NC021'	,	190.23	;
INSERT INTO #r_factor3 SELECT	'NC023'	,	199.04	;
INSERT INTO #r_factor3 SELECT	'NC025'	,	236.42	;
INSERT INTO #r_factor3 SELECT	'NC027'	,	187.44	;
INSERT INTO #r_factor3 SELECT	'NC029'	,	278.07	;
INSERT INTO #r_factor3 SELECT	'NC031'	,	367.42	;
INSERT INTO #r_factor3 SELECT	'NC033'	,	199.31	;
INSERT INTO #r_factor3 SELECT	'NC035'	,	211.67	;
INSERT INTO #r_factor3 SELECT	'NC037'	,	240.14	;
INSERT INTO #r_factor3 SELECT	'NC039'	,	236.55	;
INSERT INTO #r_factor3 SELECT	'NC041'	,	286.69	;
INSERT INTO #r_factor3 SELECT	'NC043'	,	242.92	;
INSERT INTO #r_factor3 SELECT	'NC045'	,	234.73	;
INSERT INTO #r_factor3 SELECT	'NC047'	,	374.24	;
INSERT INTO #r_factor3 SELECT	'NC049'	,	359.88	;
INSERT INTO #r_factor3 SELECT	'NC051'	,	310.66	;
INSERT INTO #r_factor3 SELECT	'NC053'	,	279.76	;
INSERT INTO #r_factor3 SELECT	'NC055'	,	321.34	;
INSERT INTO #r_factor3 SELECT	'NC057'	,	216.79	;
INSERT INTO #r_factor3 SELECT	'NC059'	,	203.44	;
INSERT INTO #r_factor3 SELECT	'NC061'	,	361.92	;
INSERT INTO #r_factor3 SELECT	'NC063'	,	228.43	;
INSERT INTO #r_factor3 SELECT	'NC065'	,	276.96	;
INSERT INTO #r_factor3 SELECT	'NC067'	,	196.92	;
INSERT INTO #r_factor3 SELECT	'NC069'	,	241.34	;
INSERT INTO #r_factor3 SELECT	'NC071'	,	237.18	;
INSERT INTO #r_factor3 SELECT	'NC073'	,	264.18	;
INSERT INTO #r_factor3 SELECT	'NC075'	,	214.49	;
INSERT INTO #r_factor3 SELECT	'NC077'	,	219.52	;
INSERT INTO #r_factor3 SELECT	'NC079'	,	315.6	;
INSERT INTO #r_factor3 SELECT	'NC081'	,	205.42	;
INSERT INTO #r_factor3 SELECT	'NC083'	,	247.77	;
INSERT INTO #r_factor3 SELECT	'NC085'	,	283.19	;
INSERT INTO #r_factor3 SELECT	'NC089'	,	226.01	;
INSERT INTO #r_factor3 SELECT	'NC091'	,	264.53	;
INSERT INTO #r_factor3 SELECT	'NC093'	,	294.13	;
INSERT INTO #r_factor3 SELECT	'NC095'	,	339.96	;
INSERT INTO #r_factor3 SELECT	'NC097'	,	206.33	;
INSERT INTO #r_factor3 SELECT	'NC099'	,	220.26	;
INSERT INTO #r_factor3 SELECT	'NC101'	,	287.85	;
INSERT INTO #r_factor3 SELECT	'NC103'	,	365.55	;
INSERT INTO #r_factor3 SELECT	'NC105'	,	263.42	;
INSERT INTO #r_factor3 SELECT	'NC107'	,	346.16	;
INSERT INTO #r_factor3 SELECT	'NC109'	,	224.57	;
INSERT INTO #r_factor3 SELECT	'NC111'	,	196.97	;
INSERT INTO #r_factor3 SELECT	'NC113'	,	233.68	;
INSERT INTO #r_factor3 SELECT	'NC115'	,	174.62	;
INSERT INTO #r_factor3 SELECT	'NC117'	,	300.04	;
INSERT INTO #r_factor3 SELECT	'NC119'	,	242.05	;
INSERT INTO #r_factor3 SELECT	'NC121'	,	170.76	;
INSERT INTO #r_factor3 SELECT	'NC123'	,	256.79	;
INSERT INTO #r_factor3 SELECT	'NC125'	,	268.99	;
INSERT INTO #r_factor3 SELECT	'NC127'	,	260.18	;
INSERT INTO #r_factor3 SELECT	'NC129'	,	384.97	;
INSERT INTO #r_factor3 SELECT	'NC131'	,	247.72	;
INSERT INTO #r_factor3 SELECT	'NC133'	,	376.52	;
INSERT INTO #r_factor3 SELECT	'NC135'	,	221.19	;
INSERT INTO #r_factor3 SELECT	'NC137'	,	359.65	;
INSERT INTO #r_factor3 SELECT	'NC139'	,	281.62	;
INSERT INTO #r_factor3 SELECT	'NC141'	,	378.27	;
INSERT INTO #r_factor3 SELECT	'NC143'	,	285.3	;
INSERT INTO #r_factor3 SELECT	'NC145'	,	207.21	;
INSERT INTO #r_factor3 SELECT	'NC147'	,	317.36	;
INSERT INTO #r_factor3 SELECT	'NC149'	,	236.93	;
INSERT INTO #r_factor3 SELECT	'NC151'	,	229.59	;
INSERT INTO #r_factor3 SELECT	'NC153'	,	281.4	;
INSERT INTO #r_factor3 SELECT	'NC155'	,	339.35	;
INSERT INTO #r_factor3 SELECT	'NC157'	,	192.6	;
INSERT INTO #r_factor3 SELECT	'NC159'	,	221.6	;
INSERT INTO #r_factor3 SELECT	'NC161'	,	228.39	;
INSERT INTO #r_factor3 SELECT	'NC163'	,	339.1	;
INSERT INTO #r_factor3 SELECT	'NC165'	,	297.09	;
INSERT INTO #r_factor3 SELECT	'NC167'	,	248.82	;
INSERT INTO #r_factor3 SELECT	'NC169'	,	183.87	;
INSERT INTO #r_factor3 SELECT	'NC171'	,	171.86	;
INSERT INTO #r_factor3 SELECT	'NC175'	,	234.81	;
INSERT INTO #r_factor3 SELECT	'NC177'	,	307.48	;
INSERT INTO #r_factor3 SELECT	'NC179'	,	264.45	;
INSERT INTO #r_factor3 SELECT	'NC181'	,	221.41	;
INSERT INTO #r_factor3 SELECT	'NC183'	,	253.81	;
INSERT INTO #r_factor3 SELECT	'NC185'	,	225.43	;
INSERT INTO #r_factor3 SELECT	'NC187'	,	307.2	;
INSERT INTO #r_factor3 SELECT	'NC189'	,	162.55	;
INSERT INTO #r_factor3 SELECT	'NC191'	,	314.54	;
INSERT INTO #r_factor3 SELECT	'NC193'	,	178.8	;
INSERT INTO #r_factor3 SELECT	'NC195'	,	284.47	;
INSERT INTO #r_factor3 SELECT	'NC197'	,	191.19	;
INSERT INTO #r_factor3 SELECT	'NC199'	,	175.97	;
INSERT INTO #r_factor3 SELECT	'NC605'	,	207.83	;
INSERT INTO #r_factor3 SELECT	'NC606'	,	194.07	;
INSERT INTO #r_factor3 SELECT	'ND001'	,	39.396	;
INSERT INTO #r_factor3 SELECT	'ND003'	,	65.45	;
INSERT INTO #r_factor3 SELECT	'ND005'	,	56.978	;
INSERT INTO #r_factor3 SELECT	'ND007'	,	32.469	;
INSERT INTO #r_factor3 SELECT	'ND009'	,	47.01	;
INSERT INTO #r_factor3 SELECT	'ND011'	,	30.833	;
INSERT INTO #r_factor3 SELECT	'ND013'	,	36.603	;
INSERT INTO #r_factor3 SELECT	'ND015'	,	51.934	;
INSERT INTO #r_factor3 SELECT	'ND017'	,	69.211	;
INSERT INTO #r_factor3 SELECT	'ND019'	,	59.778	;
INSERT INTO #r_factor3 SELECT	'ND021'	,	69.867	;
INSERT INTO #r_factor3 SELECT	'ND023'	,	29.246	;
INSERT INTO #r_factor3 SELECT	'ND025'	,	37.523	;
INSERT INTO #r_factor3 SELECT	'ND027'	,	59.976	;
INSERT INTO #r_factor3 SELECT	'ND029'	,	56.823	;
INSERT INTO #r_factor3 SELECT	'ND031'	,	60.433	;
INSERT INTO #r_factor3 SELECT	'ND033'	,	30.32	;
INSERT INTO #r_factor3 SELECT	'ND035'	,	63.981	;
INSERT INTO #r_factor3 SELECT	'ND037'	,	46.105	;
INSERT INTO #r_factor3 SELECT	'ND039'	,	62.61	;
INSERT INTO #r_factor3 SELECT	'ND041'	,	39.421	;
INSERT INTO #r_factor3 SELECT	'ND043'	,	57.118	;
INSERT INTO #r_factor3 SELECT	'ND045'	,	66.334	;
INSERT INTO #r_factor3 SELECT	'ND047'	,	60.995	;
INSERT INTO #r_factor3 SELECT	'ND049'	,	48.744	;
INSERT INTO #r_factor3 SELECT	'ND051'	,	63.031	;
INSERT INTO #r_factor3 SELECT	'ND053'	,	32.291	;
INSERT INTO #r_factor3 SELECT	'ND055'	,	45.514	;
INSERT INTO #r_factor3 SELECT	'ND057'	,	42.266	;
INSERT INTO #r_factor3 SELECT	'ND059'	,	47.567	;
INSERT INTO #r_factor3 SELECT	'ND061'	,	38.435	;
INSERT INTO #r_factor3 SELECT	'ND063'	,	61.661	;
INSERT INTO #r_factor3 SELECT	'ND065'	,	46.16	;
INSERT INTO #r_factor3 SELECT	'ND067'	,	61.881	;
INSERT INTO #r_factor3 SELECT	'ND069'	,	52.673	;
INSERT INTO #r_factor3 SELECT	'ND071'	,	59.792	;
INSERT INTO #r_factor3 SELECT	'ND073'	,	71.406	;
INSERT INTO #r_factor3 SELECT	'ND075'	,	41.649	;
INSERT INTO #r_factor3 SELECT	'ND077'	,	78.212	;
INSERT INTO #r_factor3 SELECT	'ND079'	,	53.043	;
INSERT INTO #r_factor3 SELECT	'ND081'	,	76.124	;
INSERT INTO #r_factor3 SELECT	'ND083'	,	51.309	;
INSERT INTO #r_factor3 SELECT	'ND085'	,	51.01	;
INSERT INTO #r_factor3 SELECT	'ND087'	,	31.777	;
INSERT INTO #r_factor3 SELECT	'ND089'	,	37.78	;
INSERT INTO #r_factor3 SELECT	'ND091'	,	64.516	;
INSERT INTO #r_factor3 SELECT	'ND093'	,	61.379	;
INSERT INTO #r_factor3 SELECT	'ND095'	,	56.91	;
INSERT INTO #r_factor3 SELECT	'ND097'	,	66.443	;
INSERT INTO #r_factor3 SELECT	'ND099'	,	62.137	;
INSERT INTO #r_factor3 SELECT	'ND101'	,	42.846	;
INSERT INTO #r_factor3 SELECT	'ND103'	,	56.02	;
INSERT INTO #r_factor3 SELECT	'ND105'	,	30.812	;
INSERT INTO #r_factor3 SELECT	'NE001'	,	123.35	;
INSERT INTO #r_factor3 SELECT	'NE003'	,	115.84	;
INSERT INTO #r_factor3 SELECT	'NE005'	,	70.141	;
INSERT INTO #r_factor3 SELECT	'NE007'	,	47.208	;
INSERT INTO #r_factor3 SELECT	'NE009'	,	89.805	;
INSERT INTO #r_factor3 SELECT	'NE011'	,	119.91	;
INSERT INTO #r_factor3 SELECT	'NE013'	,	50.239	;
INSERT INTO #r_factor3 SELECT	'NE015'	,	96.96	;
INSERT INTO #r_factor3 SELECT	'NE017'	,	84.908	;
INSERT INTO #r_factor3 SELECT	'NE019'	,	111.1	;
INSERT INTO #r_factor3 SELECT	'NE021'	,	136.95	;
INSERT INTO #r_factor3 SELECT	'NE023'	,	134.8	;
INSERT INTO #r_factor3 SELECT	'NE025'	,	154.69	;
INSERT INTO #r_factor3 SELECT	'NE027'	,	123.57	;
INSERT INTO #r_factor3 SELECT	'NE029'	,	70.524	;
INSERT INTO #r_factor3 SELECT	'NE031'	,	70.47	;
INSERT INTO #r_factor3 SELECT	'NE033'	,	62.978	;
INSERT INTO #r_factor3 SELECT	'NE035'	,	128.67	;
INSERT INTO #r_factor3 SELECT	'NE037'	,	131.7	;
INSERT INTO #r_factor3 SELECT	'NE039'	,	132.21	;
INSERT INTO #r_factor3 SELECT	'NE041'	,	98.43	;
INSERT INTO #r_factor3 SELECT	'NE043'	,	130.75	;
INSERT INTO #r_factor3 SELECT	'NE045'	,	45.473	;
INSERT INTO #r_factor3 SELECT	'NE047'	,	100.9	;
INSERT INTO #r_factor3 SELECT	'NE049'	,	65.95	;
INSERT INTO #r_factor3 SELECT	'NE051'	,	127.93	;
INSERT INTO #r_factor3 SELECT	'NE053'	,	136.79	;
INSERT INTO #r_factor3 SELECT	'NE055'	,	146.74	;
INSERT INTO #r_factor3 SELECT	'NE057'	,	69.491	;
INSERT INTO #r_factor3 SELECT	'NE059'	,	136.66	;
INSERT INTO #r_factor3 SELECT	'NE061'	,	120.91	;
INSERT INTO #r_factor3 SELECT	'NE063'	,	95.214	;
INSERT INTO #r_factor3 SELECT	'NE065'	,	103.85	;
INSERT INTO #r_factor3 SELECT	'NE067'	,	158.28	;
INSERT INTO #r_factor3 SELECT	'NE069'	,	64.121	;
INSERT INTO #r_factor3 SELECT	'NE071'	,	102.62	;
INSERT INTO #r_factor3 SELECT	'NE073'	,	102.03	;
INSERT INTO #r_factor3 SELECT	'NE075'	,	68.859	;
INSERT INTO #r_factor3 SELECT	'NE077'	,	113.66	;
INSERT INTO #r_factor3 SELECT	'NE079'	,	120.13	;
INSERT INTO #r_factor3 SELECT	'NE081'	,	125.83	;
INSERT INTO #r_factor3 SELECT	'NE083'	,	112.81	;
INSERT INTO #r_factor3 SELECT	'NE085'	,	83.183	;
INSERT INTO #r_factor3 SELECT	'NE087'	,	84.633	;
INSERT INTO #r_factor3 SELECT	'NE089'	,	101.53	;
INSERT INTO #r_factor3 SELECT	'NE091'	,	75.647	;
INSERT INTO #r_factor3 SELECT	'NE093'	,	116.84	;
INSERT INTO #r_factor3 SELECT	'NE095'	,	150.61	;
INSERT INTO #r_factor3 SELECT	'NE097'	,	165.52	;
INSERT INTO #r_factor3 SELECT	'NE099'	,	116.53	;
INSERT INTO #r_factor3 SELECT	'NE101'	,	71.596	;
INSERT INTO #r_factor3 SELECT	'NE103'	,	83.028	;
INSERT INTO #r_factor3 SELECT	'NE105'	,	52.838	;
INSERT INTO #r_factor3 SELECT	'NE107'	,	113.53	;
INSERT INTO #r_factor3 SELECT	'NE109'	,	148.65	;
INSERT INTO #r_factor3 SELECT	'NE111'	,	85.915	;
INSERT INTO #r_factor3 SELECT	'NE113'	,	85.303	;
INSERT INTO #r_factor3 SELECT	'NE115'	,	97.765	;
INSERT INTO #r_factor3 SELECT	'NE117'	,	78.465	;
INSERT INTO #r_factor3 SELECT	'NE119'	,	124.64	;
INSERT INTO #r_factor3 SELECT	'NE121'	,	123.83	;
INSERT INTO #r_factor3 SELECT	'NE123'	,	57.168	;
INSERT INTO #r_factor3 SELECT	'NE125'	,	122.93	;
INSERT INTO #r_factor3 SELECT	'NE127'	,	173.46	;
INSERT INTO #r_factor3 SELECT	'NE129'	,	133.6	;
INSERT INTO #r_factor3 SELECT	'NE131'	,	161.86	;
INSERT INTO #r_factor3 SELECT	'NE133'	,	172.12	;
INSERT INTO #r_factor3 SELECT	'NE135'	,	72.278	;
INSERT INTO #r_factor3 SELECT	'NE137'	,	108.48	;
INSERT INTO #r_factor3 SELECT	'NE139'	,	122.76	;
INSERT INTO #r_factor3 SELECT	'NE141'	,	126.81	;
INSERT INTO #r_factor3 SELECT	'NE143'	,	128.64	;
INSERT INTO #r_factor3 SELECT	'NE145'	,	95.853	;
INSERT INTO #r_factor3 SELECT	'NE147'	,	179.74	;
INSERT INTO #r_factor3 SELECT	'NE149'	,	92.512	;
INSERT INTO #r_factor3 SELECT	'NE151'	,	145.41	;
INSERT INTO #r_factor3 SELECT	'NE153'	,	150.41	;
INSERT INTO #r_factor3 SELECT	'NE155'	,	141.9	;
INSERT INTO #r_factor3 SELECT	'NE157'	,	43.69	;
INSERT INTO #r_factor3 SELECT	'NE159'	,	139.79	;
INSERT INTO #r_factor3 SELECT	'NE161'	,	56.834	;
INSERT INTO #r_factor3 SELECT	'NE163'	,	109.59	;
INSERT INTO #r_factor3 SELECT	'NE165'	,	36.955	;
INSERT INTO #r_factor3 SELECT	'NE167'	,	128.2	;
INSERT INTO #r_factor3 SELECT	'NE169'	,	142.5	;
INSERT INTO #r_factor3 SELECT	'NE171'	,	81.577	;
INSERT INTO #r_factor3 SELECT	'NE173'	,	132.56	;
INSERT INTO #r_factor3 SELECT	'NE175'	,	105.98	;
INSERT INTO #r_factor3 SELECT	'NE177'	,	142.09	;
INSERT INTO #r_factor3 SELECT	'NE179'	,	127.58	;
INSERT INTO #r_factor3 SELECT	'NE181'	,	127.01	;
INSERT INTO #r_factor3 SELECT	'NE183'	,	110.12	;
INSERT INTO #r_factor3 SELECT	'NE185'	,	131.61	;
INSERT INTO #r_factor3 SELECT	'NH005'	,	97.095	;
INSERT INTO #r_factor3 SELECT	'NH009'	,	83.305	;
INSERT INTO #r_factor3 SELECT	'NH015'	,	103.64	;
INSERT INTO #r_factor3 SELECT	'NH017'	,	100.66	;
INSERT INTO #r_factor3 SELECT	'NH019'	,	89.692	;
INSERT INTO #r_factor3 SELECT	'NH601'	,	102.58	;
INSERT INTO #r_factor3 SELECT	'NH602'	,	98.692	;
INSERT INTO #r_factor3 SELECT	'NH603'	,	90.413	;
INSERT INTO #r_factor3 SELECT	'NH605'	,	82.822	;
INSERT INTO #r_factor3 SELECT	'NH607'	,	76.889	;
INSERT INTO #r_factor3 SELECT	'NH609'	,	94.88	;
INSERT INTO #r_factor3 SELECT	'NJ001'	,	175.63	;
INSERT INTO #r_factor3 SELECT	'NJ003'	,	155.63	;
INSERT INTO #r_factor3 SELECT	'NJ005'	,	170.77	;
INSERT INTO #r_factor3 SELECT	'NJ007'	,	172.28	;
INSERT INTO #r_factor3 SELECT	'NJ009'	,	181.19	;
INSERT INTO #r_factor3 SELECT	'NJ011'	,	179.27	;
INSERT INTO #r_factor3 SELECT	'NJ013'	,	157.83	;
INSERT INTO #r_factor3 SELECT	'NJ015'	,	174.17	;
INSERT INTO #r_factor3 SELECT	'NJ017'	,	159.84	;
INSERT INTO #r_factor3 SELECT	'NJ019'	,	155.6	;
INSERT INTO #r_factor3 SELECT	'NJ021'	,	163.86	;
INSERT INTO #r_factor3 SELECT	'NJ023'	,	162.79	;
INSERT INTO #r_factor3 SELECT	'NJ025'	,	166.75	;
INSERT INTO #r_factor3 SELECT	'NJ027'	,	153.74	;
INSERT INTO #r_factor3 SELECT	'NJ029'	,	171.23	;
INSERT INTO #r_factor3 SELECT	'NJ031'	,	152.92	;
INSERT INTO #r_factor3 SELECT	'NJ033'	,	177.36	;
INSERT INTO #r_factor3 SELECT	'NJ035'	,	158.83	;
INSERT INTO #r_factor3 SELECT	'NJ037'	,	143.67	;
INSERT INTO #r_factor3 SELECT	'NJ039'	,	159.56	;
INSERT INTO #r_factor3 SELECT	'NJ041'	,	147.7	;
INSERT INTO #r_factor3 SELECT	'NM007'	,	44.662	;
INSERT INTO #r_factor3 SELECT	'NM011'	,	33.233	;
INSERT INTO #r_factor3 SELECT	'NM019'	,	33.417	;
INSERT INTO #r_factor3 SELECT	'NM021'	,	48.617	;
INSERT INTO #r_factor3 SELECT	'NM023'	,	20.198	;
INSERT INTO #r_factor3 SELECT	'NM025'	,	39.854	;
INSERT INTO #r_factor3 SELECT	'NM029'	,	9.8106	;
INSERT INTO #r_factor3 SELECT	'NM041'	,	29.982	;
INSERT INTO #r_factor3 SELECT	'NM059'	,	44.846	;
INSERT INTO #r_factor3 SELECT	'NM600'	,	25.109	;
INSERT INTO #r_factor3 SELECT	'NM606'	,	18.179	;
INSERT INTO #r_factor3 SELECT	'NM612'	,	22.643	;
INSERT INTO #r_factor3 SELECT	'NM614'	,	29.583	;
INSERT INTO #r_factor3 SELECT	'NM618'	,	9.2493	;
INSERT INTO #r_factor3 SELECT	'NM622'	,	25.661	;
INSERT INTO #r_factor3 SELECT	'NM630'	,	39.662	;
INSERT INTO #r_factor3 SELECT	'NM632'	,	44.571	;
INSERT INTO #r_factor3 SELECT	'NM636'	,	48.276	;
INSERT INTO #r_factor3 SELECT	'NM638'	,	48.547	;
INSERT INTO #r_factor3 SELECT	'NM644'	,	41.501	;
INSERT INTO #r_factor3 SELECT	'NM646'	,	18.443	;
INSERT INTO #r_factor3 SELECT	'NM648'	,	16.575	;
INSERT INTO #r_factor3 SELECT	'NM650'	,	11.034	;
INSERT INTO #r_factor3 SELECT	'NM656'	,	23.115	;
INSERT INTO #r_factor3 SELECT	'NM660'	,	14.72	;
INSERT INTO #r_factor3 SELECT	'NM662'	,	20.576	;
INSERT INTO #r_factor3 SELECT	'NM664'	,	18.962	;
INSERT INTO #r_factor3 SELECT	'NM666'	,	34.303	;
INSERT INTO #r_factor3 SELECT	'NM669'	,	32.325	;
INSERT INTO #r_factor3 SELECT	'NM670'	,	15.413	;
INSERT INTO #r_factor3 SELECT	'NM672'	,	10.702	;
INSERT INTO #r_factor3 SELECT	'NM674'	,	31.752	;
INSERT INTO #r_factor3 SELECT	'NM676'	,	52.407	;
INSERT INTO #r_factor3 SELECT	'NM678'	,	22.593	;
INSERT INTO #r_factor3 SELECT	'NM682'	,	15.039	;
INSERT INTO #r_factor3 SELECT	'NM687'	,	29.808	;
INSERT INTO #r_factor3 SELECT	'NM688'	,	10.935	;
INSERT INTO #r_factor3 SELECT	'NM690'	,	8.1952	;
INSERT INTO #r_factor3 SELECT	'NM692'	,	11.426	;
INSERT INTO #r_factor3 SELECT	'NM694'	,	41.636	;
INSERT INTO #r_factor3 SELECT	'NM696'	,	18.899	;
INSERT INTO #r_factor3 SELECT	'NM698'	,	10.296	;
INSERT INTO #r_factor3 SELECT	'NM717'	,	16.1	;
INSERT INTO #r_factor3 SELECT	'NM719'	,	11.188	;
INSERT INTO #r_factor3 SELECT	'NM780'	,	22.021	;
INSERT INTO #r_factor3 SELECT	'NM781'	,	8.1941	;
INSERT INTO #r_factor3 SELECT	'NV602'	,	0.2702	;
INSERT INTO #r_factor3 SELECT	'NV603'	,	0.7859	;
INSERT INTO #r_factor3 SELECT	'NV608'	,	9.0084	;
INSERT INTO #r_factor3 SELECT	'NV611'	,	7.1535	;
INSERT INTO #r_factor3 SELECT	'NV612'	,	6.9571	;
INSERT INTO #r_factor3 SELECT	'NV621'	,	8.2472	;
INSERT INTO #r_factor3 SELECT	'NV622'	,	1.934	;
INSERT INTO #r_factor3 SELECT	'NV625'	,	1.562	;
INSERT INTO #r_factor3 SELECT	'NV628'	,	5.7274	;
INSERT INTO #r_factor3 SELECT	'NV629'	,	8.1195	;
INSERT INTO #r_factor3 SELECT	'NV708'	,	10.017	;
INSERT INTO #r_factor3 SELECT	'NV709'	,	10.02	;
INSERT INTO #r_factor3 SELECT	'NV713'	,	10.102	;
INSERT INTO #r_factor3 SELECT	'NV754'	,	9.4047	;
INSERT INTO #r_factor3 SELECT	'NV755'	,	7.4661	;
INSERT INTO #r_factor3 SELECT	'NV757'	,	8.1315	;
INSERT INTO #r_factor3 SELECT	'NV759'	,	1.4714	;
INSERT INTO #r_factor3 SELECT	'NV760'	,	0.4854	;
INSERT INTO #r_factor3 SELECT	'NV761'	,	0.1479	;
INSERT INTO #r_factor3 SELECT	'NV763'	,	5.9872	;
INSERT INTO #r_factor3 SELECT	'NV764'	,	9.0092	;
INSERT INTO #r_factor3 SELECT	'NV765'	,	9.8494	;
INSERT INTO #r_factor3 SELECT	'NV766'	,	10.098	;
INSERT INTO #r_factor3 SELECT	'NV767'	,	9.274	;
INSERT INTO #r_factor3 SELECT	'NV768'	,	3.373	;
INSERT INTO #r_factor3 SELECT	'NV769'	,	1.3257	;
INSERT INTO #r_factor3 SELECT	'NV770'	,	0.806	;
INSERT INTO #r_factor3 SELECT	'NV771'	,	0.5883	;
INSERT INTO #r_factor3 SELECT	'NV772'	,	6.2001	;
INSERT INTO #r_factor3 SELECT	'NV773'	,	2.5927	;
INSERT INTO #r_factor3 SELECT	'NV774'	,	0.6259	;
INSERT INTO #r_factor3 SELECT	'NV775'	,	4.275	;
INSERT INTO #r_factor3 SELECT	'NV776'	,	6.8382	;
INSERT INTO #r_factor3 SELECT	'NV777'	,	2.5126	;
INSERT INTO #r_factor3 SELECT	'NV778'	,	9.1279	;
INSERT INTO #r_factor3 SELECT	'NV779'	,	10.085	;
INSERT INTO #r_factor3 SELECT	'NV780'	,	9.6716	;
INSERT INTO #r_factor3 SELECT	'NV781'	,	2.1484	;
INSERT INTO #r_factor3 SELECT	'NV782'	,	3.1072	;
INSERT INTO #r_factor3 SELECT	'NV783'	,	6.846	;
INSERT INTO #r_factor3 SELECT	'NV784'	,	9.4705	;
INSERT INTO #r_factor3 SELECT	'NV785'	,	4.339	;
INSERT INTO #r_factor3 SELECT	'NV786'	,	5.215	;
INSERT INTO #r_factor3 SELECT	'NV788'	,	7.6424	;
INSERT INTO #r_factor3 SELECT	'NV792'	,	1.1827	;
INSERT INTO #r_factor3 SELECT	'NV796'	,	0.4908	;
INSERT INTO #r_factor3 SELECT	'NV799'	,	0.4266	;
INSERT INTO #r_factor3 SELECT	'NY001'	,	99.447	;
INSERT INTO #r_factor3 SELECT	'NY003'	,	78.819	;
INSERT INTO #r_factor3 SELECT	'NY005'	,	158.67	;
INSERT INTO #r_factor3 SELECT	'NY007'	,	83.509	;
INSERT INTO #r_factor3 SELECT	'NY009'	,	78.985	;
INSERT INTO #r_factor3 SELECT	'NY011'	,	75.44	;
INSERT INTO #r_factor3 SELECT	'NY013'	,	81.755	;
INSERT INTO #r_factor3 SELECT	'NY015'	,	81.4	;
INSERT INTO #r_factor3 SELECT	'NY017'	,	80.685	;
INSERT INTO #r_factor3 SELECT	'NY019'	,	70.997	;
INSERT INTO #r_factor3 SELECT	'NY021'	,	115.69	;
INSERT INTO #r_factor3 SELECT	'NY023'	,	79.085	;
INSERT INTO #r_factor3 SELECT	'NY025'	,	91.987	;
INSERT INTO #r_factor3 SELECT	'NY027'	,	132.13	;
INSERT INTO #r_factor3 SELECT	'NY029'	,	72.995	;
INSERT INTO #r_factor3 SELECT	'NY031'	,	77.24	;
INSERT INTO #r_factor3 SELECT	'NY033'	,	69.365	;
INSERT INTO #r_factor3 SELECT	'NY035'	,	79.463	;
INSERT INTO #r_factor3 SELECT	'NY037'	,	71.632	;
INSERT INTO #r_factor3 SELECT	'NY039'	,	105.67	;
INSERT INTO #r_factor3 SELECT	'NY041'	,	74.197	;
INSERT INTO #r_factor3 SELECT	'NY045'	,	65.624	;
INSERT INTO #r_factor3 SELECT	'NY047'	,	162.16	;
INSERT INTO #r_factor3 SELECT	'NY049'	,	68.626	;
INSERT INTO #r_factor3 SELECT	'NY051'	,	74.825	;
INSERT INTO #r_factor3 SELECT	'NY053'	,	76.682	;
INSERT INTO #r_factor3 SELECT	'NY055'	,	71.657	;
INSERT INTO #r_factor3 SELECT	'NY057'	,	83.352	;
INSERT INTO #r_factor3 SELECT	'NY059'	,	161.51	;
INSERT INTO #r_factor3 SELECT	'NY061'	,	159.54	;
INSERT INTO #r_factor3 SELECT	'NY065'	,	73.438	;
INSERT INTO #r_factor3 SELECT	'NY067'	,	75.136	;
INSERT INTO #r_factor3 SELECT	'NY069'	,	74.632	;
INSERT INTO #r_factor3 SELECT	'NY071'	,	139.25	;
INSERT INTO #r_factor3 SELECT	'NY073'	,	70.146	;
INSERT INTO #r_factor3 SELECT	'NY075'	,	70.889	;
INSERT INTO #r_factor3 SELECT	'NY077'	,	82.502	;
INSERT INTO #r_factor3 SELECT	'NY079'	,	146.03	;
INSERT INTO #r_factor3 SELECT	'NY081'	,	161.91	;
INSERT INTO #r_factor3 SELECT	'NY083'	,	102.5	;
INSERT INTO #r_factor3 SELECT	'NY085'	,	162.38	;
INSERT INTO #r_factor3 SELECT	'NY087'	,	151.61	;
INSERT INTO #r_factor3 SELECT	'NY089'	,	64.628	;
INSERT INTO #r_factor3 SELECT	'NY091'	,	86.892	;
INSERT INTO #r_factor3 SELECT	'NY093'	,	91.75	;
INSERT INTO #r_factor3 SELECT	'NY095'	,	92.382	;
INSERT INTO #r_factor3 SELECT	'NY097'	,	79.32	;
INSERT INTO #r_factor3 SELECT	'NY099'	,	76.215	;
INSERT INTO #r_factor3 SELECT	'NY101'	,	79.572	;
INSERT INTO #r_factor3 SELECT	'NY103'	,	160.38	;
INSERT INTO #r_factor3 SELECT	'NY105'	,	111.9	;
INSERT INTO #r_factor3 SELECT	'NY107'	,	81.964	;
INSERT INTO #r_factor3 SELECT	'NY109'	,	79.45	;
INSERT INTO #r_factor3 SELECT	'NY111'	,	117.88	;
INSERT INTO #r_factor3 SELECT	'NY113'	,	80.117	;
INSERT INTO #r_factor3 SELECT	'NY115'	,	87.606	;
INSERT INTO #r_factor3 SELECT	'NY117'	,	72.387	;
INSERT INTO #r_factor3 SELECT	'NY119'	,	152.67	;
INSERT INTO #r_factor3 SELECT	'NY121'	,	74.057	;
INSERT INTO #r_factor3 SELECT	'NY123'	,	76.968	;
INSERT INTO #r_factor3 SELECT	'NY604'	,	64.955	;
INSERT INTO #r_factor3 SELECT	'NY605'	,	79.039	;
INSERT INTO #r_factor3 SELECT	'NY606'	,	71.302	;
INSERT INTO #r_factor3 SELECT	'NY614'	,	68.34	;
INSERT INTO #r_factor3 SELECT	'NY615'	,	76.604	;
INSERT INTO #r_factor3 SELECT	'NY663'	,	69.84	;
INSERT INTO #r_factor3 SELECT	'NY664'	,	69.793	;
INSERT INTO #r_factor3 SELECT	'NY689'	,	62.494	;
INSERT INTO #r_factor3 SELECT	'OH001'	,	149.7	;
INSERT INTO #r_factor3 SELECT	'OH003'	,	117.78	;
INSERT INTO #r_factor3 SELECT	'OH005'	,	109.15	;
INSERT INTO #r_factor3 SELECT	'OH007'	,	96.902	;
INSERT INTO #r_factor3 SELECT	'OH009'	,	129.98	;
INSERT INTO #r_factor3 SELECT	'OH011'	,	121.5	;
INSERT INTO #r_factor3 SELECT	'OH013'	,	119.55	;
INSERT INTO #r_factor3 SELECT	'OH015'	,	151.71	;
INSERT INTO #r_factor3 SELECT	'OH017'	,	149.44	;
INSERT INTO #r_factor3 SELECT	'OH019'	,	112.03	;
INSERT INTO #r_factor3 SELECT	'OH021'	,	123.68	;
INSERT INTO #r_factor3 SELECT	'OH023'	,	128	;
INSERT INTO #r_factor3 SELECT	'OH025'	,	152.6	;
INSERT INTO #r_factor3 SELECT	'OH027'	,	143.95	;
INSERT INTO #r_factor3 SELECT	'OH029'	,	109.48	;
INSERT INTO #r_factor3 SELECT	'OH031'	,	116.44	;
INSERT INTO #r_factor3 SELECT	'OH033'	,	109.89	;
INSERT INTO #r_factor3 SELECT	'OH035'	,	101.99	;
INSERT INTO #r_factor3 SELECT	'OH037'	,	132.13	;
INSERT INTO #r_factor3 SELECT	'OH039'	,	115.08	;
INSERT INTO #r_factor3 SELECT	'OH041'	,	118.44	;
INSERT INTO #r_factor3 SELECT	'OH043'	,	103.66	;
INSERT INTO #r_factor3 SELECT	'OH045'	,	126.26	;
INSERT INTO #r_factor3 SELECT	'OH047'	,	136.22	;
INSERT INTO #r_factor3 SELECT	'OH049'	,	123.48	;
INSERT INTO #r_factor3 SELECT	'OH051'	,	108.38	;
INSERT INTO #r_factor3 SELECT	'OH053'	,	137.65	;
INSERT INTO #r_factor3 SELECT	'OH055'	,	100.35	;
INSERT INTO #r_factor3 SELECT	'OH057'	,	136.21	;
INSERT INTO #r_factor3 SELECT	'OH059'	,	119.91	;
INSERT INTO #r_factor3 SELECT	'OH061'	,	152.92	;
INSERT INTO #r_factor3 SELECT	'OH063'	,	111.33	;
INSERT INTO #r_factor3 SELECT	'OH065'	,	115.48	;
INSERT INTO #r_factor3 SELECT	'OH067'	,	115.88	;
INSERT INTO #r_factor3 SELECT	'OH069'	,	110.75	;
INSERT INTO #r_factor3 SELECT	'OH071'	,	146.66	;
INSERT INTO #r_factor3 SELECT	'OH073'	,	130.06	;
INSERT INTO #r_factor3 SELECT	'OH075'	,	112.73	;
INSERT INTO #r_factor3 SELECT	'OH077'	,	105.83	;
INSERT INTO #r_factor3 SELECT	'OH079'	,	139.35	;
INSERT INTO #r_factor3 SELECT	'OH081'	,	114.17	;
INSERT INTO #r_factor3 SELECT	'OH083'	,	115.5	;
INSERT INTO #r_factor3 SELECT	'OH085'	,	98.32	;
INSERT INTO #r_factor3 SELECT	'OH087'	,	141.95	;
INSERT INTO #r_factor3 SELECT	'OH089'	,	120.37	;
INSERT INTO #r_factor3 SELECT	'OH091'	,	119.93	;
INSERT INTO #r_factor3 SELECT	'OH093'	,	103.79	;
INSERT INTO #r_factor3 SELECT	'OH095'	,	104.65	;
INSERT INTO #r_factor3 SELECT	'OH097'	,	126.6	;
INSERT INTO #r_factor3 SELECT	'OH099'	,	106.66	;
INSERT INTO #r_factor3 SELECT	'OH101'	,	114.14	;
INSERT INTO #r_factor3 SELECT	'OH103'	,	105.61	;
INSERT INTO #r_factor3 SELECT	'OH105'	,	132.46	;
INSERT INTO #r_factor3 SELECT	'OH107'	,	125.95	;
INSERT INTO #r_factor3 SELECT	'OH109'	,	128.41	;
INSERT INTO #r_factor3 SELECT	'OH111'	,	123.36	;
INSERT INTO #r_factor3 SELECT	'OH113'	,	138.4	;
INSERT INTO #r_factor3 SELECT	'OH115'	,	126.09	;
INSERT INTO #r_factor3 SELECT	'OH117'	,	114.22	;
INSERT INTO #r_factor3 SELECT	'OH119'	,	121.77	;
INSERT INTO #r_factor3 SELECT	'OH121'	,	123.7	;
INSERT INTO #r_factor3 SELECT	'OH123'	,	103.05	;
INSERT INTO #r_factor3 SELECT	'OH125'	,	118.35	;
INSERT INTO #r_factor3 SELECT	'OH127'	,	125.55	;
INSERT INTO #r_factor3 SELECT	'OH129'	,	130.09	;
INSERT INTO #r_factor3 SELECT	'OH131'	,	143.33	;
INSERT INTO #r_factor3 SELECT	'OH133'	,	104.87	;
INSERT INTO #r_factor3 SELECT	'OH135'	,	143	;
INSERT INTO #r_factor3 SELECT	'OH137'	,	114.88	;
INSERT INTO #r_factor3 SELECT	'OH139'	,	110.33	;
INSERT INTO #r_factor3 SELECT	'OH141'	,	137.97	;
INSERT INTO #r_factor3 SELECT	'OH143'	,	104.82	;
INSERT INTO #r_factor3 SELECT	'OH145'	,	146.12	;
INSERT INTO #r_factor3 SELECT	'OH147'	,	107.25	;
INSERT INTO #r_factor3 SELECT	'OH149'	,	123.87	;
INSERT INTO #r_factor3 SELECT	'OH151'	,	109.17	;
INSERT INTO #r_factor3 SELECT	'OH153'	,	105.47	;
INSERT INTO #r_factor3 SELECT	'OH155'	,	102.41	;
INSERT INTO #r_factor3 SELECT	'OH157'	,	114.16	;
INSERT INTO #r_factor3 SELECT	'OH159'	,	119.29	;
INSERT INTO #r_factor3 SELECT	'OH161'	,	121.75	;
INSERT INTO #r_factor3 SELECT	'OH163'	,	134.35	;
INSERT INTO #r_factor3 SELECT	'OH165'	,	146.85	;
INSERT INTO #r_factor3 SELECT	'OH167'	,	126.53	;
INSERT INTO #r_factor3 SELECT	'OH169'	,	109.12	;
INSERT INTO #r_factor3 SELECT	'OH171'	,	113.47	;
INSERT INTO #r_factor3 SELECT	'OH173'	,	107.08	;
INSERT INTO #r_factor3 SELECT	'OH175'	,	111.2	;
INSERT INTO #r_factor3 SELECT	'OK001'	,	272.3	;
INSERT INTO #r_factor3 SELECT	'OK003'	,	182.15	;
INSERT INTO #r_factor3 SELECT	'OK005'	,	292.52	;
INSERT INTO #r_factor3 SELECT	'OK007'	,	119.3	;
INSERT INTO #r_factor3 SELECT	'OK009'	,	163.28	;
INSERT INTO #r_factor3 SELECT	'OK011'	,	195.07	;
INSERT INTO #r_factor3 SELECT	'OK013'	,	294.57	;
INSERT INTO #r_factor3 SELECT	'OK015'	,	206.97	;
INSERT INTO #r_factor3 SELECT	'OK017'	,	214.49	;
INSERT INTO #r_factor3 SELECT	'OK019'	,	264.68	;
INSERT INTO #r_factor3 SELECT	'OK021'	,	271.37	;
INSERT INTO #r_factor3 SELECT	'OK023'	,	303.95	;
INSERT INTO #r_factor3 SELECT	'OK025'	,	68.747	;
INSERT INTO #r_factor3 SELECT	'OK027'	,	241.67	;
INSERT INTO #r_factor3 SELECT	'OK029'	,	283.94	;
INSERT INTO #r_factor3 SELECT	'OK031'	,	210.44	;
INSERT INTO #r_factor3 SELECT	'OK033'	,	216.63	;
INSERT INTO #r_factor3 SELECT	'OK035'	,	253.74	;
INSERT INTO #r_factor3 SELECT	'OK037'	,	252.86	;
INSERT INTO #r_factor3 SELECT	'OK039'	,	177.63	;
INSERT INTO #r_factor3 SELECT	'OK041'	,	261.96	;
INSERT INTO #r_factor3 SELECT	'OK043'	,	171.59	;
INSERT INTO #r_factor3 SELECT	'OK045'	,	148.48	;
INSERT INTO #r_factor3 SELECT	'OK047'	,	207.89	;
INSERT INTO #r_factor3 SELECT	'OK049'	,	255.6	;
INSERT INTO #r_factor3 SELECT	'OK051'	,	226.95	;
INSERT INTO #r_factor3 SELECT	'OK053'	,	198.27	;
INSERT INTO #r_factor3 SELECT	'OK055'	,	171.18	;
INSERT INTO #r_factor3 SELECT	'OK057'	,	162.03	;
INSERT INTO #r_factor3 SELECT	'OK059'	,	140.67	;
INSERT INTO #r_factor3 SELECT	'OK061'	,	285.36	;
INSERT INTO #r_factor3 SELECT	'OK063'	,	274.92	;
INSERT INTO #r_factor3 SELECT	'OK065'	,	176.49	;
INSERT INTO #r_factor3 SELECT	'OK067'	,	242.67	;
INSERT INTO #r_factor3 SELECT	'OK069'	,	281.46	;
INSERT INTO #r_factor3 SELECT	'OK071'	,	216.08	;
INSERT INTO #r_factor3 SELECT	'OK073'	,	210.54	;
INSERT INTO #r_factor3 SELECT	'OK075'	,	190.54	;
INSERT INTO #r_factor3 SELECT	'OK077'	,	293.43	;
INSERT INTO #r_factor3 SELECT	'OK079'	,	296.17	;
INSERT INTO #r_factor3 SELECT	'OK081'	,	244.63	;
INSERT INTO #r_factor3 SELECT	'OK083'	,	224.27	;
INSERT INTO #r_factor3 SELECT	'OK085'	,	268.64	;
INSERT INTO #r_factor3 SELECT	'OK087'	,	242.64	;
INSERT INTO #r_factor3 SELECT	'OK089'	,	312.01	;
INSERT INTO #r_factor3 SELECT	'OK091'	,	277.42	;
INSERT INTO #r_factor3 SELECT	'OK093'	,	183.67	;
INSERT INTO #r_factor3 SELECT	'OK095'	,	282.2	;
INSERT INTO #r_factor3 SELECT	'OK097'	,	262.78	;
INSERT INTO #r_factor3 SELECT	'OK099'	,	269.27	;
INSERT INTO #r_factor3 SELECT	'OK101'	,	274.91	;
INSERT INTO #r_factor3 SELECT	'OK103'	,	222.09	;
INSERT INTO #r_factor3 SELECT	'OK105'	,	250.25	;
INSERT INTO #r_factor3 SELECT	'OK107'	,	262.83	;
INSERT INTO #r_factor3 SELECT	'OK109'	,	231.53	;
INSERT INTO #r_factor3 SELECT	'OK111'	,	268.11	;
INSERT INTO #r_factor3 SELECT	'OK113'	,	239.21	;
INSERT INTO #r_factor3 SELECT	'OK115'	,	254.1	;
INSERT INTO #r_factor3 SELECT	'OK117'	,	237.38	;
INSERT INTO #r_factor3 SELECT	'OK119'	,	233.95	;
INSERT INTO #r_factor3 SELECT	'OK121'	,	285.75	;
INSERT INTO #r_factor3 SELECT	'OK123'	,	273.53	;
INSERT INTO #r_factor3 SELECT	'OK125'	,	252.66	;
INSERT INTO #r_factor3 SELECT	'OK127'	,	300.57	;
INSERT INTO #r_factor3 SELECT	'OK129'	,	156.34	;
INSERT INTO #r_factor3 SELECT	'OK131'	,	258.09	;
INSERT INTO #r_factor3 SELECT	'OK133'	,	262.67	;
INSERT INTO #r_factor3 SELECT	'OK135'	,	279.86	;
INSERT INTO #r_factor3 SELECT	'OK137'	,	238.05	;
INSERT INTO #r_factor3 SELECT	'OK139'	,	91.335	;
INSERT INTO #r_factor3 SELECT	'OK141'	,	195.07	;
INSERT INTO #r_factor3 SELECT	'OK143'	,	257.8	;
INSERT INTO #r_factor3 SELECT	'OK145'	,	267.41	;
INSERT INTO #r_factor3 SELECT	'OK147'	,	248.51	;
INSERT INTO #r_factor3 SELECT	'OK149'	,	184.47	;
INSERT INTO #r_factor3 SELECT	'OK151'	,	164.29	;
INSERT INTO #r_factor3 SELECT	'OK153'	,	157.2	;
INSERT INTO #r_factor3 SELECT	'OR003'	,	73.165	;
INSERT INTO #r_factor3 SELECT	'OR007'	,	117.42	;
INSERT INTO #r_factor3 SELECT	'OR009'	,	65.472	;
INSERT INTO #r_factor3 SELECT	'OR011'	,	122.01	;
INSERT INTO #r_factor3 SELECT	'OR015'	,	113	;
INSERT INTO #r_factor3 SELECT	'OR021'	,	0.8671	;
INSERT INTO #r_factor3 SELECT	'OR033'	,	61.28	;
INSERT INTO #r_factor3 SELECT	'OR049'	,	3.5273	;
INSERT INTO #r_factor3 SELECT	'OR051'	,	70.763	;
INSERT INTO #r_factor3 SELECT	'OR053'	,	89.258	;
INSERT INTO #r_factor3 SELECT	'OR055'	,	1.1614	;
INSERT INTO #r_factor3 SELECT	'OR057'	,	166.54	;
INSERT INTO #r_factor3 SELECT	'OR067'	,	59.689	;
INSERT INTO #r_factor3 SELECT	'OR071'	,	80.879	;
INSERT INTO #r_factor3 SELECT	'OR601'	,	121.27	;
INSERT INTO #r_factor3 SELECT	'OR603'	,	21.389	;
INSERT INTO #r_factor3 SELECT	'OR604'	,	8.902	;
INSERT INTO #r_factor3 SELECT	'OR605'	,	14.521	;
INSERT INTO #r_factor3 SELECT	'OR607'	,	22.721	;
INSERT INTO #r_factor3 SELECT	'OR608'	,	55.56	;
INSERT INTO #r_factor3 SELECT	'OR610'	,	53.982	;
INSERT INTO #r_factor3 SELECT	'OR618'	,	1.3647	;
INSERT INTO #r_factor3 SELECT	'OR620'	,	7.5346	;
INSERT INTO #r_factor3 SELECT	'OR622'	,	31.66	;
INSERT INTO #r_factor3 SELECT	'OR625'	,	16.845	;
INSERT INTO #r_factor3 SELECT	'OR626'	,	6.5038	;
INSERT INTO #r_factor3 SELECT	'OR627'	,	6.5997	;
INSERT INTO #r_factor3 SELECT	'OR628'	,	3.7717	;
INSERT INTO #r_factor3 SELECT	'OR629'	,	30.054	;
INSERT INTO #r_factor3 SELECT	'OR631'	,	15.011	;
INSERT INTO #r_factor3 SELECT	'OR632'	,	21.894	;
INSERT INTO #r_factor3 SELECT	'OR635'	,	6.1262	;
INSERT INTO #r_factor3 SELECT	'OR636'	,	5.2665	;
INSERT INTO #r_factor3 SELECT	'OR637'	,	79.405	;
INSERT INTO #r_factor3 SELECT	'OR638'	,	165.72	;
INSERT INTO #r_factor3 SELECT	'OR639'	,	54.795	;
INSERT INTO #r_factor3 SELECT	'OR640'	,	14.212	;
INSERT INTO #r_factor3 SELECT	'OR641'	,	9.4906	;
INSERT INTO #r_factor3 SELECT	'OR643'	,	53.041	;
INSERT INTO #r_factor3 SELECT	'OR644'	,	5.0195	;
INSERT INTO #r_factor3 SELECT	'OR645'	,	7.8787	;
INSERT INTO #r_factor3 SELECT	'OR649'	,	77.182	;
INSERT INTO #r_factor3 SELECT	'OR654'	,	0.5426	;
INSERT INTO #r_factor3 SELECT	'OR657'	,	47.463	;
INSERT INTO #r_factor3 SELECT	'OR666'	,	0.8848	;
INSERT INTO #r_factor3 SELECT	'OR667'	,	8.6445	;
INSERT INTO #r_factor3 SELECT	'OR670'	,	16.795	;
INSERT INTO #r_factor3 SELECT	'OR673'	,	9.471	;
INSERT INTO #r_factor3 SELECT	'OR674'	,	18.191	;
INSERT INTO #r_factor3 SELECT	'OR677'	,	2.3151	;
INSERT INTO #r_factor3 SELECT	'OR680'	,	10.029	;
INSERT INTO #r_factor3 SELECT	'OR682'	,	18.912	;
INSERT INTO #r_factor3 SELECT	'OR683'	,	15.488	;
INSERT INTO #r_factor3 SELECT	'PA001'	,	137.3	;
INSERT INTO #r_factor3 SELECT	'PA003'	,	111.03	;
INSERT INTO #r_factor3 SELECT	'PA005'	,	106.91	;
INSERT INTO #r_factor3 SELECT	'PA007'	,	109.96	;
INSERT INTO #r_factor3 SELECT	'PA009'	,	113.44	;
INSERT INTO #r_factor3 SELECT	'PA011'	,	146.32	;
INSERT INTO #r_factor3 SELECT	'PA013'	,	110.14	;
INSERT INTO #r_factor3 SELECT	'PA017'	,	159.32	;
INSERT INTO #r_factor3 SELECT	'PA019'	,	106.76	;
INSERT INTO #r_factor3 SELECT	'PA021'	,	108.59	;
INSERT INTO #r_factor3 SELECT	'PA025'	,	134.37	;
INSERT INTO #r_factor3 SELECT	'PA027'	,	104.88	;
INSERT INTO #r_factor3 SELECT	'PA029'	,	167.64	;
INSERT INTO #r_factor3 SELECT	'PA031'	,	101.96	;
INSERT INTO #r_factor3 SELECT	'PA033'	,	103.04	;
INSERT INTO #r_factor3 SELECT	'PA035'	,	98.847	;
INSERT INTO #r_factor3 SELECT	'PA037'	,	113.7	;
INSERT INTO #r_factor3 SELECT	'PA039'	,	95.309	;
INSERT INTO #r_factor3 SELECT	'PA041'	,	128.63	;
INSERT INTO #r_factor3 SELECT	'PA043'	,	130.25	;
INSERT INTO #r_factor3 SELECT	'PA045'	,	170.74	;
INSERT INTO #r_factor3 SELECT	'PA049'	,	89.216	;
INSERT INTO #r_factor3 SELECT	'PA051'	,	113.14	;
INSERT INTO #r_factor3 SELECT	'PA055'	,	125.59	;
INSERT INTO #r_factor3 SELECT	'PA057'	,	118.92	;
INSERT INTO #r_factor3 SELECT	'PA061'	,	113.89	;
INSERT INTO #r_factor3 SELECT	'PA063'	,	107.47	;
INSERT INTO #r_factor3 SELECT	'PA065'	,	102.03	;
INSERT INTO #r_factor3 SELECT	'PA069'	,	108.07	;
INSERT INTO #r_factor3 SELECT	'PA071'	,	154.3	;
INSERT INTO #r_factor3 SELECT	'PA073'	,	106.58	;
INSERT INTO #r_factor3 SELECT	'PA075'	,	137.54	;
INSERT INTO #r_factor3 SELECT	'PA077'	,	145.85	;
INSERT INTO #r_factor3 SELECT	'PA079'	,	115.2	;
INSERT INTO #r_factor3 SELECT	'PA081'	,	98.259	;
INSERT INTO #r_factor3 SELECT	'PA083'	,	87.205	;
INSERT INTO #r_factor3 SELECT	'PA085'	,	101.92	;
INSERT INTO #r_factor3 SELECT	'PA089'	,	134.88	;
INSERT INTO #r_factor3 SELECT	'PA091'	,	160.88	;
INSERT INTO #r_factor3 SELECT	'PA093'	,	110.84	;
INSERT INTO #r_factor3 SELECT	'PA095'	,	146.05	;
INSERT INTO #r_factor3 SELECT	'PA097'	,	117.26	;
INSERT INTO #r_factor3 SELECT	'PA099'	,	123.68	;
INSERT INTO #r_factor3 SELECT	'PA101'	,	168.36	;
INSERT INTO #r_factor3 SELECT	'PA103'	,	126.54	;
INSERT INTO #r_factor3 SELECT	'PA105'	,	87.073	;
INSERT INTO #r_factor3 SELECT	'PA107'	,	131.99	;
INSERT INTO #r_factor3 SELECT	'PA109'	,	115.17	;
INSERT INTO #r_factor3 SELECT	'PA111'	,	111.07	;
INSERT INTO #r_factor3 SELECT	'PA115'	,	90.25	;
INSERT INTO #r_factor3 SELECT	'PA117'	,	86.811	;
INSERT INTO #r_factor3 SELECT	'PA119'	,	108.25	;
INSERT INTO #r_factor3 SELECT	'PA121'	,	99.342	;
INSERT INTO #r_factor3 SELECT	'PA127'	,	103.52	;
INSERT INTO #r_factor3 SELECT	'PA129'	,	110.25	;
INSERT INTO #r_factor3 SELECT	'PA131'	,	98.362	;
INSERT INTO #r_factor3 SELECT	'PA133'	,	147.37	;
INSERT INTO #r_factor3 SELECT	'PA605'	,	115.86	;
INSERT INTO #r_factor3 SELECT	'PA607'	,	95.51	;
INSERT INTO #r_factor3 SELECT	'PA609'	,	91.739	;
INSERT INTO #r_factor3 SELECT	'PA610'	,	91.232	;
INSERT INTO #r_factor3 SELECT	'PA611'	,	115.69	;
INSERT INTO #r_factor3 SELECT	'RI600'	,	144.27	;
INSERT INTO #r_factor3 SELECT	'SC001'	,	278.77	;
INSERT INTO #r_factor3 SELECT	'SC005'	,	319.88	;
INSERT INTO #r_factor3 SELECT	'SC007'	,	272.5	;
INSERT INTO #r_factor3 SELECT	'SC009'	,	315.27	;
INSERT INTO #r_factor3 SELECT	'SC013'	,	397.23	;
INSERT INTO #r_factor3 SELECT	'SC015'	,	368.88	;
INSERT INTO #r_factor3 SELECT	'SC017'	,	303.88	;
INSERT INTO #r_factor3 SELECT	'SC021'	,	250.26	;
INSERT INTO #r_factor3 SELECT	'SC023'	,	273.37	;
INSERT INTO #r_factor3 SELECT	'SC025'	,	288.88	;
INSERT INTO #r_factor3 SELECT	'SC027'	,	330.14	;
INSERT INTO #r_factor3 SELECT	'SC029'	,	355.91	;
INSERT INTO #r_factor3 SELECT	'SC031'	,	309.79	;
INSERT INTO #r_factor3 SELECT	'SC033'	,	342.42	;
INSERT INTO #r_factor3 SELECT	'SC035'	,	349.96	;
INSERT INTO #r_factor3 SELECT	'SC037'	,	284.71	;
INSERT INTO #r_factor3 SELECT	'SC039'	,	281.54	;
INSERT INTO #r_factor3 SELECT	'SC041'	,	343.61	;
INSERT INTO #r_factor3 SELECT	'SC043'	,	384.39	;
INSERT INTO #r_factor3 SELECT	'SC045'	,	256.24	;
INSERT INTO #r_factor3 SELECT	'SC047'	,	279.83	;
INSERT INTO #r_factor3 SELECT	'SC049'	,	341.21	;
INSERT INTO #r_factor3 SELECT	'SC051'	,	376.23	;
INSERT INTO #r_factor3 SELECT	'SC053'	,	375.1	;
INSERT INTO #r_factor3 SELECT	'SC057'	,	277.94	;
INSERT INTO #r_factor3 SELECT	'SC059'	,	274.24	;
INSERT INTO #r_factor3 SELECT	'SC061'	,	304.83	;
INSERT INTO #r_factor3 SELECT	'SC063'	,	287.7	;
INSERT INTO #r_factor3 SELECT	'SC065'	,	283.75	;
INSERT INTO #r_factor3 SELECT	'SC067'	,	358.78	;
INSERT INTO #r_factor3 SELECT	'SC069'	,	306.11	;
INSERT INTO #r_factor3 SELECT	'SC071'	,	278.66	;
INSERT INTO #r_factor3 SELECT	'SC075'	,	313.89	;
INSERT INTO #r_factor3 SELECT	'SC077'	,	256.94	;
INSERT INTO #r_factor3 SELECT	'SC079'	,	292.05	;
INSERT INTO #r_factor3 SELECT	'SC081'	,	281.93	;
INSERT INTO #r_factor3 SELECT	'SC083'	,	255.02	;
INSERT INTO #r_factor3 SELECT	'SC085'	,	309.6	;
INSERT INTO #r_factor3 SELECT	'SC087'	,	268.65	;
INSERT INTO #r_factor3 SELECT	'SC089'	,	359.79	;
INSERT INTO #r_factor3 SELECT	'SC091'	,	257.42	;
INSERT INTO #r_factor3 SELECT	'SC602'	,	264.26	;
INSERT INTO #r_factor3 SELECT	'SC604'	,	259.35	;
INSERT INTO #r_factor3 SELECT	'SC610'	,	291.08	;
INSERT INTO #r_factor3 SELECT	'SC615'	,	289.99	;
INSERT INTO #r_factor3 SELECT	'SC665'	,	302.42	;
INSERT INTO #r_factor3 SELECT	'SC690'	,	395.56	;
INSERT INTO #r_factor3 SELECT	'SC696'	,	298.43	;
INSERT INTO #r_factor3 SELECT	'SD003'	,	84.979	;
INSERT INTO #r_factor3 SELECT	'SD005'	,	78.015	;
INSERT INTO #r_factor3 SELECT	'SD007'	,	59.823	;
INSERT INTO #r_factor3 SELECT	'SD009'	,	107.92	;
INSERT INTO #r_factor3 SELECT	'SD011'	,	97.108	;
INSERT INTO #r_factor3 SELECT	'SD013'	,	75.973	;
INSERT INTO #r_factor3 SELECT	'SD019'	,	32.793	;
INSERT INTO #r_factor3 SELECT	'SD021'	,	60.745	;
INSERT INTO #r_factor3 SELECT	'SD023'	,	94.544	;
INSERT INTO #r_factor3 SELECT	'SD025'	,	81.039	;
INSERT INTO #r_factor3 SELECT	'SD027'	,	122.45	;
INSERT INTO #r_factor3 SELECT	'SD029'	,	85.277	;
INSERT INTO #r_factor3 SELECT	'SD031'	,	51.865	;
INSERT INTO #r_factor3 SELECT	'SD035'	,	91.131	;
INSERT INTO #r_factor3 SELECT	'SD037'	,	82.005	;
INSERT INTO #r_factor3 SELECT	'SD039'	,	92.393	;
INSERT INTO #r_factor3 SELECT	'SD041'	,	57.106	;
INSERT INTO #r_factor3 SELECT	'SD043'	,	94.449	;
INSERT INTO #r_factor3 SELECT	'SD045'	,	69.64	;
INSERT INTO #r_factor3 SELECT	'SD047'	,	38.033	;
INSERT INTO #r_factor3 SELECT	'SD049'	,	70.729	;
INSERT INTO #r_factor3 SELECT	'SD051'	,	87.44	;
INSERT INTO #r_factor3 SELECT	'SD053'	,	86.629	;
INSERT INTO #r_factor3 SELECT	'SD055'	,	54.635	;
INSERT INTO #r_factor3 SELECT	'SD057'	,	87.186	;
INSERT INTO #r_factor3 SELECT	'SD059'	,	73.216	;
INSERT INTO #r_factor3 SELECT	'SD063'	,	30.825	;
INSERT INTO #r_factor3 SELECT	'SD065'	,	68.643	;
INSERT INTO #r_factor3 SELECT	'SD069'	,	70.967	;
INSERT INTO #r_factor3 SELECT	'SD073'	,	79.032	;
INSERT INTO #r_factor3 SELECT	'SD075'	,	64.358	;
INSERT INTO #r_factor3 SELECT	'SD077'	,	86.127	;
INSERT INTO #r_factor3 SELECT	'SD079'	,	99.446	;
INSERT INTO #r_factor3 SELECT	'SD081'	,	33.344	;
INSERT INTO #r_factor3 SELECT	'SD083'	,	119.53	;
INSERT INTO #r_factor3 SELECT	'SD085'	,	72.946	;
INSERT INTO #r_factor3 SELECT	'SD087'	,	103.75	;
INSERT INTO #r_factor3 SELECT	'SD089'	,	67.594	;
INSERT INTO #r_factor3 SELECT	'SD091'	,	80.057	;
INSERT INTO #r_factor3 SELECT	'SD095'	,	65.894	;
INSERT INTO #r_factor3 SELECT	'SD097'	,	91.2	;
INSERT INTO #r_factor3 SELECT	'SD099'	,	111.87	;
INSERT INTO #r_factor3 SELECT	'SD101'	,	106.17	;
INSERT INTO #r_factor3 SELECT	'SD105'	,	41.269	;
INSERT INTO #r_factor3 SELECT	'SD107'	,	64.878	;
INSERT INTO #r_factor3 SELECT	'SD109'	,	83.568	;
INSERT INTO #r_factor3 SELECT	'SD111'	,	83.583	;
INSERT INTO #r_factor3 SELECT	'SD115'	,	76.845	;
INSERT INTO #r_factor3 SELECT	'SD117'	,	61.62	;
INSERT INTO #r_factor3 SELECT	'SD119'	,	65.364	;
INSERT INTO #r_factor3 SELECT	'SD121'	,	68.57	;
INSERT INTO #r_factor3 SELECT	'SD123'	,	76.657	;
INSERT INTO #r_factor3 SELECT	'SD125'	,	112.83	;
INSERT INTO #r_factor3 SELECT	'SD127'	,	126.62	;
INSERT INTO #r_factor3 SELECT	'SD129'	,	62.489	;
INSERT INTO #r_factor3 SELECT	'SD135'	,	114.76	;
INSERT INTO #r_factor3 SELECT	'SD137'	,	50.761	;
INSERT INTO #r_factor3 SELECT	'SD600'	,	40.736	;
INSERT INTO #r_factor3 SELECT	'SD601'	,	44.156	;
INSERT INTO #r_factor3 SELECT	'SD602'	,	101.64	;
INSERT INTO #r_factor3 SELECT	'SD603'	,	79.209	;
INSERT INTO #r_factor3 SELECT	'SD606'	,	45.69	;
INSERT INTO #r_factor3 SELECT	'SD607'	,	34.922	;
INSERT INTO #r_factor3 SELECT	'SD610'	,	57.59	;
INSERT INTO #r_factor3 SELECT	'SD611'	,	56.431	;
INSERT INTO #r_factor3 SELECT	'SD612'	,	48.494	;
INSERT INTO #r_factor3 SELECT	'SD613'	,	49.435	;
INSERT INTO #r_factor3 SELECT	'TN001'	,	180.9	;
INSERT INTO #r_factor3 SELECT	'TN003'	,	237.79	;
INSERT INTO #r_factor3 SELECT	'TN005'	,	246.75	;
INSERT INTO #r_factor3 SELECT	'TN007'	,	215.52	;
INSERT INTO #r_factor3 SELECT	'TN011'	,	240.5	;
INSERT INTO #r_factor3 SELECT	'TN013'	,	174.83	;
INSERT INTO #r_factor3 SELECT	'TN015'	,	221.42	;
INSERT INTO #r_factor3 SELECT	'TN017'	,	255.79	;
INSERT INTO #r_factor3 SELECT	'TN019'	,	152.71	;
INSERT INTO #r_factor3 SELECT	'TN021'	,	225.8	;
INSERT INTO #r_factor3 SELECT	'TN023'	,	274.41	;
INSERT INTO #r_factor3 SELECT	'TN025'	,	163.03	;
INSERT INTO #r_factor3 SELECT	'TN027'	,	203.39	;
INSERT INTO #r_factor3 SELECT	'TN031'	,	232.64	;
INSERT INTO #r_factor3 SELECT	'TN033'	,	270.67	;
INSERT INTO #r_factor3 SELECT	'TN035'	,	200.43	;
INSERT INTO #r_factor3 SELECT	'TN037'	,	223.54	;
INSERT INTO #r_factor3 SELECT	'TN039'	,	261.54	;
INSERT INTO #r_factor3 SELECT	'TN041'	,	213.65	;
INSERT INTO #r_factor3 SELECT	'TN043'	,	232.43	;
INSERT INTO #r_factor3 SELECT	'TN045'	,	268.33	;
INSERT INTO #r_factor3 SELECT	'TN047'	,	287.83	;
INSERT INTO #r_factor3 SELECT	'TN051'	,	249.73	;
INSERT INTO #r_factor3 SELECT	'TN053'	,	263.72	;
INSERT INTO #r_factor3 SELECT	'TN055'	,	259.41	;
INSERT INTO #r_factor3 SELECT	'TN057'	,	163.54	;
INSERT INTO #r_factor3 SELECT	'TN059'	,	158.52	;
INSERT INTO #r_factor3 SELECT	'TN061'	,	232.98	;
INSERT INTO #r_factor3 SELECT	'TN063'	,	160.65	;
INSERT INTO #r_factor3 SELECT	'TN065'	,	239.2	;
INSERT INTO #r_factor3 SELECT	'TN069'	,	283.93	;
INSERT INTO #r_factor3 SELECT	'TN071'	,	276.75	;
INSERT INTO #r_factor3 SELECT	'TN075'	,	276.02	;
INSERT INTO #r_factor3 SELECT	'TN077'	,	264.61	;
INSERT INTO #r_factor3 SELECT	'TN079'	,	246	;
INSERT INTO #r_factor3 SELECT	'TN081'	,	244.83	;
INSERT INTO #r_factor3 SELECT	'TN083'	,	235.52	;
INSERT INTO #r_factor3 SELECT	'TN085'	,	242.69	;
INSERT INTO #r_factor3 SELECT	'TN087'	,	206.53	;
INSERT INTO #r_factor3 SELECT	'TN089'	,	167.85	;
INSERT INTO #r_factor3 SELECT	'TN091'	,	145.28	;
INSERT INTO #r_factor3 SELECT	'TN093'	,	178.36	;
INSERT INTO #r_factor3 SELECT	'TN095'	,	264.1	;
INSERT INTO #r_factor3 SELECT	'TN097'	,	275.03	;
INSERT INTO #r_factor3 SELECT	'TN099'	,	265.41	;
INSERT INTO #r_factor3 SELECT	'TN101'	,	253.66	;
INSERT INTO #r_factor3 SELECT	'TN103'	,	255.32	;
INSERT INTO #r_factor3 SELECT	'TN105'	,	192.55	;
INSERT INTO #r_factor3 SELECT	'TN107'	,	215.2	;
INSERT INTO #r_factor3 SELECT	'TN109'	,	280.82	;
INSERT INTO #r_factor3 SELECT	'TN111'	,	208.04	;
INSERT INTO #r_factor3 SELECT	'TN113'	,	272.01	;
INSERT INTO #r_factor3 SELECT	'TN115'	,	246.98	;
INSERT INTO #r_factor3 SELECT	'TN117'	,	244.9	;
INSERT INTO #r_factor3 SELECT	'TN119'	,	244.61	;
INSERT INTO #r_factor3 SELECT	'TN121'	,	212.05	;
INSERT INTO #r_factor3 SELECT	'TN123'	,	210.22	;
INSERT INTO #r_factor3 SELECT	'TN125'	,	225.51	;
INSERT INTO #r_factor3 SELECT	'TN127'	,	246.97	;
INSERT INTO #r_factor3 SELECT	'TN131'	,	259.84	;
INSERT INTO #r_factor3 SELECT	'TN133'	,	201.18	;
INSERT INTO #r_factor3 SELECT	'TN135'	,	255.29	;
INSERT INTO #r_factor3 SELECT	'TN139'	,	242.25	;
INSERT INTO #r_factor3 SELECT	'TN143'	,	208.96	;
INSERT INTO #r_factor3 SELECT	'TN145'	,	192.82	;
INSERT INTO #r_factor3 SELECT	'TN147'	,	217.72	;
INSERT INTO #r_factor3 SELECT	'TN149'	,	225.34	;
INSERT INTO #r_factor3 SELECT	'TN153'	,	229.99	;
INSERT INTO #r_factor3 SELECT	'TN157'	,	291.81	;
INSERT INTO #r_factor3 SELECT	'TN159'	,	210.9	;
INSERT INTO #r_factor3 SELECT	'TN161'	,	233.71	;
INSERT INTO #r_factor3 SELECT	'TN163'	,	144.01	;
INSERT INTO #r_factor3 SELECT	'TN165'	,	213.56	;
INSERT INTO #r_factor3 SELECT	'TN167'	,	281.14	;
INSERT INTO #r_factor3 SELECT	'TN169'	,	211.26	;
INSERT INTO #r_factor3 SELECT	'TN171'	,	161.39	;
INSERT INTO #r_factor3 SELECT	'TN173'	,	170.36	;
INSERT INTO #r_factor3 SELECT	'TN177'	,	221.34	;
INSERT INTO #r_factor3 SELECT	'TN179'	,	151.67	;
INSERT INTO #r_factor3 SELECT	'TN181'	,	270.79	;
INSERT INTO #r_factor3 SELECT	'TN183'	,	253.91	;
INSERT INTO #r_factor3 SELECT	'TN187'	,	231.49	;
INSERT INTO #r_factor3 SELECT	'TN189'	,	216.87	;
INSERT INTO #r_factor3 SELECT	'TN602'	,	151.63	;
INSERT INTO #r_factor3 SELECT	'TN604'	,	211.85	;
INSERT INTO #r_factor3 SELECT	'TN606'	,	169.93	;
INSERT INTO #r_factor3 SELECT	'TN607'	,	181.73	;
INSERT INTO #r_factor3 SELECT	'TN608'	,	176.22	;
INSERT INTO #r_factor3 SELECT	'TN609'	,	188.43	;
INSERT INTO #r_factor3 SELECT	'TN610'	,	206.06	;
INSERT INTO #r_factor3 SELECT	'TN629'	,	190.54	;
INSERT INTO #r_factor3 SELECT	'TN640'	,	191.31	;
INSERT INTO #r_factor3 SELECT	'TN650'	,	185.04	;
INSERT INTO #r_factor3 SELECT	'TN701'	,	195.43	;
INSERT INTO #r_factor3 SELECT	'TX001'	,	360.93	;
INSERT INTO #r_factor3 SELECT	'TX003'	,	62.927	;
INSERT INTO #r_factor3 SELECT	'TX005'	,	426.19	;
INSERT INTO #r_factor3 SELECT	'TX009'	,	211.48	;
INSERT INTO #r_factor3 SELECT	'TX011'	,	119.25	;
INSERT INTO #r_factor3 SELECT	'TX013'	,	246.3	;
INSERT INTO #r_factor3 SELECT	'TX017'	,	43.131	;
INSERT INTO #r_factor3 SELECT	'TX019'	,	215.3	;
INSERT INTO #r_factor3 SELECT	'TX021'	,	305.17	;
INSERT INTO #r_factor3 SELECT	'TX023'	,	191.18	;
INSERT INTO #r_factor3 SELECT	'TX025'	,	269.76	;
INSERT INTO #r_factor3 SELECT	'TX027'	,	286.1	;
INSERT INTO #r_factor3 SELECT	'TX029'	,	247.29	;
INSERT INTO #r_factor3 SELECT	'TX033'	,	111.94	;
INSERT INTO #r_factor3 SELECT	'TX035'	,	267.57	;
INSERT INTO #r_factor3 SELECT	'TX037'	,	333.52	;
INSERT INTO #r_factor3 SELECT	'TX039'	,	466.36	;
INSERT INTO #r_factor3 SELECT	'TX041'	,	363.93	;
INSERT INTO #r_factor3 SELECT	'TX045'	,	121.79	;
INSERT INTO #r_factor3 SELECT	'TX047'	,	257.53	;
INSERT INTO #r_factor3 SELECT	'TX051'	,	348.11	;
INSERT INTO #r_factor3 SELECT	'TX055'	,	289.63	;
INSERT INTO #r_factor3 SELECT	'TX057'	,	318.99	;
INSERT INTO #r_factor3 SELECT	'TX059'	,	189.26	;
INSERT INTO #r_factor3 SELECT	'TX061'	,	296.03	;
INSERT INTO #r_factor3 SELECT	'TX065'	,	117.24	;
INSERT INTO #r_factor3 SELECT	'TX069'	,	73.326	;
INSERT INTO #r_factor3 SELECT	'TX071'	,	519.13	;
INSERT INTO #r_factor3 SELECT	'TX073'	,	380.19	;
INSERT INTO #r_factor3 SELECT	'TX075'	,	151.9	;
INSERT INTO #r_factor3 SELECT	'TX077'	,	227.41	;
INSERT INTO #r_factor3 SELECT	'TX079'	,	48.426	;
INSERT INTO #r_factor3 SELECT	'TX081'	,	154.14	;
INSERT INTO #r_factor3 SELECT	'TX083'	,	193.51	;
INSERT INTO #r_factor3 SELECT	'TX085'	,	295.7	;
INSERT INTO #r_factor3 SELECT	'TX087'	,	148.06	;
INSERT INTO #r_factor3 SELECT	'TX089'	,	354.32	;
INSERT INTO #r_factor3 SELECT	'TX093'	,	225.84	;
INSERT INTO #r_factor3 SELECT	'TX095'	,	185.99	;
INSERT INTO #r_factor3 SELECT	'TX097'	,	271.14	;
INSERT INTO #r_factor3 SELECT	'TX099'	,	266.64	;
INSERT INTO #r_factor3 SELECT	'TX101'	,	152.2	;
INSERT INTO #r_factor3 SELECT	'TX105'	,	126.58	;
INSERT INTO #r_factor3 SELECT	'TX107'	,	113.31	;
INSERT INTO #r_factor3 SELECT	'TX111'	,	69.917	;
INSERT INTO #r_factor3 SELECT	'TX113'	,	293.57	;
INSERT INTO #r_factor3 SELECT	'TX115'	,	89.628	;
INSERT INTO #r_factor3 SELECT	'TX117'	,	69.163	;
INSERT INTO #r_factor3 SELECT	'TX121'	,	276.42	;
INSERT INTO #r_factor3 SELECT	'TX123'	,	289.9	;
INSERT INTO #r_factor3 SELECT	'TX125'	,	135.19	;
INSERT INTO #r_factor3 SELECT	'TX129'	,	131.43	;
INSERT INTO #r_factor3 SELECT	'TX131'	,	249.53	;
INSERT INTO #r_factor3 SELECT	'TX133'	,	209.45	;
INSERT INTO #r_factor3 SELECT	'TX139'	,	300.56	;
INSERT INTO #r_factor3 SELECT	'TX143'	,	237.31	;
INSERT INTO #r_factor3 SELECT	'TX145'	,	310.72	;
INSERT INTO #r_factor3 SELECT	'TX147'	,	301.05	;
INSERT INTO #r_factor3 SELECT	'TX149'	,	326.86	;
INSERT INTO #r_factor3 SELECT	'TX151'	,	149.42	;
INSERT INTO #r_factor3 SELECT	'TX153'	,	115.54	;
INSERT INTO #r_factor3 SELECT	'TX155'	,	167.19	;
INSERT INTO #r_factor3 SELECT	'TX157'	,	436.93	;
INSERT INTO #r_factor3 SELECT	'TX161'	,	344.38	;
INSERT INTO #r_factor3 SELECT	'TX163'	,	227.06	;
INSERT INTO #r_factor3 SELECT	'TX165'	,	59.712	;
INSERT INTO #r_factor3 SELECT	'TX167'	,	501.49	;
INSERT INTO #r_factor3 SELECT	'TX169'	,	113.3	;
INSERT INTO #r_factor3 SELECT	'TX171'	,	228.39	;
INSERT INTO #r_factor3 SELECT	'TX173'	,	114.16	;
INSERT INTO #r_factor3 SELECT	'TX175'	,	279.79	;
INSERT INTO #r_factor3 SELECT	'TX177'	,	290.96	;
INSERT INTO #r_factor3 SELECT	'TX179'	,	128.35	;
INSERT INTO #r_factor3 SELECT	'TX181'	,	288.22	;
INSERT INTO #r_factor3 SELECT	'TX185'	,	385.46	;
INSERT INTO #r_factor3 SELECT	'TX187'	,	274.05	;
INSERT INTO #r_factor3 SELECT	'TX189'	,	91.096	;
INSERT INTO #r_factor3 SELECT	'TX191'	,	138.49	;
INSERT INTO #r_factor3 SELECT	'TX193'	,	249.22	;
INSERT INTO #r_factor3 SELECT	'TX195'	,	103.16	;
INSERT INTO #r_factor3 SELECT	'TX197'	,	166.4	;
INSERT INTO #r_factor3 SELECT	'TX199'	,	506.73	;
INSERT INTO #r_factor3 SELECT	'TX201'	,	464.66	;
INSERT INTO #r_factor3 SELECT	'TX203'	,	367.1	;
INSERT INTO #r_factor3 SELECT	'TX205'	,	70.815	;
INSERT INTO #r_factor3 SELECT	'TX207'	,	169.91	;
INSERT INTO #r_factor3 SELECT	'TX211'	,	139.49	;
INSERT INTO #r_factor3 SELECT	'TX213'	,	339.09	;
INSERT INTO #r_factor3 SELECT	'TX215'	,	271.14	;
INSERT INTO #r_factor3 SELECT	'TX217'	,	289.72	;
INSERT INTO #r_factor3 SELECT	'TX219'	,	64.348	;
INSERT INTO #r_factor3 SELECT	'TX225'	,	392.39	;
INSERT INTO #r_factor3 SELECT	'TX227'	,	114.59	;
INSERT INTO #r_factor3 SELECT	'TX231'	,	308.34	;
INSERT INTO #r_factor3 SELECT	'TX233'	,	111.34	;
INSERT INTO #r_factor3 SELECT	'TX235'	,	139.23	;
INSERT INTO #r_factor3 SELECT	'TX237'	,	232.7	;
INSERT INTO #r_factor3 SELECT	'TX239'	,	338.79	;
INSERT INTO #r_factor3 SELECT	'TX243'	,	35.051	;
INSERT INTO #r_factor3 SELECT	'TX247'	,	249.61	;
INSERT INTO #r_factor3 SELECT	'TX249'	,	255.52	;
INSERT INTO #r_factor3 SELECT	'TX251'	,	274.02	;
INSERT INTO #r_factor3 SELECT	'TX253'	,	166.69	;
INSERT INTO #r_factor3 SELECT	'TX255'	,	270.94	;
INSERT INTO #r_factor3 SELECT	'TX259'	,	239.59	;
INSERT INTO #r_factor3 SELECT	'TX263'	,	133.82	;
INSERT INTO #r_factor3 SELECT	'TX265'	,	210.79	;
INSERT INTO #r_factor3 SELECT	'TX267'	,	194.94	;
INSERT INTO #r_factor3 SELECT	'TX269'	,	152.14	;
INSERT INTO #r_factor3 SELECT	'TX271'	,	172.84	;
INSERT INTO #r_factor3 SELECT	'TX275'	,	168.79	;
INSERT INTO #r_factor3 SELECT	'TX279'	,	63.114	;
INSERT INTO #r_factor3 SELECT	'TX281'	,	250.67	;
INSERT INTO #r_factor3 SELECT	'TX283'	,	231.15	;
INSERT INTO #r_factor3 SELECT	'TX285'	,	319.8	;
INSERT INTO #r_factor3 SELECT	'TX287'	,	325.63	;
INSERT INTO #r_factor3 SELECT	'TX289'	,	364.03	;
INSERT INTO #r_factor3 SELECT	'TX291'	,	488.55	;
INSERT INTO #r_factor3 SELECT	'TX293'	,	326.67	;
INSERT INTO #r_factor3 SELECT	'TX295'	,	132.86	;
INSERT INTO #r_factor3 SELECT	'TX297'	,	257.17	;
INSERT INTO #r_factor3 SELECT	'TX299'	,	237.02	;
INSERT INTO #r_factor3 SELECT	'TX303'	,	90.69	;
INSERT INTO #r_factor3 SELECT	'TX305'	,	91.79	;
INSERT INTO #r_factor3 SELECT	'TX307'	,	205.75	;
INSERT INTO #r_factor3 SELECT	'TX309'	,	291.39	;
INSERT INTO #r_factor3 SELECT	'TX311'	,	246.39	;
INSERT INTO #r_factor3 SELECT	'TX313'	,	377.99	;
INSERT INTO #r_factor3 SELECT	'TX317'	,	91.452	;
INSERT INTO #r_factor3 SELECT	'TX319'	,	213.22	;
INSERT INTO #r_factor3 SELECT	'TX321'	,	401.62	;
INSERT INTO #r_factor3 SELECT	'TX323'	,	181.32	;
INSERT INTO #r_factor3 SELECT	'TX325'	,	223.76	;
INSERT INTO #r_factor3 SELECT	'TX327'	,	191.12	;
INSERT INTO #r_factor3 SELECT	'TX329'	,	94.793	;
INSERT INTO #r_factor3 SELECT	'TX331'	,	319.4	;
INSERT INTO #r_factor3 SELECT	'TX335'	,	133.89	;
INSERT INTO #r_factor3 SELECT	'TX337'	,	250.69	;
INSERT INTO #r_factor3 SELECT	'TX339'	,	432.04	;
INSERT INTO #r_factor3 SELECT	'TX341'	,	95.54	;
INSERT INTO #r_factor3 SELECT	'TX345'	,	136.23	;
INSERT INTO #r_factor3 SELECT	'TX347'	,	410.99	;
INSERT INTO #r_factor3 SELECT	'TX349'	,	320.77	;
INSERT INTO #r_factor3 SELECT	'TX353'	,	153.54	;
INSERT INTO #r_factor3 SELECT	'TX355'	,	265.48	;
INSERT INTO #r_factor3 SELECT	'TX357'	,	118.45	;
INSERT INTO #r_factor3 SELECT	'TX359'	,	73.456	;
INSERT INTO #r_factor3 SELECT	'TX363'	,	228.54	;
INSERT INTO #r_factor3 SELECT	'TX365'	,	391.43	;
INSERT INTO #r_factor3 SELECT	'TX367'	,	251.2	;
INSERT INTO #r_factor3 SELECT	'TX369'	,	47.761	;
INSERT INTO #r_factor3 SELECT	'TX371'	,	73.951	;
INSERT INTO #r_factor3 SELECT	'TX375'	,	99.625	;
INSERT INTO #r_factor3 SELECT	'TX377'	,	37.168	;
INSERT INTO #r_factor3 SELECT	'TX381'	,	98.504	;
INSERT INTO #r_factor3 SELECT	'TX387'	,	319.3	;
INSERT INTO #r_factor3 SELECT	'TX389'	,	40.275	;
INSERT INTO #r_factor3 SELECT	'TX391'	,	282.45	;
INSERT INTO #r_factor3 SELECT	'TX393'	,	124.95	;
INSERT INTO #r_factor3 SELECT	'TX395'	,	344.57	;
INSERT INTO #r_factor3 SELECT	'TX399'	,	173.75	;
INSERT INTO #r_factor3 SELECT	'TX401'	,	381.54	;
INSERT INTO #r_factor3 SELECT	'TX411'	,	224.95	;
INSERT INTO #r_factor3 SELECT	'TX413'	,	157.9	;
INSERT INTO #r_factor3 SELECT	'TX415'	,	129.48	;
INSERT INTO #r_factor3 SELECT	'TX417'	,	186.04	;
INSERT INTO #r_factor3 SELECT	'TX419'	,	412.66	;
INSERT INTO #r_factor3 SELECT	'TX421'	,	89.188	;
INSERT INTO #r_factor3 SELECT	'TX423'	,	351.36	;
INSERT INTO #r_factor3 SELECT	'TX427'	,	254.84	;
INSERT INTO #r_factor3 SELECT	'TX429'	,	207.93	;
INSERT INTO #r_factor3 SELECT	'TX431'	,	131.94	;
INSERT INTO #r_factor3 SELECT	'TX433'	,	151.51	;
INSERT INTO #r_factor3 SELECT	'TX435'	,	159.57	;
INSERT INTO #r_factor3 SELECT	'TX437'	,	101.87	;
INSERT INTO #r_factor3 SELECT	'TX439'	,	272.46	;
INSERT INTO #r_factor3 SELECT	'TX441'	,	169.98	;
INSERT INTO #r_factor3 SELECT	'TX443'	,	102.62	;
INSERT INTO #r_factor3 SELECT	'TX445'	,	68.296	;
INSERT INTO #r_factor3 SELECT	'TX447'	,	191.96	;
INSERT INTO #r_factor3 SELECT	'TX451'	,	161.28	;
INSERT INTO #r_factor3 SELECT	'TX453'	,	281.44	;
INSERT INTO #r_factor3 SELECT	'TX455'	,	412.39	;
INSERT INTO #r_factor3 SELECT	'TX457'	,	464.87	;
INSERT INTO #r_factor3 SELECT	'TX463'	,	198.19	;
INSERT INTO #r_factor3 SELECT	'TX465'	,	139.19	;
INSERT INTO #r_factor3 SELECT	'TX467'	,	328.02	;
INSERT INTO #r_factor3 SELECT	'TX469'	,	301.43	;
INSERT INTO #r_factor3 SELECT	'TX471'	,	402.95	;
INSERT INTO #r_factor3 SELECT	'TX475'	,	55.682	;
INSERT INTO #r_factor3 SELECT	'TX477'	,	363.85	;
INSERT INTO #r_factor3 SELECT	'TX479'	,	229.42	;
INSERT INTO #r_factor3 SELECT	'TX481'	,	383.13	;
INSERT INTO #r_factor3 SELECT	'TX483'	,	144.06	;
INSERT INTO #r_factor3 SELECT	'TX485'	,	206.85	;
INSERT INTO #r_factor3 SELECT	'TX487'	,	186.25	;
INSERT INTO #r_factor3 SELECT	'TX489'	,	283.76	;
INSERT INTO #r_factor3 SELECT	'TX491'	,	286.98	;
INSERT INTO #r_factor3 SELECT	'TX493'	,	264.73	;
INSERT INTO #r_factor3 SELECT	'TX497'	,	254.59	;
INSERT INTO #r_factor3 SELECT	'TX499'	,	333.63	;
INSERT INTO #r_factor3 SELECT	'TX501'	,	50.66	;
INSERT INTO #r_factor3 SELECT	'TX503'	,	214.2	;
INSERT INTO #r_factor3 SELECT	'TX505'	,	242.29	;
INSERT INTO #r_factor3 SELECT	'TX600'	,	386.11	;
INSERT INTO #r_factor3 SELECT	'TX601'	,	256.07	;
INSERT INTO #r_factor3 SELECT	'TX602'	,	218.89	;
INSERT INTO #r_factor3 SELECT	'TX603'	,	332.91	;
INSERT INTO #r_factor3 SELECT	'TX604'	,	264.44	;
INSERT INTO #r_factor3 SELECT	'TX605'	,	204.21	;
INSERT INTO #r_factor3 SELECT	'TX606'	,	73.902	;
INSERT INTO #r_factor3 SELECT	'TX607'	,	180.4	;
INSERT INTO #r_factor3 SELECT	'TX608'	,	350.43	;
INSERT INTO #r_factor3 SELECT	'TX609'	,	255.59	;
INSERT INTO #r_factor3 SELECT	'TX610'	,	320.09	;
INSERT INTO #r_factor3 SELECT	'TX611'	,	492.44	;
INSERT INTO #r_factor3 SELECT	'TX612'	,	311.65	;
INSERT INTO #r_factor3 SELECT	'TX613'	,	269.51	;
INSERT INTO #r_factor3 SELECT	'TX614'	,	309.92	;
INSERT INTO #r_factor3 SELECT	'TX615'	,	49.394	;
INSERT INTO #r_factor3 SELECT	'TX616'	,	347.88	;
INSERT INTO #r_factor3 SELECT	'TX617'	,	439.56	;
INSERT INTO #r_factor3 SELECT	'TX618'	,	107.54	;
INSERT INTO #r_factor3 SELECT	'TX619'	,	439.42	;
INSERT INTO #r_factor3 SELECT	'TX620'	,	275.23	;
INSERT INTO #r_factor3 SELECT	'TX621'	,	71.038	;
INSERT INTO #r_factor3 SELECT	'TX622'	,	62.144	;
INSERT INTO #r_factor3 SELECT	'TX623'	,	557.85	;
INSERT INTO #r_factor3 SELECT	'TX624'	,	8.8467	;
INSERT INTO #r_factor3 SELECT	'TX625'	,	19.937	;
INSERT INTO #r_factor3 SELECT	'TX626'	,	25.888	;
INSERT INTO #r_factor3 SELECT	'TX627'	,	15.779	;
INSERT INTO #r_factor3 SELECT	'UT013'	,	9.9961	;
INSERT INTO #r_factor3 SELECT	'UT047'	,	10.008	;
INSERT INTO #r_factor3 SELECT	'UT601'	,	9.3484	;
INSERT INTO #r_factor3 SELECT	'UT602'	,	10.713	;
INSERT INTO #r_factor3 SELECT	'UT603'	,	15.179	;
INSERT INTO #r_factor3 SELECT	'UT604'	,	9.9599	;
INSERT INTO #r_factor3 SELECT	'UT607'	,	16.458	;
INSERT INTO #r_factor3 SELECT	'UT608'	,	9.8924	;
INSERT INTO #r_factor3 SELECT	'UT609'	,	19.517	;
INSERT INTO #r_factor3 SELECT	'UT611'	,	8.8983	;
INSERT INTO #r_factor3 SELECT	'UT612'	,	13.662	;
INSERT INTO #r_factor3 SELECT	'UT613'	,	11.897	;
INSERT INTO #r_factor3 SELECT	'UT616'	,	10.002	;
INSERT INTO #r_factor3 SELECT	'UT617'	,	9.8689	;
INSERT INTO #r_factor3 SELECT	'UT618'	,	9.9325	;
INSERT INTO #r_factor3 SELECT	'UT621'	,	10.003	;
INSERT INTO #r_factor3 SELECT	'UT622'	,	11.835	;
INSERT INTO #r_factor3 SELECT	'UT623'	,	10.01	;
INSERT INTO #r_factor3 SELECT	'UT624'	,	9.9453	;
INSERT INTO #r_factor3 SELECT	'UT625'	,	9.9938	;
INSERT INTO #r_factor3 SELECT	'UT626'	,	9.9957	;
INSERT INTO #r_factor3 SELECT	'UT627'	,	9.9977	;
INSERT INTO #r_factor3 SELECT	'UT628'	,	9.998	;
INSERT INTO #r_factor3 SELECT	'UT629'	,	10.001	;
INSERT INTO #r_factor3 SELECT	'UT631'	,	9.9229	;
INSERT INTO #r_factor3 SELECT	'UT632'	,	9.8632	;
INSERT INTO #r_factor3 SELECT	'UT633'	,	9.603	;
INSERT INTO #r_factor3 SELECT	'UT634'	,	10.129	;
INSERT INTO #r_factor3 SELECT	'UT636'	,	10.061	;
INSERT INTO #r_factor3 SELECT	'UT638'	,	12.536	;
INSERT INTO #r_factor3 SELECT	'UT639'	,	11.036	;
INSERT INTO #r_factor3 SELECT	'UT640'	,	9.9889	;
INSERT INTO #r_factor3 SELECT	'UT641'	,	9.9066	;
INSERT INTO #r_factor3 SELECT	'UT642'	,	10.851	;
INSERT INTO #r_factor3 SELECT	'UT643'	,	15.169	;
INSERT INTO #r_factor3 SELECT	'UT645'	,	10.061	;
INSERT INTO #r_factor3 SELECT	'UT646'	,	10.116	;
INSERT INTO #r_factor3 SELECT	'UT647'	,	10.833	;
INSERT INTO #r_factor3 SELECT	'UT648'	,	10.083	;
INSERT INTO #r_factor3 SELECT	'UT649'	,	9.9771	;
INSERT INTO #r_factor3 SELECT	'UT650'	,	11.885	;
INSERT INTO #r_factor3 SELECT	'UT651'	,	10.008	;
INSERT INTO #r_factor3 SELECT	'UT653'	,	9.9997	;
INSERT INTO #r_factor3 SELECT	'UT685'	,	9.9993	;
INSERT INTO #r_factor3 SELECT	'UT686'	,	10.021	;
INSERT INTO #r_factor3 SELECT	'UT687'	,	9.8562	;
INSERT INTO #r_factor3 SELECT	'UT688'	,	9.328	;
INSERT INTO #r_factor3 SELECT	'UT689'	,	9.5924	;
INSERT INTO #r_factor3 SELECT	'VA001'	,	226.91	;
INSERT INTO #r_factor3 SELECT	'VA003'	,	155.86	;
INSERT INTO #r_factor3 SELECT	'VA005'	,	126.43	;
INSERT INTO #r_factor3 SELECT	'VA007'	,	195.81	;
INSERT INTO #r_factor3 SELECT	'VA009'	,	151.46	;
INSERT INTO #r_factor3 SELECT	'VA011'	,	171.49	;
INSERT INTO #r_factor3 SELECT	'VA013'	,	179.93	;
INSERT INTO #r_factor3 SELECT	'VA015'	,	129.3	;
INSERT INTO #r_factor3 SELECT	'VA017'	,	122.42	;
INSERT INTO #r_factor3 SELECT	'VA019'	,	157.56	;
INSERT INTO #r_factor3 SELECT	'VA021'	,	123.48	;
INSERT INTO #r_factor3 SELECT	'VA023'	,	138.7	;
INSERT INTO #r_factor3 SELECT	'VA025'	,	217.59	;
INSERT INTO #r_factor3 SELECT	'VA027'	,	131.1	;
INSERT INTO #r_factor3 SELECT	'VA029'	,	170.47	;
INSERT INTO #r_factor3 SELECT	'VA033'	,	195.11	;
INSERT INTO #r_factor3 SELECT	'VA035'	,	141.06	;
INSERT INTO #r_factor3 SELECT	'VA036'	,	216.74	;
INSERT INTO #r_factor3 SELECT	'VA037'	,	189.18	;
INSERT INTO #r_factor3 SELECT	'VA041'	,	204.49	;
INSERT INTO #r_factor3 SELECT	'VA043'	,	142.91	;
INSERT INTO #r_factor3 SELECT	'VA045'	,	130.13	;
INSERT INTO #r_factor3 SELECT	'VA047'	,	172.38	;
INSERT INTO #r_factor3 SELECT	'VA049'	,	181.8	;
INSERT INTO #r_factor3 SELECT	'VA051'	,	136.74	;
INSERT INTO #r_factor3 SELECT	'VA057'	,	202.61	;
INSERT INTO #r_factor3 SELECT	'VA059'	,	177.64	;
INSERT INTO #r_factor3 SELECT	'VA061'	,	167.08	;
INSERT INTO #r_factor3 SELECT	'VA063'	,	141.82	;
INSERT INTO #r_factor3 SELECT	'VA065'	,	173.11	;
INSERT INTO #r_factor3 SELECT	'VA067'	,	159.69	;
INSERT INTO #r_factor3 SELECT	'VA069'	,	131.52	;
INSERT INTO #r_factor3 SELECT	'VA071'	,	124.35	;
INSERT INTO #r_factor3 SELECT	'VA073'	,	220.51	;
INSERT INTO #r_factor3 SELECT	'VA075'	,	188.45	;
INSERT INTO #r_factor3 SELECT	'VA077'	,	138.84	;
INSERT INTO #r_factor3 SELECT	'VA079'	,	155.37	;
INSERT INTO #r_factor3 SELECT	'VA081'	,	230.85	;
INSERT INTO #r_factor3 SELECT	'VA083'	,	192.4	;
INSERT INTO #r_factor3 SELECT	'VA085'	,	198.06	;
INSERT INTO #r_factor3 SELECT	'VA087'	,	204.47	;
INSERT INTO #r_factor3 SELECT	'VA089'	,	176.47	;
INSERT INTO #r_factor3 SELECT	'VA091'	,	119.23	;
INSERT INTO #r_factor3 SELECT	'VA093'	,	237.64	;
INSERT INTO #r_factor3 SELECT	'VA097'	,	208.29	;
INSERT INTO #r_factor3 SELECT	'VA101'	,	205.8	;
INSERT INTO #r_factor3 SELECT	'VA105'	,	150.49	;
INSERT INTO #r_factor3 SELECT	'VA107'	,	155.69	;
INSERT INTO #r_factor3 SELECT	'VA109'	,	181.91	;
INSERT INTO #r_factor3 SELECT	'VA111'	,	199.93	;
INSERT INTO #r_factor3 SELECT	'VA113'	,	162.69	;
INSERT INTO #r_factor3 SELECT	'VA115'	,	222.11	;
INSERT INTO #r_factor3 SELECT	'VA117'	,	206.81	;
INSERT INTO #r_factor3 SELECT	'VA119'	,	215	;
INSERT INTO #r_factor3 SELECT	'VA121'	,	133.17	;
INSERT INTO #r_factor3 SELECT	'VA125'	,	148.95	;
INSERT INTO #r_factor3 SELECT	'VA127'	,	212.71	;
INSERT INTO #r_factor3 SELECT	'VA131'	,	232.73	;
INSERT INTO #r_factor3 SELECT	'VA133'	,	211.61	;
INSERT INTO #r_factor3 SELECT	'VA135'	,	198.94	;
INSERT INTO #r_factor3 SELECT	'VA137'	,	174.71	;
INSERT INTO #r_factor3 SELECT	'VA139'	,	148.73	;
INSERT INTO #r_factor3 SELECT	'VA141'	,	160.01	;
INSERT INTO #r_factor3 SELECT	'VA143'	,	182.04	;
INSERT INTO #r_factor3 SELECT	'VA145'	,	192.61	;
INSERT INTO #r_factor3 SELECT	'VA147'	,	186.3	;
INSERT INTO #r_factor3 SELECT	'VA149'	,	219.4	;
INSERT INTO #r_factor3 SELECT	'VA153'	,	176.82	;
INSERT INTO #r_factor3 SELECT	'VA155'	,	128.15	;
INSERT INTO #r_factor3 SELECT	'VA157'	,	160.33	;
INSERT INTO #r_factor3 SELECT	'VA159'	,	204.53	;
INSERT INTO #r_factor3 SELECT	'VA161'	,	143.18	;
INSERT INTO #r_factor3 SELECT	'VA163'	,	134.34	;
INSERT INTO #r_factor3 SELECT	'VA165'	,	131.36	;
INSERT INTO #r_factor3 SELECT	'VA167'	,	133.63	;
INSERT INTO #r_factor3 SELECT	'VA169'	,	143.08	;
INSERT INTO #r_factor3 SELECT	'VA171'	,	135.41	;
INSERT INTO #r_factor3 SELECT	'VA173'	,	128.99	;
INSERT INTO #r_factor3 SELECT	'VA175'	,	240.3	;
INSERT INTO #r_factor3 SELECT	'VA177'	,	184.69	;
INSERT INTO #r_factor3 SELECT	'VA179'	,	186.82	;
INSERT INTO #r_factor3 SELECT	'VA181'	,	227.06	;
INSERT INTO #r_factor3 SELECT	'VA183'	,	229.16	;
INSERT INTO #r_factor3 SELECT	'VA185'	,	125.01	;
INSERT INTO #r_factor3 SELECT	'VA187'	,	147.92	;
INSERT INTO #r_factor3 SELECT	'VA191'	,	136.05	;
INSERT INTO #r_factor3 SELECT	'VA193'	,	199.81	;
INSERT INTO #r_factor3 SELECT	'VA195'	,	141.64	;
INSERT INTO #r_factor3 SELECT	'VA197'	,	127.74	;
INSERT INTO #r_factor3 SELECT	'VA510'	,	181.44	;
INSERT INTO #r_factor3 SELECT	'VA515'	,	156.19	;
INSERT INTO #r_factor3 SELECT	'VA540'	,	158.56	;
INSERT INTO #r_factor3 SELECT	'VA550'	,	257.3	;
INSERT INTO #r_factor3 SELECT	'VA600'	,	176.95	;
INSERT INTO #r_factor3 SELECT	'VA606'	,	132.48	;
INSERT INTO #r_factor3 SELECT	'VA610'	,	178.45	;
INSERT INTO #r_factor3 SELECT	'VA630'	,	185.61	;
INSERT INTO #r_factor3 SELECT	'VA631'	,	171.18	;
INSERT INTO #r_factor3 SELECT	'VA653'	,	212.83	;
INSERT INTO #r_factor3 SELECT	'VA695'	,	222.89	;
INSERT INTO #r_factor3 SELECT	'VA715'	,	235.99	;
INSERT INTO #r_factor3 SELECT	'VA760'	,	202.88	;
INSERT INTO #r_factor3 SELECT	'VA790'	,	129.16	;
INSERT INTO #r_factor3 SELECT	'VA800'	,	249.86	;
INSERT INTO #r_factor3 SELECT	'VA810'	,	258.09	;
INSERT INTO #r_factor3 SELECT	'VA820'	,	139.47	;
INSERT INTO #r_factor3 SELECT	'VA840'	,	135.03	;
INSERT INTO #r_factor3 SELECT	'VA850'	,	149.47	;
INSERT INTO #r_factor3 SELECT	'VT001'	,	80.374	;
INSERT INTO #r_factor3 SELECT	'VT003'	,	95.411	;
INSERT INTO #r_factor3 SELECT	'VT005'	,	76.969	;
INSERT INTO #r_factor3 SELECT	'VT007'	,	78.654	;
INSERT INTO #r_factor3 SELECT	'VT009'	,	75.599	;
INSERT INTO #r_factor3 SELECT	'VT011'	,	72.809	;
INSERT INTO #r_factor3 SELECT	'VT013'	,	72.747	;
INSERT INTO #r_factor3 SELECT	'VT015'	,	76.276	;
INSERT INTO #r_factor3 SELECT	'VT017'	,	79.625	;
INSERT INTO #r_factor3 SELECT	'VT019'	,	73.765	;
INSERT INTO #r_factor3 SELECT	'VT021'	,	83.838	;
INSERT INTO #r_factor3 SELECT	'VT023'	,	78.777	;
INSERT INTO #r_factor3 SELECT	'VT025'	,	96.121	;
INSERT INTO #r_factor3 SELECT	'VT027'	,	84.48	;
INSERT INTO #r_factor3 SELECT	'WA001'	,	4.17	;
INSERT INTO #r_factor3 SELECT	'WA011'	,	83.348	;
INSERT INTO #r_factor3 SELECT	'WA015'	,	70.89	;
INSERT INTO #r_factor3 SELECT	'WA017'	,	6.9018	;
INSERT INTO #r_factor3 SELECT	'WA021'	,	2.0756	;
INSERT INTO #r_factor3 SELECT	'WA025'	,	3.5587	;
INSERT INTO #r_factor3 SELECT	'WA029'	,	32.736	;
INSERT INTO #r_factor3 SELECT	'WA043'	,	7.7077	;
INSERT INTO #r_factor3 SELECT	'WA055'	,	26.007	;
INSERT INTO #r_factor3 SELECT	'WA063'	,	11.045	;
INSERT INTO #r_factor3 SELECT	'WA065'	,	10.688	;
INSERT INTO #r_factor3 SELECT	'WA071'	,	5.8657	;
INSERT INTO #r_factor3 SELECT	'WA075'	,	10.824	;
INSERT INTO #r_factor3 SELECT	'WA603'	,	18.377	;
INSERT INTO #r_factor3 SELECT	'WA605'	,	1.2558	;
INSERT INTO #r_factor3 SELECT	'WA607'	,	9.9281	;
INSERT INTO #r_factor3 SELECT	'WA608'	,	22.788	;
INSERT INTO #r_factor3 SELECT	'WA609'	,	107.93	;
INSERT INTO #r_factor3 SELECT	'WA613'	,	8.9921	;
INSERT INTO #r_factor3 SELECT	'WA619'	,	10.497	;
INSERT INTO #r_factor3 SELECT	'WA623'	,	11.412	;
INSERT INTO #r_factor3 SELECT	'WA627'	,	154.05	;
INSERT INTO #r_factor3 SELECT	'WA631'	,	160.52	;
INSERT INTO #r_factor3 SELECT	'WA632'	,	187.82	;
INSERT INTO #r_factor3 SELECT	'WA633'	,	47.573	;
INSERT INTO #r_factor3 SELECT	'WA634'	,	84.363	;
INSERT INTO #r_factor3 SELECT	'WA635'	,	93.472	;
INSERT INTO #r_factor3 SELECT	'WA637'	,	22.482	;
INSERT INTO #r_factor3 SELECT	'WA639'	,	5.4172	;
INSERT INTO #r_factor3 SELECT	'WA641'	,	69.367	;
INSERT INTO #r_factor3 SELECT	'WA645'	,	171.43	;
INSERT INTO #r_factor3 SELECT	'WA648'	,	9.1735	;
INSERT INTO #r_factor3 SELECT	'WA649'	,	7.3086	;
INSERT INTO #r_factor3 SELECT	'WA651'	,	12.473	;
INSERT INTO #r_factor3 SELECT	'WA653'	,	50.11	;
INSERT INTO #r_factor3 SELECT	'WA657'	,	83.978	;
INSERT INTO #r_factor3 SELECT	'WA659'	,	94.579	;
INSERT INTO #r_factor3 SELECT	'WA661'	,	71.357	;
INSERT INTO #r_factor3 SELECT	'WA667'	,	72.591	;
INSERT INTO #r_factor3 SELECT	'WA673'	,	73.659	;
INSERT INTO #r_factor3 SELECT	'WA676'	,	8.8014	;
INSERT INTO #r_factor3 SELECT	'WA677'	,	3.6536	;
INSERT INTO #r_factor3 SELECT	'WA678'	,	1.7497	;
INSERT INTO #r_factor3 SELECT	'WA680'	,	18.446	;
INSERT INTO #r_factor3 SELECT	'WA681'	,	1.4535	;
INSERT INTO #r_factor3 SELECT	'WA706'	,	0.5374	;
INSERT INTO #r_factor3 SELECT	'WA710'	,	126.09	;
INSERT INTO #r_factor3 SELECT	'WA714'	,	19.216	;
INSERT INTO #r_factor3 SELECT	'WA728'	,	211.86	;
INSERT INTO #r_factor3 SELECT	'WA730'	,	153.48	;
INSERT INTO #r_factor3 SELECT	'WA749'	,	16.015	;
INSERT INTO #r_factor3 SELECT	'WA754'	,	41.113	;
INSERT INTO #r_factor3 SELECT	'WA760'	,	51.932	;
INSERT INTO #r_factor3 SELECT	'WA762'	,	100.04	;
INSERT INTO #r_factor3 SELECT	'WA774'	,	58.309	;
INSERT INTO #r_factor3 SELECT	'WA775'	,	37.816	;
INSERT INTO #r_factor3 SELECT	'WA776'	,	41.123	;
INSERT INTO #r_factor3 SELECT	'WA777'	,	45.871	;
INSERT INTO #r_factor3 SELECT	'WA778'	,	99.403	;
INSERT INTO #r_factor3 SELECT	'WI001'	,	127.53	;
INSERT INTO #r_factor3 SELECT	'WI003'	,	99.595	;
INSERT INTO #r_factor3 SELECT	'WI005'	,	128	;
INSERT INTO #r_factor3 SELECT	'WI007'	,	97.688	;
INSERT INTO #r_factor3 SELECT	'WI009'	,	90.904	;
INSERT INTO #r_factor3 SELECT	'WI011'	,	151.38	;
INSERT INTO #r_factor3 SELECT	'WI013'	,	108.6	;
INSERT INTO #r_factor3 SELECT	'WI017'	,	138.12	;
INSERT INTO #r_factor3 SELECT	'WI019'	,	136.45	;
INSERT INTO #r_factor3 SELECT	'WI021'	,	125.05	;
INSERT INTO #r_factor3 SELECT	'WI023'	,	156.16	;
INSERT INTO #r_factor3 SELECT	'WI025'	,	136.92	;
INSERT INTO #r_factor3 SELECT	'WI027'	,	115.08	;
INSERT INTO #r_factor3 SELECT	'WI029'	,	85.195	;
INSERT INTO #r_factor3 SELECT	'WI031'	,	99.412	;
INSERT INTO #r_factor3 SELECT	'WI033'	,	138.4	;
INSERT INTO #r_factor3 SELECT	'WI035'	,	145.55	;
INSERT INTO #r_factor3 SELECT	'WI037'	,	87.939	;
INSERT INTO #r_factor3 SELECT	'WI039'	,	104.23	;
INSERT INTO #r_factor3 SELECT	'WI041'	,	91.326	;
INSERT INTO #r_factor3 SELECT	'WI043'	,	157.23	;
INSERT INTO #r_factor3 SELECT	'WI045'	,	148.93	;
INSERT INTO #r_factor3 SELECT	'WI047'	,	113.66	;
INSERT INTO #r_factor3 SELECT	'WI049'	,	151.45	;
INSERT INTO #r_factor3 SELECT	'WI051'	,	97.727	;
INSERT INTO #r_factor3 SELECT	'WI053'	,	146.43	;
INSERT INTO #r_factor3 SELECT	'WI055'	,	126.32	;
INSERT INTO #r_factor3 SELECT	'WI057'	,	137.43	;
INSERT INTO #r_factor3 SELECT	'WI061'	,	88.367	;
INSERT INTO #r_factor3 SELECT	'WI063'	,	153.31	;
INSERT INTO #r_factor3 SELECT	'WI065'	,	154.87	;
INSERT INTO #r_factor3 SELECT	'WI067'	,	97.225	;
INSERT INTO #r_factor3 SELECT	'WI069'	,	106.54	;
INSERT INTO #r_factor3 SELECT	'WI073'	,	114.68	;
INSERT INTO #r_factor3 SELECT	'WI075'	,	87.387	;
INSERT INTO #r_factor3 SELECT	'WI077'	,	121.16	;
INSERT INTO #r_factor3 SELECT	'WI078'	,	94.736	;
INSERT INTO #r_factor3 SELECT	'WI081'	,	148.09	;
INSERT INTO #r_factor3 SELECT	'WI083'	,	90.28	;
INSERT INTO #r_factor3 SELECT	'WI085'	,	98.508	;
INSERT INTO #r_factor3 SELECT	'WI087'	,	95.362	;
INSERT INTO #r_factor3 SELECT	'WI089'	,	103.52	;
INSERT INTO #r_factor3 SELECT	'WI091'	,	145.34	;
INSERT INTO #r_factor3 SELECT	'WI093'	,	133.65	;
INSERT INTO #r_factor3 SELECT	'WI095'	,	118.32	;
INSERT INTO #r_factor3 SELECT	'WI097'	,	113.95	;
INSERT INTO #r_factor3 SELECT	'WI099'	,	112.32	;
INSERT INTO #r_factor3 SELECT	'WI103'	,	151.23	;
INSERT INTO #r_factor3 SELECT	'WI105'	,	141.36	;
INSERT INTO #r_factor3 SELECT	'WI107'	,	128.24	;
INSERT INTO #r_factor3 SELECT	'WI109'	,	126.96	;
INSERT INTO #r_factor3 SELECT	'WI111'	,	141.26	;
INSERT INTO #r_factor3 SELECT	'WI113'	,	116.22	;
INSERT INTO #r_factor3 SELECT	'WI115'	,	96.437	;
INSERT INTO #r_factor3 SELECT	'WI117'	,	97.84	;
INSERT INTO #r_factor3 SELECT	'WI119'	,	126.27	;
INSERT INTO #r_factor3 SELECT	'WI121'	,	152.22	;
INSERT INTO #r_factor3 SELECT	'WI123'	,	153	;
INSERT INTO #r_factor3 SELECT	'WI125'	,	94.814	;
INSERT INTO #r_factor3 SELECT	'WI127'	,	131.98	;
INSERT INTO #r_factor3 SELECT	'WI129'	,	115.11	;
INSERT INTO #r_factor3 SELECT	'WI131'	,	107.97	;
INSERT INTO #r_factor3 SELECT	'WI135'	,	101.07	;
INSERT INTO #r_factor3 SELECT	'WI137'	,	113.1	;
INSERT INTO #r_factor3 SELECT	'WI139'	,	101.71	;
INSERT INTO #r_factor3 SELECT	'WI141'	,	127.66	;
INSERT INTO #r_factor3 SELECT	'WI600'	,	94.037	;
INSERT INTO #r_factor3 SELECT	'WI601'	,	126.61	;
INSERT INTO #r_factor3 SELECT	'WI602'	,	118.26	;
INSERT INTO #r_factor3 SELECT	'WV001'	,	119.14	;
INSERT INTO #r_factor3 SELECT	'WV003'	,	128.92	;
INSERT INTO #r_factor3 SELECT	'WV005'	,	128.76	;
INSERT INTO #r_factor3 SELECT	'WV007'	,	124.36	;
INSERT INTO #r_factor3 SELECT	'WV011'	,	137.84	;
INSERT INTO #r_factor3 SELECT	'WV015'	,	125.32	;
INSERT INTO #r_factor3 SELECT	'WV017'	,	125.03	;
INSERT INTO #r_factor3 SELECT	'WV021'	,	125.56	;
INSERT INTO #r_factor3 SELECT	'WV025'	,	122.31	;
INSERT INTO #r_factor3 SELECT	'WV037'	,	138.94	;
INSERT INTO #r_factor3 SELECT	'WV039'	,	128.06	;
INSERT INTO #r_factor3 SELECT	'WV041'	,	123.71	;
INSERT INTO #r_factor3 SELECT	'WV043'	,	134.65	;
INSERT INTO #r_factor3 SELECT	'WV047'	,	125.5	;
INSERT INTO #r_factor3 SELECT	'WV051'	,	120.26	;
INSERT INTO #r_factor3 SELECT	'WV063'	,	123.85	;
INSERT INTO #r_factor3 SELECT	'WV065'	,	122.61	;
INSERT INTO #r_factor3 SELECT	'WV071'	,	118.55	;
INSERT INTO #r_factor3 SELECT	'WV075'	,	119.25	;
INSERT INTO #r_factor3 SELECT	'WV077'	,	115.54	;
INSERT INTO #r_factor3 SELECT	'WV079'	,	133.02	;
INSERT INTO #r_factor3 SELECT	'WV085'	,	126.47	;
INSERT INTO #r_factor3 SELECT	'WV097'	,	121	;
INSERT INTO #r_factor3 SELECT	'WV099'	,	140.57	;
INSERT INTO #r_factor3 SELECT	'WV101'	,	121.5	;
INSERT INTO #r_factor3 SELECT	'WV103'	,	122.62	;
INSERT INTO #r_factor3 SELECT	'WV109'	,	125.38	;
INSERT INTO #r_factor3 SELECT	'WV600'	,	132.23	;
INSERT INTO #r_factor3 SELECT	'WV601'	,	128.18	;
INSERT INTO #r_factor3 SELECT	'WV602'	,	116.5	;
INSERT INTO #r_factor3 SELECT	'WV603'	,	118.3	;
INSERT INTO #r_factor3 SELECT	'WV604'	,	115.05	;
INSERT INTO #r_factor3 SELECT	'WV608'	,	118.86	;
INSERT INTO #r_factor3 SELECT	'WV610'	,	121.48	;
INSERT INTO #r_factor3 SELECT	'WV611'	,	118.75	;
INSERT INTO #r_factor3 SELECT	'WV612'	,	125.3	;
INSERT INTO #r_factor3 SELECT	'WV620'	,	132.55	;
INSERT INTO #r_factor3 SELECT	'WV621'	,	124.39	;
INSERT INTO #r_factor3 SELECT	'WV622'	,	123.36	;
INSERT INTO #r_factor3 SELECT	'WV623'	,	122.58	;
INSERT INTO #r_factor3 SELECT	'WV624'	,	127.21	;
INSERT INTO #r_factor3 SELECT	'WV628'	,	119.48	;
INSERT INTO #r_factor3 SELECT	'WV705'	,	124.22	;
INSERT INTO #r_factor3 SELECT	'WV713'	,	122.65	;
INSERT INTO #r_factor3 SELECT	'WV767'	,	123.54	;
INSERT INTO #r_factor3 SELECT	'WY011'	,	28.347	;
INSERT INTO #r_factor3 SELECT	'WY027'	,	18.224	;
INSERT INTO #r_factor3 SELECT	'WY031'	,	24.297	;
INSERT INTO #r_factor3 SELECT	'WY041'	,	7.3053	;
INSERT INTO #r_factor3 SELECT	'WY043'	,	10.667	;
INSERT INTO #r_factor3 SELECT	'WY045'	,	30.211	;
INSERT INTO #r_factor3 SELECT	'WY601'	,	10.117	;
INSERT INTO #r_factor3 SELECT	'WY603'	,	10.314	;
INSERT INTO #r_factor3 SELECT	'WY605'	,	23.825	;
INSERT INTO #r_factor3 SELECT	'WY609'	,	9.6635	;
INSERT INTO #r_factor3 SELECT	'WY613'	,	9.9723	;
INSERT INTO #r_factor3 SELECT	'WY615'	,	35.678	;
INSERT INTO #r_factor3 SELECT	'WY617'	,	10.034	;
INSERT INTO #r_factor3 SELECT	'WY619'	,	16.103	;
INSERT INTO #r_factor3 SELECT	'WY621'	,	33.985	;
INSERT INTO #r_factor3 SELECT	'WY622'	,	12.622	;
INSERT INTO #r_factor3 SELECT	'WY623'	,	9.7174	;
INSERT INTO #r_factor3 SELECT	'WY625'	,	10.697	;
INSERT INTO #r_factor3 SELECT	'WY629'	,	9.9666	;
INSERT INTO #r_factor3 SELECT	'WY630'	,	9.2791	;
INSERT INTO #r_factor3 SELECT	'WY632'	,	6.9512	;
INSERT INTO #r_factor3 SELECT	'WY633'	,	18.925	;
INSERT INTO #r_factor3 SELECT	'WY635'	,	8.9127	;
INSERT INTO #r_factor3 SELECT	'WY636'	,	8.5034	;
INSERT INTO #r_factor3 SELECT	'WY638'	,	9.799	;
INSERT INTO #r_factor3 SELECT	'WY647'	,	9.8939	;
INSERT INTO #r_factor3 SELECT	'WY650'	,	14.297	;
INSERT INTO #r_factor3 SELECT	'WY656'	,	9.9127	;
INSERT INTO #r_factor3 SELECT	'WY661'	,	9.9431	;
INSERT INTO #r_factor3 SELECT	'WY662'	,	9.5201	;
INSERT INTO #r_factor3 SELECT	'WY663'	,	9.2877	;
INSERT INTO #r_factor3 SELECT	'WY665'	,	9.9945	;
INSERT INTO #r_factor3 SELECT	'WY666'	,	9.9988	;
INSERT INTO #r_factor3 SELECT	'WY667'	,	10.001	;
INSERT INTO #r_factor3 SELECT	'WY677'	,	9.725	;
INSERT INTO #r_factor3 SELECT	'WY705'	,	22.878	;
INSERT INTO #r_factor3 SELECT	'WY709'	,	12.016	;
INSERT INTO #r_factor3 SELECT	'WY713'	,	9.9284	;
INSERT INTO #r_factor3 SELECT	'WY715'	,	30.518	;
INSERT INTO #r_factor3 SELECT	'WY719'	,	19.88	;
INSERT INTO #r_factor3 SELECT	'WY721'	,	17.538	;
INSERT INTO #r_factor3 SELECT	'WY723'	,	7.7867	;
INSERT INTO #r_factor3 SELECT	'WY737'	,	9.2443	;


SELECT 	f.areasymbol AS f_areasymbol,
		rf.areasymbol AS rf_areasymbol, --new
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
		r_factor , -- new
		kwfact		,  -- new
		taxorder	,  -- new
		((r_factor)*(kwfact)*(ls_factor))/tfact AS erosion_index,
		((r_factor)*(kwfact)*(ls_factor)) water_sensitive,
		datestamp 
FROM #fifth AS f
LEFT OUTER JOIN #r_factor3  AS rf ON rf.areasymbol=f.areasymbol
INNER JOIN #horizon5 AS h ON h.cokey=f.cokey

GROUP BY 	f.areasymbol ,
		rf.areasymbol ,
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
ORDER BY f.areasymbol, muname, mukey, f.cokey  

 DROP TABLE IF EXISTS #main3;
 DROP TABLE IF EXISTS #second2;
 DROP TABLE IF EXISTS #third2;
 DROP TABLE IF EXISTS #fourth3;
 DROP TABLE IF EXISTS #r_factor3 ;
 DROP TABLE IF EXISTS #fifth;
 DROP TABLE IF EXISTS #horizon3;
 DROP TABLE IF EXISTS #horizon4;
 DROP TABLE IF EXISTS #horizon5;