#' Get list of all containers on a host.
#'
#' @inheritParams docker_cmd
#' @export
containers <- function(host = harbor::localhost, ...) {

  ids <- docker_cmd(host, cmd="ps", args="-qa", capture_text = TRUE, ...)
  ids <- trimws(ids)
  ids <- strsplit(ids, "[\r\n]")[[1]]
  ids <- Filter(Negate(is_blank), ids)

  cons <- lapply(ids, as.container, host=host)
  names(cons) <- pluck(cons, "name", character(1))

  class(cons) <- c("dckr_cntrs")

  if (length(cons) == 0) {
    message("No containers found")
    invisible(cons)
  } else {
    cons
  }

}

#' @md
#' @rdname containers
#' @param x containers object
#' @param ... not used
#' @param stringsAsFactors set to `FALSE`
#' @export
as.data.frame.dckr_cntrs <- function(x, ..., stringsAsFactors=FALSE) {

  if (length(x) == 0) return(data.frame(stringsAsFactors=stringsAsFactors))

  do.call(rbind.data.frame, lapply(x, function(y){
    data.frame(
      name=y$name,
      image=y$image,
      created=y$info$Created,
      status=y$info$State$Status,
      stringsAsFactors=stringsAsFactors)
  })) -> z

  row.names(z) <- NULL

  z

}
