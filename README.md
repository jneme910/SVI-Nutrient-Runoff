# Soil Sensitivity for Nutrient-Runoff
Travis Rome, Jason Nemecek, Bob Dobos, Adolfo Diaz, Jerry Mohnhaupt, Richard Reid and Steve Campbell, Chad Ferguson, Stephen Roecker, Dylan Beaudette

Conservation Planning and Technical Assistance Division (CPTAD) has initiated a project with Resource Assessment Branch (RAB) and Soil and Plant Science Division (SPSD) to incorporate a LiDAR enhanced version of SVI into a pre-planning analysis mapping for planners to use in Conservation Desktop (CD) and Conservation Assessment Ranking Tool (CART).  The first theme for the pre-planning analysis they would like to develop mapping for is sensitive areas for nutrient runoff, using soils info and high resolution elevation data to identify those vulnerable areas within land units. The SVI categorizes inherent vulnerability to nutrient loss (via subsurface and subsurface pathways), and the goal now is to enhance that with topographic data. Travis Rome is leading this project, working with Lee Norfleet’s team. 

## Datasets
1. SSURGO (Soil)
2. Best available elevation (3 Meter, min)
3. Elevation derivatives
    + [Flow Direction](https://saga-gis.sourceforge.io/saga_tool_doc/2.1.3/ta_preprocessor_4.html) a.k.a. fill sinks
    + [Flow accumulation](https://saga-gis.sourceforge.io/saga_tool_doc/7.1.0/ta_hydrology_0.html) a.k.a Total Catchment Area
    + [Stream Power Index](https://saga-gis.sourceforge.io/saga_tool_doc/7.1.0/ta_hydrology_21.html)
    + [Slope Degrees](https://saga-gis.sourceforge.io/saga_tool_doc/7.1.0/ta_morphometry_0.html)
    + [LS -Slope Length](https://saga-gis.sourceforge.io/saga_tool_doc/7.1.0/ta_hydrology_22.html)

### SQL Conditions
1. [Raw Script - Managment Studio](https://github.com/jneme910/SVI-Nutrient-Runoff/blob/main/SQL/SDA_rkls.sql)
2. [Raw Script - Soil Data Access](https://github.com/jneme910/SVI-Nutrient-Runoff/blob/main/SQL/SDA_version_rkls.txt)
3. Metadata
4. Script Breakdown
5. Conditions
    + Dominant Component
    + Thickest Layer from 0 to 15 cm
    + Eliminates dry organic (duff layers such as leaf litter)
    + If Soil Component name equals "histosols" then assign 0.02 to Kfactor (Soil Erodibility)
    


    
