#' Get list of all images on a host
#'
#' @inheritParams docker_cmd
#' @export
images <- function(host = harbor::localhost, ...) {

  ids <- docker_cmd(host = host, "images", "-q", capture_text = TRUE, ...)
  ids <- trimws(ids)
  ids <- strsplit(ids, "[\r\n]")[[1]]
  ids <- Filter(Negate(is_blank), ids)

  ids <- lapply(ids, as.image, host)
  names(ids) <- pluck(ids, "Id", character(1))
  ids

}
