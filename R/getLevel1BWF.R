#'Get GEDI Pulse Full Waveform (GEDI Level1B)
#'
#'@description This function extracts the full waveform of a given pulse from GEDI Level1B data.
#'
#'@usage getLevel1BWF(level1b, shot_number)
#'
#'@param level1b A GEDI Level1B object (output of [readLevel1B()] function). A S4 object of class "gedi.level1b".
#'@param shot_number Shot number. A scalar representing the shot number of a giving pulse.
#'
#'@return Returns an S4 object of class "gedi.fullwaveform".
#'
#'@details Shot numbers can be extracted using [readLevel1B] function.
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
#'# Extracting GEDI full waveform for a giving shotnumber
#'wf <- getLevel1BWF(level1b, shot_number="19640521100108408")
#'
#'# Plotting GEDI Full waveform
#'oldpar<-par()
#'par(mfrow = c(1,2), cex.axis = 1.5)
#'plot(wf, relative=FALSE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
#'xlab="Waveform Amplitude", ylab="Elevation (m)")
#'
#'plot(wf, relative=TRUE, polygon=TRUE, type="l", lwd=2, col="forestgreen",
#'xlab="Waveform Amplitude (%)", ylab="Elevation (m)")
#'
#'par(oldpar)
#'close(level1b)
#'@export
#'
getLevel1BWF<-function(level1b,shot_number){

  level1b<-level1b@h5
  groups_id<-grep("BEAM\\d{4}$",gsub("/","",
                                     hdf5r::list.groups(level1b, recursive = F)), value = T)

  i=NULL
  for ( k in groups_id){
    gid<-max(level1b[[paste0(k,"/shot_number")]][]==shot_number)
    if (gid==1) {i=k}
  }

  if(is.null(i)) {
    stop(paste0("Shot number ", shot_number, " was not found within the dataset!. Please try another shot number"))
  } else{

  shot_number_i<-level1b[[paste0(i,"/shot_number")]][]
  shot_number_id<-which(shot_number_i[]==shot_number)
  elevation_bin0<-level1b[[paste0(i,"/geolocation/elevation_bin0")]][]
  elevation_lastbin<-level1b[[paste0(i,"/geolocation/elevation_lastbin")]][]
  rx_sample_count<-level1b[[paste0(i,"/rx_sample_count")]][]
  rx_sample_start_index<-level1b[[paste0(i,"/rx_sample_start_index")]][]
  rx_sample_start_index_n<-rx_sample_start_index-min(rx_sample_start_index)+1
  rxwaveform_i<-level1b[[paste0(i,"/rxwaveform")]][rx_sample_start_index_n[shot_number_id]:(rx_sample_start_index_n[shot_number_id]+rx_sample_count[shot_number_id]-1)]
  rxwaveform_inorm<-(rxwaveform_i-min(rxwaveform_i))/(max(rxwaveform_i)-min(rxwaveform_i))*100
  elevation_bin0_i<-elevation_bin0[shot_number_id]
  elevation_lastbin_i<-elevation_lastbin[shot_number_id]
  z=rev(seq(elevation_lastbin_i,elevation_bin0_i,(elevation_bin0_i-elevation_lastbin_i)/rx_sample_count[shot_number_id]))[-1]

  waveform<-new("gedi.fullwaveform", dt = data.table::data.table(rxwaveform=rxwaveform_i,elevation=z))

  return(waveform)
 }
}
