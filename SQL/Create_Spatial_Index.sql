CREATE SPATIAL INDEX [ si_r_factor_geom_idx5] ON [sdm_spatial].[dbo].[r_factor]
(
	[geom]
)USING  GEOMETRY_GRID 
WITH (BOUNDING_BOX =(-180, -90, 180, 90), GRIDS =(LEVEL_1 = HIGH,LEVEL_2 = HIGH,LEVEL_3 = HIGH,LEVEL_4 = HIGH), 
CELLS_PER_OBJECT = 64, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

 ; 