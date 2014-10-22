#' Run a docker command on a host.
#'
#' @examples
#' docker_cmd(localhost(), "ps", "-a")
#' @export
docker_cmd <- function(host, cmd = NULL, args = NULL, docker_args = NULL, ...) {
  UseMethod("docker_cmd")
}
