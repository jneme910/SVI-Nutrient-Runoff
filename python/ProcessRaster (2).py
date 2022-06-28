# Land Unit Terrain Processing --------------------------------------------------------------------------
#
# The script is designed to work on a LIDAR-derived DEM of METER horizontal resolution.
# and is used to create elevation products to be used in evaluation of vulnerabilities related
# to nutrient loss on a land unit basis.  Additional data sources including soil products are
# used in combination with topgrahic factors to develop a vulnerability raster.
##--------------------------------------------------------------------------------
## Original coding: T. Rome 01/2022
##--------------------------------------------------------------------------------
#
##--------------------------------------------------------------------------------
# Import System Modules
##--------------------------------------------------------------------------------
import arcpy
from arcpy import env
from arcpy.sa import *
import sys, string, os, time
import arcgisscripting
gp = arcgisscripting.create()
arcpy.CheckOutExtension("Spatial")
gp.CheckOutExtension("Spatial")
gp.overwriteoutput = 1


os.chdir ('C://temp')

gp.workspace = r"C:\DATA\Rasters.gdb"
env.workspace = "C:\DATA\Rasters.gdb"
arcpy.env.scratchWorkspace = "C:\DATA\scratch"

CLUs = arcpy.GetParameterAsText(0)
arcpy.env.parallelProcessingFactor = '80%'


# -----------------------------------------------------------------------
# Elevation Prep
# -----------------------------------------------------------------------
ZFactor = 1

ClipElev = "C:\DATA\Rasters.gdb\ClipElev"
ElevAlbers = "C:\DATA\Rasters.gdb\ElevAlbers"
FillElevation = "C:\DATA\Rasters.gdb\FillElevation"
FlowDir = "C:\DATA\Rasters.gdb\FlowDir"
FlowAcc = "C:\DATA\Rasters.gdb\FlowAcc"
Hillshd = "C:\DATA\Rasters.gdb\Hillshd"
slopepct = "C:\DATA\Rasters.gdb\slope_percent"
slopedeg = "C:\DATA\Rasters.gdb\slope_degree"
slopeclass = "C:\DATA\Rasters.gdb\slopeclass"
slope_radians = "C:\DATA\Rasters.gdb\slope_radians"
FlowLenthFT = "C:\DATA\Rasters.gdb\FlowLengthFT"
SPI = "C:\DATA\Rasters.gdb\SPI"
StreamO = "C:\DATA\Rasters.gdb\StreamOrder"
StreamCon = "C:\DATA\Rasters.gdb\StreamCon"
#CLUs = "C:\DATA\Layers.gdb\CLU"
CLUbuffer = "C:\DATA\Rasters.gdb\CLUbuffer"
Elevation = "C:\DATA\KS105Elevation.gdb\Elevation_ks105_resample_Pro"
LS = "C:\DATA\Rasters.gdb\LS"
LS1 = "C:\DATA\Rasters.gdb\LS1"
DINFFlowDir = "C:\DATA\Rasters.gdb\DINFFlowDir"
DINFFlowAcc = "C:\DATA\Rasters.gdb\DINFFlowAcc"
sfactor = "C:\DATA\Rasters.gdb\sfactor"
lfactor = "C:\DATA\Rasters.gdb\lfactor"
rfactLayer = "C:\DATA\Layers.gdb\RFactor"
rFactorclip = "C:\DATA\Rasters.gdb\rFactorclip"



# -----------------------------------------------------------------------
#Create Buffers of AOI
# -----------------------------------------------------------------------

arcpy.Buffer_analysis(CLUs, CLUbuffer, "200 Feet", "FULL", "FLAT", "ALL")
# -----------------------------------------------------------------------
#Extract Elevation
# -----------------------------------------------------------------------





# Use the Buffered CLU's to clip/extract the DEM from the service
arcpy.AddMessage("\nDownloading Data...")
source_Service = "https://gis.sc.egov.usda.gov/image/rest/services/elevation/bare_earth_3m/ImageServer"
aoi_ext = arcpy.Describe(CLUbuffer).extent
xMin = aoi_ext.XMin
yMin = aoi_ext.YMin
xMax = aoi_ext.XMax
yMax = aoi_ext.YMax
clip_ext = str(xMin) + " " + str(yMin) + " " + str(xMax) + " " + str(yMax)
arcpy.Clip_management(source_Service, clip_ext, ClipElev, "", "", "", "NO_MAINTAIN_EXTENT")
arcpy.AddMessage("Done!\n")

# Reproject the Elevation to Albers
SR = arcpy.SpatialReference(32614)
arcpy.ProjectRaster_management(ClipElev, ElevAlbers, SR, "BILINEAR")


#Obtain R factor for AOI


