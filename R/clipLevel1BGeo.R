#'Clip GEDI Full Waveform Geolocations by Coordinates
#'
#'@description This function clips GEDI level1B extracted geolocation ([getLevel1BGeo()])
#' data a within given bounding coordinates
#'
#'@usage clipLevel1BGeo(level1BGeo, xmin, xmax, ymin, ymax)
#'
#'@param level1BGeo A [`data.table::data.table-class`] resulting from [getLevel1BGeo()].
#'@param xmin Numeric. West longitude (x) coordinate of the bounding rectangle, in decimal degrees.
#'@param xmax Numeric. East longitude (x) coordinate of the bounding rectangle, in decimal degrees.
#'@param ymin Numeric. South latitude (y) coordinate of the bounding rectangle, in decimal degrees.
#'@param ymax Numeric. North latitude (y) coordinate of the bounding rectangle, in decimal degrees.
#'
#'@return Returns an S4 object of class [`data.table::data.table-class`].
#'
#'@seealso \url{https://lpdaac.usgs.gov/products/gedi01_bv002/}
#'
#'@examples
#'# Specifying the path to GEDI level1B data (zip file)
#'outdir = tempdir()
#'level1B_fp_zip <- system.file("extdata",
#'                   "GEDI01_B_2019108080338_O01964_T05337_02_003_01_sub.zip",
#'                   package="rGEDI")
#'
#'# Unzipping GEDI level1B data
#'level1Bpath <- unzip(level1B_fp_zip,exdir = outdir)
#'
#'# Reading GEDI level1B data (h5 file)
#'level1b<-readLevel1B(level1Bpath=level1Bpath)
#'
#'# Extracting GEDI Full Waveform Geolocations
#'level1bGeo<-getLevel1BGeo(level1b)
#'
#'# Bounding rectangle coordinates
#'xmin = -44.15036
#'xmax = -44.10066
#'ymin = -13.75831
#'ymax = -13.71244
#'
#'# Clipping GEDI Full Waveform Geolocations by boundary box extent
#'level1bGeo_clip <- clipLevel1BGeo(level1bGeo,xmin, xmax, ymin, ymax)
#'
#'hasLeaflet = require(leaflet)
#'
#'if (hasLeaflet){
#' leaflet() %>%
#'  addCircleMarkers(level1bGeo_clip$longitude_bin0,
#'                   level1bGeo_clip$latitude_bin0,
#'                   radius = 1,
#'                   opacity = 1,
#'                   color = "red")  %>%
#'  addScaleBar(options = list(imperial = FALSE)) %>%
#'  addProviderTiles(providers$Esri.WorldImagery)
#' }
#'
#' close(level1b)
#'@export
clipLevel1BGeo = function(level1BGeo,xmin, xmax, ymin, ymax){
  # xmin ymin xmax ymax
  mask =
    level1BGeo$longitude_bin0 >= xmin &
    level1BGeo$longitude_bin0 <= xmax &
    level1BGeo$latitude_bin0 >= ymin &
    level1BGeo$latitude_bin0 <=  ymax &
    level1BGeo$longitude_lastbin >= xmin &
    level1BGeo$longitude_lastbin <= xmax &
    level1BGeo$latitude_lastbin >= ymin &
    level1BGeo$latitude_lastbin <=  ymax
  mask[!stats::complete.cases(mask)] = FALSE
  mask = (1:length(level1BGeo$longitude_bin0))[mask]
  newFile<-level1BGeo[mask,]
  #newFile<- new("gedi.level1b.dt", dt = x[mask,])
  if (nrow(newFile) == 0) {print("The polygon does not overlap the GEDI data")} else {
    return (newFile)
  }

}

