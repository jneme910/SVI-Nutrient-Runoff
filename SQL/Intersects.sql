/*USE [sdm_spatial]
GO

SELECT [rfiid]
      ,[geom]
      ,[fid]
      ,[rusle_req]
      ,[rec_link]
      ,[shape_leng]
      ,[shape_area]
      ,[co_fips]
      ,[st_numb]
      ,[co_numb]
      ,[co_name]
      ,[ei_rang]
      ,[cli_key]
      ,[co_num5]
      ,[tcli_key]
      ,[r_factor]
  FROM [dbo].[sdm_spatial].[r_factor]

GO


SELECT [areasymbol]
      ,[spatialversion]
      ,[musym]
      ,[nationalmusym]
      ,[mukey]
      ,[muareaacres]
      ,[mupolygongeo]
      ,[mupolygonproj]
      ,[mupolygonkey]
      ,[PointAcreage]
      ,[LineAcreage]
  FROM [dbo].[sdmONLINE][mupolygon]

GO
*/
SELECT TOP 1
M.mukey
, M.[mupolygonkey]
, A.[r_factor]
,  M.mupolygongeo.STIntersection(A.geom ) AS soilgeom
FROM [sdmONLINE].[dbo].[mupolygon] M, [sdm_spatial].[dbo].[r_factor] A
    WHERE mupolygongeo.STIntersects(A.geom) = 1;

