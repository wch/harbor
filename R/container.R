#' Coerce an object into a container object.
#'
#' A container object represents a Docker container on a host.

#' @param x An object to coerce
#' @param host A docker host
#' @export
as.container <- function(x, host = harbor::localhost) UseMethod("as.container")

#' @rdname as.container
#' @export
as.container.character <- function(x, host = harbor::localhost) {
  info <- docker_inspect(host, x)[[1]]
  as.container(info, host)
}

#' @rdname as.container
#' @export
as.container.list <- function(x, host = harbor::localhost) {
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

#' @rdname as.container
#' @export
as.container.container <- function(x, host = harbor::localhost) {
  x
}

#' Custom print method
#'
#' @param x A container object
#' @param ... unused
#' @export
#' @importFrom utils capture.output
print.container <- function(x, ...) {
  cat("<container>")
  cat(
    "\n  Id:      ", x$id,
    "\n  Name:    ", x$name,
    "\n  Image:   ", x$image,
    "\n  Command: ", x$cmd,
    "\n  Host:  ",
    indent(
      paste(utils::capture.output(print(x$host)), collapse = "\n"),
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
#' @param container A container object
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
#' @inheritParams container_update_info
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
#' @inheritParams container_update_info
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
#' @inheritParams container_update_info
#' @param timestamps Show timestamps.
#' @examples
#' \dontrun{
#' container_logs(con)
#' }
#' @export
container_logs <- function(container, timestamps = FALSE) {
  args <- c(if (timestamps) "-t", container$id)
  docker_cmd(container$host, "logs", args, capture_text=TRUE, text_from="stderr")
}

#' Stop a running container
#'
#' @inheritParams container_update_info
#' @param seconds Seconds to wait for stop before killing container
#' @examples
#' \dontrun{
#' container_stop(con)
#' }
#' @export
container_stop <- function(container, seconds = 10) {
  docker_cmd(container$host,
             c("stop", container$id, sprintf("--time=%s",seconds)),
             capture_text=TRUE, text_from="both")
}
