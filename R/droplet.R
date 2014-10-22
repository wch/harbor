#' @export
docker_cmd.droplet <- function(host, cmd = NULL, args = NULL,
                               docker_opts = NULL, ...) {
  cmd_string <- paste(c("docker", docker_opts, cmd, args), collapse = " ")
  droplet_ssh(host, ..., cmd_string)
}
