#' @export
docker_cmd.droplet <- function(host, cmd = NULL, args = NULL,
                               docker_args = NULL, ...) {
  cmd_string <- paste(c("docker", docker_args, cmd, args), collapse = " ")
  droplet_ssh(host, ..., cmd_string)
}
