#' Coerce an object into a container object.
#'
#' A container object represents a Docker container on a host.
#' @export
as.container <- function(x, host = localhost()) UseMethod("as.container")

#' @export
as.container.character <- function(x, host = localhost()) {
  info <- docker_inspect(host, x)[[1]]
  as.container(info, host)
}

#' @export
as.container.list <- function(x, host = localhost()) {
  # x should be the output of docker_inspect()
  if (is.null(x$Name) || is.null(x$Id))
    stop("`x` must be information about a single container.")

  structure(
    list(
      host = host,
      id = substr(x$Id, 1, 12),
      name = sub("^/", "", x$Name),
      image = x$Config$Image,
      cmd = x$Config$Cmd,
      info = x
    ),
    class = "container"
  )
}

#' @export
as.container.container <- function(x, host = localhost()) {
  x
}

#' @export
print.container <- function(x, ...) {
  cat("<container>")
  cat(
    "\n  ID:      ", x$id,
    "\n  Name:    ", x$name,
    "\n  Image:   ", x$image,
    "\n  Command: ", x$cmd,
    "\n  Host:  ",
    indent(
      paste(capture.output(print(x$host)), collapse = "\n"),
      indent = 2
    )
  )
}
