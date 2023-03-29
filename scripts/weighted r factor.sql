USE [sdmONLINE]
GO

--Uncomment if beginning from scratch
/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[_tempMuRFactor]') AND type in (N'U'))
DROP TABLE [dbo].[_tempMuRFactor]
GO


CREATE TABLE [dbo].[_tempMuRFactor](
	id int identity(1,1),
	[mukey] [int] NOT NULL,
	[wgav_r_factor] [float] NULL
) ON [FG1]
*/

DECLARE @id_control INT
DECLARE @batchSize INT
DECLARE @results INT
Declare @message varchar(500)
Declare @batchdate datetime2
Declare @timeout varchar(100)
DECLARE @TimeInSeconds INT

SET @results = 1
SET @batchSize = 25000
SET @id_control = 279725467

Declare @OriginalStart int = @id_control

WHILE (@id_control < 332862163) --332,862,163
BEGIN
   BEGIN TRAN;
   SET @batchdate = sysdatetime()

   Insert into _tempMuRFactor
   SELECT mukey
		,weighted_average_r_factor AS wgav_r_factor
	FROM (
		SELECT mukey
			,ROUND(SUM(r_factor * pct) OVER (PARTITION BY mukey), 2) AS weighted_average_r_factor
		FROM (
			SELECT mukey
				,r_factor
				,sum_rfact_acres / sum_mukey_acres AS pct
			FROM (
				SELECT mukey
					,areasymbol
					,r_factor
					--,GEOGRAPHY::STGeomFromWKB(mupolygongeo.MakeValid().STUnion(mupolygongeo.STStartPoint()).Reduce(0.000001).STAsBinary(), 4326).STArea() * 0.000247105381 AS macres1
					,SUM(muareaacres) OVER (PARTITION BY mukey, r_factor) AS sum_rfact_acres
					,SUM(muareaacres) OVER (PARTITION BY mukey) AS sum_mukey_acres
				FROM (
					SELECT m.mukey
						,m.areasymbol
						,m.mupolygongeo
						,m.muareaacres
						,areasymbolstr
					FROM dbo.mupolygon M
					CROSS APPLY (
						SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(m.[areasymbol], '0', ''), '1', ''), '2', ''), '3', ''), '4', ''), '5', ''), '6', ''), '7', ''), '8', ''), '9', '') areasymbolstr
						) AS mupolystr
					where
						mupolygonkey >= @id_control
						AND mupolygonkey < @id_control + @batchSize
					) mu
				INNER JOIN (
					SELECT r.r_factor
						,r.geom
						,cofipsstr
					FROM sdm_spatial.dbo.r_factor R
					CROSS APPLY (
						SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(r.co_fips, '0', ''), '1', ''), '2', ''), '3', ''), '4', ''), '5', ''), '6', ''), '7', ''), '8', ''), '9', '') cofipsstr
						) AS rfactstr
					) r
					ON mu.areasymbolstr = r.cofipsstr
				WHERE mupolygongeo.STIntersects(geom) = 1
				) temp1
			GROUP BY mukey
				,areasymbol
				,r_factor
				,sum_rfact_acres
				,sum_mukey_acres
				,sum_rfact_acres / sum_mukey_acres
			) temp2
		) temp3
	GROUP BY mukey
		,weighted_average_r_factor

   -- very important to obtain the latest rowcount to avoid infinite loops
   SET @results = @@ROWCOUNT

   
   -- next batch
	SELECT @id_control = min([mupolygonkey])
	FROM [sdmONLINE].[dbo].[mupolygon]
	WHERE mupolygonkey >= @id_control + @batchSize

	SET @TimeInSeconds = DATEDIFF(SECOND, @batchdate, sysdatetime())
	Set @timeout = 
		RIGHT('0' + CAST(@TimeInSeconds / 3600 AS VARCHAR),2) + ':' +
		RIGHT('0' + CAST((@TimeInSeconds / 60) % 60 AS VARCHAR),2) + ':' +
		RIGHT('0' + CAST(@TimeInSeconds % 60 AS VARCHAR),2)
	
	set @message = convert(varchar(100),@id_control-1) + ' is now done (' + convert(varchar(100),(@id_control-@OriginalStart) * 100.0 / (332862163-@OriginalStart)) + ' batch, ' + convert(varchar(15),str(@id_control * 100.0 / 332862163,12,2)) + ' total) ' + @timeout + ' - ' + CONVERT(varchar,getdate(),14)
	
	--print @message --Just in case the raiserror doesn't output.
	RAISERROR (@message, 0, 1) WITH NOWAIT

	COMMIT TRAN;

END



--CREATE TABLE [sdm_spatial].[dbo].[mukey_r_factor2]

--   ( rfmkey INT IDENTITY (1,1),
--    mukey INT,
--    wgav_r_factor REAL)

--INSERT INTO [sdm_spatial].[dbo].[mukey_r_factor2] ( mukey , wgav_r_factor)
--SELECT mukey, weighted_average_r_factor AS wgav_r_factor
--FROM #rftemp3
--GROUP BY mukey, weighted_average_r_factor 

