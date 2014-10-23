#' Coerce an object into a container object.
#'
#' A container object represents a Docker container on a host.
#' @export
as.container <- function(x, host = localhost) UseMethod("as.container")

#' @export
as.container.character <- function(x, host = localhost) {
  info <- docker_inspect(host, x)[[1]]
  as.container(info, host)
}

#' @export
as.container.list <- function(x, host = localhost) {
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
as.container.container <- function(x, host = localhost) {
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

#' Update the information about a container.
#'
#' This queries docker (on the host) for information about the container, and
#' saves the returned information into a container object, which is returned.
#' This does not use reference semantics, so if you want to store the updated
#' information, you need to save the result.
#'
#' @examples
#' \dontrun{
#' con <- container_update_info(con)
#' }
#' @export
container_update_info <- function(container) {
  container$info <- docker_inspect(container$host, container$name)[[1]]
  container
}

#' Report whether a container is currently running.
#'
#' @examples
#' \dontrun{
#' container_running(con)
#' }
#' @export
container_running <- function(container) {
  container <- container_update_info(container)
  container$info$State$Running
}


#' Delete a container.
#'
#' @param force Force removal of a running container.
#' @examples
#' \dontrun{
#' container_rm(con)
#' }
#' @export
container_rm <- function(container, force = FALSE) {
  args <- c(if (force) "-f", container$id)
  docker_cmd(container$host, "rm", args)
}


#' Retrieve logs for a container.
#'
#' @param follow Follow log output as it is happening.
#' @param timestamp Show timestamps.
#' @examples
#' \dontrun{
#' container_rm(con)
#' }
#' @export
container_logs <- function(container, timestamps = FALSE, follow = FALSE) {
  args <- c(if (timestamps) "-t", if (follow) "-f", container$id)
  docker_cmd(container$host, "logs", args)
}
