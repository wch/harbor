# Create an object representing a container on a host
# info should be the output of docker_inspect()
container <- function(host, info) {
  if (is.null(info$Name) || is.null(info$Id))
    stop("`info` must be information about a single container.")

  structure(
    list(
      host = host,
      id = substr(info$Id, 1, 12),
      name = sub("^/", "", info$Name),
      image = info$Config$Image,
      cmd = info$Config$Cmd,
      info = info
    ),
    class = "container"
  )
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
