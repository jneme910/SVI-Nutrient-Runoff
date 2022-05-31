DROP TABLE IF EXISTS #main3;
DROP TABLE IF EXISTS #second2;

--Define the area
DECLARE @area VARCHAR(20);
DECLARE @area_type INT ;
DECLARE @major INT;

-- Soil Data Access
/*~DeclareChar(@area,20)~  -- Used for Soil Data Access
~DeclareINT(@area_type)~
*/
--~DeclareINT(@area_type)~ 
-- End soil data access

SELECT @area= 'WI025'; --Enter State Abbreviation or Soil Survey Area i.e. WI or WI025
SELECT @area_type = LEN (@area); --determines number of characters of area 2-State, 5- Soil Survey Area
SELECT @major = 0; -- Enter 0 for major component, enter 1 for all components

CREATE TABLE #main3
    (
        areaname         VARCHAR(255),
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
        areaname,
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
 INNER JOIN  mapunit AS mu ON mu.lkey = l.lkey AND  CASE WHEN @area_type = 2 THEN LEFT (l.areasymbol, 2) ELSE l.areasymbol END = @area
 INNER JOIN  component AS c ON c.mukey = mu.mukey AND majcompflag = 'Yes'
 ORDER BY sc.areasymbol, musym, muname, mu.mukey

CREATE TABLE #second2
    (
        areaname         VARCHAR(255),
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
        areaname ,
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

 SELECT areaname ,
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


 SELECT areaname ,
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
		slope_length
FROM #second2

 DROP TABLE IF EXISTS #main3;
 DROP TABLE IF EXISTS #second2;