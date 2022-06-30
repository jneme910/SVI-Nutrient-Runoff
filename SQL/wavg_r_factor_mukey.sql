USE sdm;

DROP TABLE IF EXISTS #rftemp1
DROP TABLE IF EXISTS #rftemp2
DROP TABLE IF EXISTS #rftemp3
SELECT
m.mukey
, m.areasymbol
,  R.r_factor

,GEOGRAPHY::STGeomFromWKB(mupolygongeo.MakeValid().STUnion(mupolygongeo.STStartPoint()).Reduce(0.000001).STAsBinary(),4326).STArea()* 0.000247105381AS macres1


,SUM(muareaacres) over(partition by mukey, r_factor) as sum_rfact_acres
,SUM(muareaacres) over(partition by mukey) as sum_mukey_acres

INTO #rftemp1
from sdm.dbo.mupolygon M,
sdm_spatial.dbo.r_factor R

where --areasymbol like 'WI025'
--and 
M.mupolygongeo.STIntersects(r.geom) = 1 --and mukey = 1415048

order by areasymbol

SELECT DISTINCT mukey,	areasymbol,	r_factor,	--macres1,	
sum_rfact_acres , sum_mukey_acres  , sum_rfact_acres/sum_mukey_acres AS pct
INTO #rftemp2
FROM #rftemp1
ORDER BY sum_rfact_acres DESC

SELECT mukey,
areasymbol,
r_factor,
sum_rfact_acres,
sum_mukey_acres,
pct,
r_factor*pct AS r_pct,
ROUND (SUM(r_factor*pct) over(partition by mukey),2) as weighted_average_r_factor
INTO #rftemp3
FROM #rftemp2
ORDER BY sum_rfact_acres DESC

CREATE TABLE [sdm_spatial].[dbo].[mukey_r_factor2]

   ( rfmkey INT IDENTITY (1,1),
    mukey INT,
    wgav_r_factor REAL)

INSERT INTO [sdm_spatial].[dbo].[mukey_r_factor2] ( mukey , wgav_r_factor)
SELECT mukey, weighted_average_r_factor AS wgav_r_factor
FROM #rftemp3
GROUP BY mukey, weighted_average_r_factor 