rFactorclip = ExtractByMask(rfactLayer, CLUbuffer)

MeanRfact = arcpy.GetRasterProperties_management(rFactorclip, "MEAN")

arcpy.AddMessage(MeanRfact)




##outExtractByMask = ExtractByMask(Elevation, CLUbuffer)
##
##DEMmeters = (outExtractByMask * .3048)
##DEMmeters.save(DEM)


# ----------------------------------------------------------------------- 
# Fill the cut DEM
# -----------------------------------------------------------------------
arcpy.AddMessage("Filling DEM")
DEMFill = Fill(ElevAlbers)
DEMFill.save(FillElevation)


# -----------------------------------------------------------------------
## Calculate Flow Direction
# -----------------------------------------------------------------------

arcpy.AddMessage("Calculating D8 Flow Direction")
D8FlowDirection = FlowDirection(FillElevation, "", "")
D8FlowDirection.save(FlowDir)
#----------------------------------------------------------------------
# Calculate Flow Accumulation
# -----------------------------------------------------------------------
arcpy.AddMessage("Calculating Flow Accumulation")
D8Accumulation = FlowAccumulation(FlowDir, "", "INTEGER")
D8Accumulation.save(FlowAcc)



##FocalStat = "C:\DATA\Rasters.gdb\FocalStat"
##outFocalStat = FocalStatistics(FlowAcc, NbrAnnulus(1, 3, "CELL"), "Mean", "NODATA")
##outFocalStat.save(FocalStat)
# -----------------------------------------------------------------------
# Calculate Hillshade
# -----------------------------------------------------------------------
arcpy.AddMessage("Generating Hillshade")
HillshadeOut = Hillshade(FillElevation, "", "", "", ZFactor)
HillshadeOut.save(Hillshd)
# -----------------------------------------------------------------------
# Calculate Slope Percent
# -----------------------------------------------------------------------
slope_percent = Slope(FillElevation, "PERCENT_RISE")
slope_percent.save(slopepct)
gp.ReclassByASCIIFile_sa(slopepct, "C:\\Data\\reclassslope.txt", slopeclass)

slope_degree = Slope(FillElevation, "DEGREE")
slope_degree.save(slopedeg)


slope_radians = ATan(Times(Raster(slopepct),0.01))


# -----------------------------------------------------------------------
# FlowLength Calculation
# -----------------------------------------------------------------------
preflowLength = FlowLength(FlowDir,"UPSTREAM", "")
flowLength = FocalStatistics(preflowLength, NbrRectangle(3,3,"CELL"),"MAXIMUM","DATA")
FlowLengthFT = flowLength * 3.280839896


# -----------------------------------------------------------------------
# Calculate Stream Power Index
# -----------------------------------------------------------------------
arcpy.AddMessage("Creating Stream Power Index")
SPIout = (Ln((Raster(FlowAcc) + .001) * ((Raster(slopepct)/100)+.001)))
SPIout.save(SPI)



##LSout = Power(Raster(FlowAcc) * 3 / 22.1, 0.4) * Power(Sin(Raster(slopedeg) * 0.01745) / 0.0896, 1.4) * 1.4
##LSout.save(LS1)

##LSout = Power(Raster(FlowAcc5m) * 5 / 22.1, 0.4) * Power(Sin(Raster(slopedeg5m) * 0.01745) / 0.0896, 1.4) * 1.4
##LSout.save(LS)


##LSout = Power(Raster(FlowAcc5m) * 3 / 22.1, 0.4) * Power(Sin(Raster(slopedeg5m) * 0.01745) / 0.0896, 1.4) * 1.4
##LSout.save(LS)

##LSout = Power(Raster(FlowAcc5m) * 5 / 22.13, 0.4) * Power(Sin(Raster(slopedeg5m) * 0.01745 / 0.0896, 1.3)

                                                          
##

##Original LS factor





arcpy.SetProgressorLabel("Calculating S Factor")

# Compute S factor using formula in AH537, pg 12
sFactor = ((Power(Sin(slope_radians),2)*65.41)+(Sin(slope_radians)*4.56)+(0.065))


#10 ------------------------------------------------------------------------------ Calculate L Factor
arcpy.SetProgressorLabel("Calculating L Factor")

#lFactor = arcpy.CreateScratchName("lFactor",data_type="RasterDataset",workspace=scratchWS)

# Original outlFactor lines
"""outlFactor = Con(Raster(slope),Power(Raster(flowLengthFT) / 72.6,0.2),
                   Con(Raster(slope),Power(Raster(flowLengthFT) / 72.6,0.3),
                   Con(Raster(slope),Power(Raster(flowLengthFT) / 72.6,0.4),
                   Power(Raster(flowLengthFT) / 72.6,0.5),"VALUE >= 3 AND VALUE < 5"),"VALUE >= 1 AND VALUE < 3"),"VALUE<1")"""

