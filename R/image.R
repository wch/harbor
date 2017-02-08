#' Coerce an object into an image object.
#' @export
as.image <- function(x, host = harbor::localhost) UseMethod("as.image")

#' @rdname as.image
#' @export
as.image.character <- function(x, host = harbor::localhost) {
  info <- docker_inspect(host, x)[[1]]
  as.image(info, host)
}

#' @rdname as.image
#' @export
as.image.list <- function(x, host = harbor::localhost) {
  # x should be the output of docker_inspect()
  if (is.null(x$Id))
    stop("`x` must be information about a single image.")

  x$host <- host
  class(x) <- c("image", "list")
  x
}

#' @rdname as.image
#' @export
as.image.image <- function(x, host = harbor::localhost) {
  x
}

#' Custom print method
#'
#' @param x An image object
#' @param ... unused
#' @export
print.image <- function(x, ...) {
  cat("<image>")
  cat(
    "\n  Id:           ", substr(x$Id, 8, 8+11),
    "\n  Repo:         ", sub(":.*$", "", x$RepoTags),
    "\n  Tag:          ", sub("^.*:", "", x$RepoTags),
    "\n  Architecture: ", x$Architecture,
    "\n  OS:           ", x$Os,
    "\n  Size:         ", sprintf("%s MB", scales::comma(ceiling(x$Size/1000/1000)))
  )
}

#' Delete an image
#'
#' @param x An image object
#' @param force Force removal of a running container.
#' @examples
#' \dontrun{
#' image_rm(img)
#' }
#' @export
image_rm <- function(x, force = FALSE) {
  args <- c(if (force) "-f", substr(x$Id, 8, 8+11))
  docker_cmd(x$host, "rmi", args)
}
