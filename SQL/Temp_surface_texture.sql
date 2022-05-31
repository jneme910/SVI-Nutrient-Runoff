--# Get K factor value for surface horizon
--Define the area
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


SELECT TOP 1000 l.areasymbol, muname, compname, c1.cokey, ch1.chkey, hzdept_r, hzdepb_r,  CASE WHEN hzdepb_r IS NULL THEN NULL
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
WHEN hzdept_r < @InRangeBot then hzdept_r ELSE @InRangeTop END AS thickness2


FROM  sacatalog AS  sc
 INNER JOIN legend  AS l ON l.areasymbol = sc.areasymbol
 INNER JOIN  mapunit AS mu ON mu.lkey = l.lkey AND  CASE WHEN @area_type = 2 THEN LEFT (l.areasymbol, 2) ELSE l.areasymbol END = @area
INNER JOIN  component AS c1 ON c1.mukey = mu.mukey AND majcompflag = 'Yes' AND c1.cokey = 21387231
INNER JOIN chorizon AS ch1 ON ch1.cokey=c1.cokey AND hzdepb_r > @InRangeTop AND hzdept_r < @InRangeBot 
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
FROM chorizon INNER JOIN chtexturegrp AS cht2 ON chorizon.chkey = cht2.chkey
AND cht2.texture Not In ('SPM','HPM', 'MPM') AND cht2.rvindicator='Yes' AND c1.cokey = chorizon.cokey )))

ORDER BY areasymbol, musym, muname, mu.mukey, comppct_r DESC, cokey,  hzdept_r, hzdepb_r

--INNER JOIN chtexturegrp AS chtg1 ON chtg1.chkey=ch1.chkey AND chtg1.rvindicator = 'yes'
--INNER JOIN chtexture AS cht1 ON cht1.chtgkey=cht1.chtgkey

--GROUP BY l.areasymbol, muname, compname, c1.cokey, ch1.chkey, hzdept_r, hzdepb_r, hzname, desgnmaster, -- lieutex 
--kwfact, taxorder
--ORDER BY c1.cokey ASC, ch1.chkey ASC, hzdept_r ASC, hzdepb_r ASC


/*	join chtexturegrp to chtexture 
AND (desgnmaster is null or not (desgnmaster in ("O", "O'", "O''")) OR not (lieutex in ("mpm", "mpt", "muck", "peat", "spm", "udom", "pdom", "hpm")) OR hzname is null or not (hzname in ("O*")));
    sort by hzdept_r, hzdepb_r
    aggregate column hzdept_r none, hzdepb_r none, kwfact none.

# Find thickness of each horizon in 0-15cm range.
 derive layer_thickness using "NSSC Pangaea":"HORIZON THICKNESS IN RANGE" (0,15).

# Determine the maximum horizon thickness in the range.
 define max_thickness arraymax(layer_thickness).

# From thickest horizon in range, return kwfact.
define erosfact  arraymax(lookup(max_thickness, layer_thickness, codename(kwfact)) + 0).

define rv if codename(taxorder) == "histosols" then 0.02 else erosfact.


CASE WHEN hzdepb_r IS NULL THEN 0
WHEN hzdept_r IS NULL THEN 0 ELSE hzdepb_r-hzdept_r END AS thickness, 
CASE  WHEN hzdept_r < 15 then hzdept_r ELSE 0 END AS AGG_InRangeTop_0_15, 
CASE  WHEN hzdepb_r <= 15 THEN hzdepb_r WHEN hzdepb_r > 15 and hzdept_r < 15 THEN 15 ELSE 0 END AS AGG_InRangeBot_0_15
*/