#' Get list of all containers on a host.
#' @export
containers <- function(host = localhost, ...) {
  ids <- docker_cmd(host, "ps", "-qa", capture_text = TRUE, ...)

  cons <- lapply(ids, as.container, host)
  names(cons) <- pluck(cons, "name", character(1))
  cons
}
