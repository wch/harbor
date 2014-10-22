#' Run a docker command on a host.
#'
#' @examples
#' \dontrun{
#' docker_cmd(localhost(), "ps", "-a")
#' }
#' @export
docker_cmd <- function(host, cmd = NULL, args = NULL, docker_opts = NULL, ...) {
  UseMethod("docker_cmd")
}


#' Pull a docker image onto a host.
#'
#' @examples
#' \dontrun{
#' docker_pull(localhost(), "debian:testing")
#' }
#' @return The \code{host} object.
#' @export
docker_pull <- function(host = localhost(), image, ...) {
  if (is.null(image)) stop("Must specify an image.")
  docker_cmd(host, "pull", image, ...)
}


#' Run a command in a new container on a host.
#'
#' @examples
#' \dontrun{
#' docker_run(localhost(), "debian:testing", "echo foo")
#' #> foo
#'
#' # Arguments will be concatenated
#' docker_run(localhost(), "debian:testing", c("echo foo", "bar"))
#' #> foo bar
#'
#' docker_run(localhost(), "rocker/r-base", c("Rscript", "-e", "1+1"))
#' #> [1] 2
#' }
#' @export
docker_run <- function(host = localhost(), image = NULL, cmd = NULL,
                       name = NULL, rm = FALSE,...) {

  if (is.null(image)) stop("Must specify an image.")

  docker_opts <- c(
    if (rm) "--rm",
    if (!is.null(name)) sprintf('--name="%s"', name)
  )

  docker_cmd(host, "run", args = c(image, cmd), docker_opts = docker_opts, ...)
}
