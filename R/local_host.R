#' Return an object representing the current that this is run on.
#' @export
localhost <- function() {
  structure(list(), class = c("host", "localhost"))
}

#' @export
docker_cmd.localhost <- function(host, cmd = NULL, args = NULL,
                                  docker_args = NULL, ...) {
  system2("docker", args = c(docker_args, cmd, args))
  host
}