# Remove 'Raster' function from above
##lFactor = Con(slopepct,Power(FlowLengthFT / 72.6,0.2),
##                Con(slopepct,Power(FlowLengthFT / 72.6,0.3),
##                Con(slopepct,Power(FlowLengthFT / 72.6,0.4),
##                Power(FlowLengthFT / 72.6,0.5),"VALUE >= 3 AND VALUE < 5"),"VALUE >= 1 AND VALUE < 3"),"VALUE<1")

lFactor = Con(slopepct,Power(flowLength / 22.1,0.2),
                Con(slopepct,Power(flowLength / 22.1,0.3),
                Con(slopepct,Power(flowLength / 22.1,0.4),
                Power(flowLength / 22.1,0.5),"VALUE >= 3 AND VALUE < 5"),"VALUE >= 1 AND VALUE < 3"),"VALUE<1")


arcpy.AddMessage("Calculating LS")
InFlow = Raster(FlowAcc)
InSlope = Raster(slopepct)
LSout = ((InFlow*3/22.1)^0.3)*(0.065+0.045*InSlope+0.0065*(InSlope*InSlope))
LSout.save(LS1)

lsFactor = lFactor * sFactor

lsFactor.save(LS)



### expand values 1 cell to increase connectivity
##SPIExp = Expand(SPI, 1, [1])
##
### thin back down to 1 cell thickness to enable conversion to polyline
##SPIThin = Thin(SPIExp, "", "", "ROUND")
# -----------------------------------------------------------------------
# Calculate Stream Order
# -----------------------------------------------------------------------
arcpy.AddMessage("Calculating Stream Order")
SPIextract = ExtractByAttributes("SPI", "VALUE > 1.75") 

outStreamOrder = StreamOrder(SPIextract, FlowDir, "STRAHLER")
outStreamOrder.save(StreamO)

# -----------------------------------------------------------------------
# Condition Stream Order to set NoData Areas to 0
# -----------------------------------------------------------------------
rast = Raster(StreamO) * 2
ConStreamOrder = Con(IsNull(rast),0,rast)
ConStreamOrder.save(StreamCon)

# -----------------------------------------------------------------------
# SOIL PREP
# -----------------------------------------------------------------------

Soils = "C:\DATA\Layers.gdb\soil_interp"
Soilclip = "C:\DATA\Rasters.gdb\soil_clip"
Soilras = "C:\DATA\Rasters.gdb\Soilras"
SoilK = "C:\DATA\Rasters.gdb\SoilK"
Soilalb = "C:\DATA\Rasters.gdb\Soialb"
# -----------------------------------------------------------------------
#Clip Soils
# -----------------------------------------------------------------------
arcpy.AddMessage("Clipping Soils")
arcpy.Clip_analysis(Soils, CLUbuffer, Soilclip)
arcpy.Project_management(Soilclip, Soilalb, SR)
env.snapRaster = FillElevation
arcpy.AddMessage("Rasterizing Soils")
arcpy.PolygonToRaster_conversion(Soilalb, "KFACT", Soilras, "MAXIMUM_AREA", "KFACT", 3)
gp.ReclassByASCIIFile_sa(Soilras, "C:\\Data\\reclasskfactor.txt", SoilK)

# -----------------------------------------------------------------------
#Clip SVI
# -----------------------------------------------------------------------
##SVI = "C:\DATA\Layers.gdb\SVI"
##SVIclip = "C:\DATA\Rasters.gdb\SVIclip"
##SVIras = "C:\DATA\Rasters.gdb\SVIras"
##SVIProj = "C:\DATA\Rasters.gdb\SVIProj"
##arcpy.AddMessage("Clipping SVI")
##arcpy.Clip_analysis(SVI, CLUbuffer, SVIclip)
##sr = arcpy.SpatialReference(26914)
##
##arcpy.management.Project(SVIclip, SVIProj, sr)
##
##env.snapRaster = FillElevation
##
##sr = arcpy.SpatialReference(26914)
##arcpy.AddMessage("Rasterizing SVI")
##
##arcpy.PolygonToRaster_conversion(SVIProj, "Runoff_Dcd", SVIras, "MAXIMUM_AREA", "Runoff_Dcd", 3)
##
# -----------------------------------------------------------------------
#Vulnerability Calculations
# -----------------------------------------------------------------------
arcpy.AddMessage("Calculating Vulnerability")
RKLS = "C:\DATA\Rasters.gdb\RKLS"
Vraster = "C:\DATA\Rasters.gdb\Vrast"
VulnerabilityRKLS_Index = "C:\DATA\Rasters.gdb\VulnerabilityRKLS_Index"
VulnerabilityRKLS_Class = "C:\DATA\Rasters.gdb\VulnerabilityRKLS_Class"
VulnerabilitySVI_Index = "C:\DATA\Rasters.gdb\VulnerabilitySVI_Index"
VulnerabilitySVI_Class = "C:\DATA\Rasters.gdb\VulnerabilitySVI_Class"
Vulnerabilityslope_Index = "C:\DATA\Rasters.gdb\VulnerabilitySlope_Index"
Vulnerabilityslope_Class = "C:\DATA\Rasters.gdb\VulnerabilitySlope_Class"
RKLS_Class = "C:\DATA\Rasters.gdb\RKLS_Class"

