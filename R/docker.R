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
