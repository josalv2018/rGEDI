#'Read GEDI Level1B data (Geolocated Waveforms)
#'
#'@description This function reads GEDI level1B products: geolocated Waveforms
#'
#'@usage readLevel1B(level1Bpath)
#'
#'@param level1Bpath File path pointing to GEDI level1B data. Data in HDF5 Hierarchical Data Format (.h5).
#'
#'@return Returns an S4 object of class [`gedi.level1b-class`] containing GEDI level1B data.
#'
#'@seealso [`hdf5r::H5File-class`] in the \emph{hdf5r} package and
#'\url{https://lpdaac.usgs.gov/products/gedi01_bv002/}
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
#'close(level1b)
#'@import hdf5r
#'@export
readLevel1B <-function(level1Bpath) {
  level1b_h5 <- hdf5r::H5File$new(level1Bpath, mode = 'r')
  level1b<- new("gedi.level1b", h5 = level1b_h5)
  return(level1b)
}