Rfactor = 168

RKLSout = Rfactor * Raster(Soilras) * Raster(LS)
RKLSout.save(RKLS)

#gp.ReclassByASCIIFile_sa(RKLS, "C:\\Data\\reclassRKLS.txt", RKLS_Class)
RKLSclassvalues = "0 12.5 1;12.5 21 2;21 33.5 3;33.5 10000 4"
arcpy.Reclassify_3d(RKLS, "VALUE", RKLSclassvalues, RKLS_Class,'NODATA')

RKLScalc = Raster(RKLS_Class)
Streamcalc = Raster(StreamCon)
VulnerabilityTemp = RKLScalc + Streamcalc

VulnerabilityRKLS_Indexout = ExtractByMask(VulnerabilityTemp, CLUs)
VulnerabilityRKLS_Indexout.save(VulnerabilityRKLS_Index)

#gp.ReclassByASCIIFile_sa(VulnerabilityRKLS_Index, "C:\\Data\\reclassvulnerability.txt", VulnerabilityRKLS_Class)
Vulnerabilityclassvalues = "0 1 1;1 3 2;3 5 3;5 7 4;7 2000 5"
arcpy.Reclassify_3d(VulnerabilityRKLS_Index, "VALUE", Vulnerabilityclassvalues, VulnerabilityRKLS_Class,'NODATA')

##SVIcalc = Raster(SVIras)
##
##VulnerabilitySVI_Temp = SVIcalc + Streamcalc
##VulnerabilitySVI_Indexout = ExtractByMask(VulnerabilitySVI_Temp, CLUs)
##VulnerabilitySVI_Indexout.save(VulnerabilitySVI_Index)
##gp.ReclassByASCIIFile_sa(VulnerabilitySVI_Index, "C:\\Data\\reclassvulnerability.txt", VulnerabilitySVI_Class)



Soilkcalc = Raster(SoilK)
slopecalc = Raster(slopeclass)
#Vulnerabilityslope_Temp = "C:\DATA\Rasters.gdb\Vulnerabilityslope_Temp"
Vulnerabilityslope_Temp = Soilkcalc * slopecalc
#Vulnerabilityslope_Temp.save(Vulnerabilityslope_Temp)
#gp.ReclassByASCIIFile_sa(Vulnerabilityslope_Temp, "C:\\Data\\reclassvulnerability.txt", Vulnerabilityslope_Class)
VulnerabilityslopeStream = Vulnerabilityslope_Temp + Streamcalc
Vulnerabilityslope_Indexout = ExtractByMask(VulnerabilityslopeStream, CLUs)
Vulnerabilityslope_Indexout.save(Vulnerabilityslope_Index)
gp.ReclassByASCIIFile_sa(Vulnerabilityslope_Index, "C:\\Data\\reclassvulnerability.txt", Vulnerabilityslope_Class)




##------------------------------------------------------------------------------
##------------------------------------------------------------------------------


    # Define parameters	
##    DEM = Elevation
##    OutputFillDEM = FillDem
##    OutputFlowDir = arcpy.GetParameterAsText(2)
##    OutputFlowAcc = arcpy.GetParameterAsText(3)
##    OutputHshd = arcpy.GetParameterAsText(4)
##    ZFactor = arcpy.GetParameterAsText(5)
##
##    # Set environments
##    arcpy.env.extent = DEM
##    arcpy.env.snapRaster = DEM
##    rObj = Raster(DEM)
##    arcpy.env.cellSize = rObj.meanCellHeight
##    arcpy.env.overwriteOutput = True
##    arcpy.env.scratchWorkspace = env.scratchFolder
##    arcpy.env.outputCoordinateSystem = DEM
##    arcpy.env.parallelProcessingFactor = '80%'
##
##    if not arcpy.Exists(env.workspace):
##        arcpy.AddError("workspace does not exist!! Please set your workspace to a valid path directory in Arcmap --> Geoprocessing --> Environments --> Workspace")
##        sys.exit(0)
##
##    # Run Modules
##    TerrainProcessing(DEM, ZFactor)
