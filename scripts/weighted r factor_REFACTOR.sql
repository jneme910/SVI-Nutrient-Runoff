USE [sdmONLINE]
GO

/********************************************************************
--
--Identify records needing updates.
--
********************************************************************/
If Object_ID('tempdb..#sacatalog_updates','U') Is Not Null
  Drop Table [#sacatalog_updates]

SELECT DISTINCT
	[areasymbol]
INTO [#sacatalog_updates]
FROM [sacatalog] WITH(NOLOCK)
WHERE 
	[saverest] >= (SELECT IsNull(MAX([update_date]),'1900-01-01') FROM _tempMuRFactor3)
		

/********************************************************************
--
--  Compile Records to Staging Table
--  
********************************************************************/
If Object_ID('dbo._StageMuRFactor','U') Is Not Null
  Drop Table dbo.[_StageMuRFactor]
  
CREATE TABLE [_StageMuRFactor](
	 [mukey] INT NOT NULL	
	,[areasymbol] varchar(20) NULL
	,[r_factor] float NULL
	,[muareaacres] numeric(38,8) NULL	
)

DECLARE @id_control INT
DECLARE @batchSize INT
Declare @message varchar(500)
Declare @batchdate datetime2
Declare @timeout varchar(100)
DECLARE @TimeInSeconds INT

SET @batchSize =  1000000
SET @id_control = 279725467

Declare @OriginalStart int = @id_control

WHILE (@id_control < (select max(mupolygonkey) from dbo.mupolygon))
                     
BEGIN
   BEGIN TRAN;
   SET @batchdate = sysdatetime()
   
				insert into [_StageMuRFactor]
				SELECT mukey
					,areasymbol
					,r_factor
					--,GEOGRAPHY::STGeomFromWKB(mupolygongeo.MakeValid().STUnion(mupolygongeo.STStartPoint()).Reduce(0.000001).STAsBinary(), 4326).STArea() * 0.000247105381 AS macres1
					,muareaacres
				FROM (
					SELECT m.mukey
						,m.areasymbol
						,m.mupolygongeo
						,m.muareaacres
						,areasymbolstr
					FROM dbo.mupolygon M with(nolock)
					INNER JOIN  [#sacatalog_updates] A  ON A.areasymbol = m.areasymbol
					CROSS APPLY (
						SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(m.[areasymbol], '0', ''), '1', ''), '2', ''), '3', ''), '4', ''), '5', ''), '6', ''), '7', ''), '8', ''), '9', '') areasymbolstr
						) AS mupolystr
					where
						mupolygonkey >= @id_control
						AND mupolygonkey <@id_control + @batchSize						
					) mu
				INNER JOIN (
					SELECT r.r_factor
						,r.geom
						,cofipsstr
					FROM sdm_spatial.dbo.r_factor R with(index([ si_r_factor_geom_idx5]))
					CROSS APPLY (
						SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(r.co_fips, '0', ''), '1', ''), '2', ''), '3', ''), '4', ''), '5', ''), '6', ''), '7', ''), '8', ''), '9', '') cofipsstr
						) AS rfactstr
					) r
					ON mu.areasymbolstr = r.cofipsstr
				WHERE mupolygongeo.STIntersects(geom) = 1
					
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

/********************************************************************
--
--  Perform Calculation Results
--  
********************************************************************/
If Object_ID('tempdb..#MuRFactorCalculations','U') Is Not Null
  Drop Table [#MuRFactorCalculations]
  
CREATE TABLE [dbo].[#MuRFactorCalculations](
	 [mukey] INT NOT NULL	
	,[wgav_r_factor] [float] NULL	
)
   INSERT INTO [#MuRFactorCalculations]
   SELECT 
		 mukey
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
				FROM [_StageMuRFactor]
				) a					
			GROUP BY mukey
				,areasymbol
				,r_factor
				,sum_rfact_acres
				,sum_mukey_acres
				,sum_rfact_acres / sum_mukey_acres
			) b
		) c
	GROUP BY 
		 mukey
		,weighted_average_r_factor

/********************************************************************
--
--  Merge Into Final Table
--  
********************************************************************/
 
    MERGE [_tempMuRFactor3] AS [Target]
    USING [#MuRFactorCalculations] AS [Source]
    ON [Source].[mukey] = [Target].[mukey]
    
    -- For Inserts
    WHEN NOT MATCHED BY Target THEN
        INSERT ([mukey],[wgav_r_factor], [insert_date],[update_date]) 
        VALUES ([Source].[mukey],[Source].[wgav_r_factor], Getdate(),Getdate())
    
    -- For Updates
    WHEN MATCHED THEN UPDATE SET
        Target.[mukey]				= [Source].[mukey],
        Target.[wgav_r_factor]		= [Source].[wgav_r_factor],
		Target.[update_date]		= GetDate();

	