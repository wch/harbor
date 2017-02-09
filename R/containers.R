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

  if (length(cons) == 0) {
    message("No containers found")
    invisible(cons)
  } else {
    cons
  }

}