#'Clip GEDI Full Waveform Geolocations by geometry
#'
#'@description This function clips level1BGeo extracted geolocation (level1BGeo)
#' data within a given geometry
#'
#'@param level1BGeo A [`data.table::data.table-class`] resulting from [getLevel1BGeo()] function.
#'@param polygon_spdf Polygon. An object of class [`sp::SpatialPolygonsDataFrame-class`],
#'which can be loaded as an ESRI shapefile using [raster::shapefile] function in the \emph{raster} package.
#'@param split_by Polygon id. If defined, GEDI data will be clipped by each polygon using the polygon id from table of attribute defined by the user.
#'
#'@return Returns an S4 object of class [`data.table::data.table-class`] containing the
#'clipped GEDI level1B extracted geolocations.
#'
#'@seealso \url{https://lpdaac.usgs.gov/products/gedi01_bv002/}
#'
#'@examples
#'# Specifying the path to GEDI level1B data (zip file)
#'outdir = tempdir()
#'level1B_fp_zip <- system.file("extdata",
#'                   "GEDI01_B_2019108080338_O01964_T05337_02_003_01_sub.zip",
#'                   package="rGEDI")
#'
#'# Unzipping GEDI level1B data
#'level1Bpath <- unzip(level1B_fp_zip,exdir = outdir)
#'
#'# Reading GEDI level1B data (h5 file)
#'level1b<-readLevel1B(level1Bpath=level1Bpath)
#'
#'# Extracting GEDI Full Waveform Geolocations
#'level1bGeo<-getLevel1BGeo(level1b)
#'
#'# Specifying the path to shapefile
#'polygon_filepath <- system.file("extdata", "stands_cerrado.shp", package="rGEDI")
#'
#'# Reading shapefile as SpatialPolygonsDataFrame object
#'library(raster)
#'polygon_spdf<-shapefile(polygon_filepath)
#'
#'# Clipping GEDI Full Waveform Geolocations by Geometry
#'level1bGeo_clip = clipLevel1BGeoGeometry(level1bGeo, polygon_spdf, split_by="id")
#'
#'hasLeaflet = require(leaflet)
#'
#'if (hasLeaflet) {
#'leaflet() %>%
#'  addCircleMarkers(level1bGeo_clip$longitude_bin0,
#'                   level1bGeo_clip$latitude_bin0,
#'                   radius = 1,
#'                   opacity = 1,
#'                   color = "red")  %>%
#'  addScaleBar(options = list(imperial = FALSE)) %>%
#'  addPolygons(data=polygon_spdf,weight=1,col = 'white',
#'              opacity = 1, fillOpacity = 0) %>%
#'  addProviderTiles(providers$Esri.WorldImagery)
#' }
#'
#' close(level1b)
#'@export
clipLevel1BGeoGeometry = function(level1BGeo, polygon_spdf, split_by="id") {
  exshp<-raster::extent(polygon_spdf)
  level1BGeo<-clipLevel1BGeo(level1BGeo,xmin=exshp[1], xmax=exshp[2], ymin=exshp[3], ymax=exshp[4])

  if (nrow(level1BGeo) == 0) {print("The polygon does not overlap the GEDI data")} else {
    points = sp::SpatialPointsDataFrame(coords=matrix(c(level1BGeo$longitude_bin0, level1BGeo$latitude_lastbin), ncol=2),
                                        data=data.frame(id=1:length(level1BGeo$latitude_bin0)), proj4string = polygon_spdf@proj4string)

    pts = raster::intersect(points, polygon_spdf)
    colnames(pts@data)<-c("rowids",names(polygon_spdf))

    if (!is.null(split_by)){

      if ( any(names(polygon_spdf)==split_by)){
        mask = as.integer(pts@data$rowids)
        newFile<-level1BGeo[mask,]
        newFile$poly_id<-pts@data[,split_by]
      } else {stop(paste("The",split_by,"is not included in the attribute table.
                       Please check the names in the attribute table"))}

    } else {
      mask = as.integer(pts@data$rowids)
      newFile<-level1BGeo[mask,]
    }
    #newFile<- new("gedi.level1b.dt", dt = x2@dt[mask,])
    return (newFile)}
}
