#' Return an object representing the current that this is run on.
#' @export
localhost <- function() {
  structure(list(), class = c("localhost", "host"))
}

#' @export
docker_cmd.localhost <- function(host, cmd = NULL, args = NULL,
                                  docker_opts = NULL, ...) {
  docker <- Sys.which("docker")
  system2("docker", args = c(docker_opts, cmd, args))
  invisible(host)
}
