#' Calculate the location of a stem based on azimuth and distance.
#'
#' @param decimalLongitude numeric vector of decimal longitudes
#' @param decimalLatitude numeric vector of decimal latitudes
#' @param stemAzimuth numeric vector of stem azimuths
#' @param stemDistance numeric vector of stem distances
#'
#' @return A tibble of pairs of co-ordinates (longitudes/latitudes)

get_stem_location <- function(
    decimalLongitude, decimalLatitude,
    stemAzimuth, stemDistance){

  # input validation checks
  checkmate::assert_numeric(decimalLongitude)
  checkmate::assert_numeric(decimalLatitude)
  checkmate::assert_numeric(stemAzimuth)
  checkmate::assert_numeric(stemDistance)
  
  out <- geosphere::destPoint(
    p = cbind(decimalLongitude, decimalLatitude),
    b = stemAzimuth,
    d = stemDistance
  ) |> 
    tibble::as_tibble()
  
  # output validation checks
  checkmate::assert_false(any(is.na(out)))
  
  return(out)
}

test <- get_stem_location(
  x$decimalLongitude, 
  x$decimalLatitude, 
  x$stemAzimuth, 
  x$stemDistance
  )
