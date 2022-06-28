/****** Script for SelectTopNRows command from SSMS  ******/
CREATE TABLE r_factor6
( rfiid2 INT IDENTITY (1,1),
	[geom] [geometry] NULL,
	[fid] [int] NULL,

	[rusle_req] [varchar](254) NULL,
	[rec_link] [varchar](254) NULL,
	[shape_leng] [float] NULL,
	[shape_area] [float] NULL,
	[co_fips] [varchar](254) NULL,
	[st_numb] [varchar](254) NULL,
	[co_numb] [varchar](254) NULL,
	[co_name] [varchar](254) NULL,
	[ei_rang] [varchar](254) NULL,
	[cli_key] [varchar](254) NULL,
	[co_num5] [varchar](254) NULL,
	[tcli_key] [varchar](50) NULL,
	[r_factor] [real] NULL,
	  -- CONSTRAINT pk_lab_map PRIMARY KEY CLUSTERED ([Pedon_Key])
	 -- )

	 CONSTRAINT [pk_r_factor6] PRIMARY KEY CLUSTERED 
(
     rfiid2
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)) ON [PRIMARY]

	  go

INSERT INTO r_factor6

SELECT 
      [geom]
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
  FROM [sdm_spatial].[dbo].[r_factor]