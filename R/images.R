#' Get list of all images on a host
#'
#' @inheritParams docker_cmd
#' @export
images <- function(host = harbor::localhost, ...) {

  ids <- docker_cmd(host = host, "images", "-q", capture_text = TRUE, ...)
  ids <- trimws(ids)
  ids <- strsplit(ids, "[\r\n]")[[1]]
  ids <- Filter(Negate(is_blank), ids)
  ids <- unique(ids)

  ids <- lapply(ids, as.image, host)
  names(ids) <- pluck(ids, "Id", character(1))

  class(ids) <- c("dckr_imgs")

  ids

}

#' @rdname images
#' @param x images object
#' @param ... not used
#' @param stringsAsFactors set to `FALSE`
#' @export
as.data.frame.dckr_imgs <- function(x, ..., stringsAsFactors=FALSE) {

  if (length(x) == 0) return(data.frame(stringsAsFactors=stringsAsFactors))

  do.call(rbind.data.frame, lapply(x, function(y){
    data.frame(
      repo=ifelse(length(y$RepoTags) == 0, "", y$RepoTags[1]),
      arch=y$Architecture,
      os=y$Os,
      author=y$Author,
      id=y$Id,
      stringsAsFactors=stringsAsFactors)
  })) -> z

  row.names(z) <- NULL

  z

}
