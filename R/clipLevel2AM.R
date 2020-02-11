#'Clip GEDI level2adt data
#'
#'@description Clip GEDI level2adt data within a given bounding coordinates
#'
#'
#'@param level2adt level2adt; S4 object of class "gedi.level1b.dt"
#'@param extent Extent object of a Spatial object .
#'@return Returns An object of class "gedi.level1b.dt"; subset of GEDI Level1B data
#'@examples
#'
#'#' GEDI level1B file path
#'level1_filepath = system.file("extdata", "lvis_level1_clip.h5", package="rLVIS")
#'
#'#' Reading LVIS level 2 file
#'level1_waveform = readLevel1b(level1Bfilepath)
#'
#'# Rectangle area for cliping
#'xmin = -116.4683
#'xmax = -116.3177
#'ymin = 46.75208
#'ymax = 46.84229
#'
#'# creating an exent object
#'ext<-extent(c(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax))
#'
#'clipped_level2adt = clipLevel1(level2adt, extent=ext)
#'
#'library(leaflet)
#'leaflet() %>%
#'  addCircleMarkers(clipped_level2adt@dt$longitude_bin0,
#'                   clipped_level2adt@dt$latitude_bin0,
#'                   radius = 1,
#'                   opacity = 1,
#'                   color = "red")  %>%
#'  addScaleBar(options = list(imperial = FALSE)) %>%
#'  addProviderTiles(providers$Esri.WorldImagery)
#'@export
clipLevel2AM = function(x,xleft, xright, ybottom, ytop){
  # xleft ybottom xright ytop
  mask =
    x$lon_lowestmode >= xleft &
    x$lon_lowestmode <= xright &
    x$lat_lowestmode >= ybottom &
    x$lat_lowestmode <=  ytop

  mask = (1:length(x$lon_lowestmode))[mask]
  newFile<-x[mask,]

  if (nrow(newFile) == 0) {print("The polygon does not overlap the GEDI data")} else {
    return (newFile)
  }
  #newFile<- new("gedi.level1b.dt", dt = level2adt[mask,])
}

#'Clip GEDI level2adt data by geometry
#'
#'@description Clip GEDI level2adt data within a given geometry area
#'
#'
#'@param level2adt level2adt; S4 object of class "gedi.level1b.dt"
#'@param polygon_spdf SpatialDataFrame. A polygon dataset for clipping the waveform
#'@return Returns An object of class "gedi.level1b.dt"; subset of GEDI Level1B data
#'@examples
#'
#'#' GEDI level1B file path
#'level1Bfilepath = system.file("extdata", "lvis_level1_clip.h5", package="rGEDI")
#'
#'#' Reading GEDI level1B file
#'level1b = readLevel1b(level1Bfilepath)
#'
#'#' Creating GEDI level2adt object
#'level2adt = level2adt(level1b)
#'
#'# Polgons file path
#'polygon_filepath <- system.file("extdata", "clip_polygon.shp", package="rGEDI")
#'
#'# Reading GEDI level2B file
#'polygon_spdf<-raster::shapefile(polygons_filepath)
#'
#'clipped_level2adt = clipLevel1Geometry(level2adt, polygon_spdf)
#'
#'library(leaflet)
#'leaflet() %>%
#'  addCircleMarkers(clipped_level2adt@dt$longitude_bin0,
#'                   clipped_level2adt@dt$latitude_bin0,
#'                   radius = 1,
#'                   opacity = 1,
#'                   color = "red")  %>%
#'  addScaleBar(options = list(imperial = FALSE)) %>%
#'  addPolygons(data=polygon_spdf,weight=1,col = 'white',
#'              opacity = 1, fillOpacity = 0) %>%
#'  addProviderTiles(providers$Esri.WorldImagery)
#'@export
clipLevel2AMGeometry = function(x, polygon_spdf, split_by="id") {
    exshp<-raster::extent(polygon_spdf)
    level2adt<-clipLevel2AM(x, xleft=exshp[1], xright=exshp[2], ybottom=exshp[3], ytop=exshp[4])
    if (nrow(level2adt) == 0) {print("The polygon does not overlap the GEDI data")} else {
      points = sp::SpatialPointsDataFrame(coords=matrix(c(level2adt$lon_lowestmode, level2adt$lat_lowestmode), ncol=2),
                                          data=data.frame(id=1:length(level2adt$lon_lowestmode)), proj4string = polygon_spdf@proj4string)
      pts = raster::intersect(points, polygon_spdf)
      if (!is.null(split_by)){

        if ( any(names(polygon_spdf)==split_by)){
          mask = as.integer(pts@data$id)
          newFile<-level2adt[mask,]
          newFile$poly_id<-pts@data[,split_by]
        } else {stop(paste("The",split_by,"is not included in the attribute table.
                       Please check the names in the attribute table"))}

      } else {
        mask = as.integer(pts@data$id)
        newFile<-level2adt[mask,]
      }
      #newFile<- new("gedi.level1b.dt", dt = level2adt2@dt[mask,])
      return (newFile)}
  }


