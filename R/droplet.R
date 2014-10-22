#' @export
docker_cmd.droplet <- function(host, cmd = NULL, args = NULL,
                               docker_opts = NULL, ...) {
  cmd_string <- paste(c("docker", docker_opts, cmd, args), collapse = " ")
  droplet_ssh(host, ..., cmd_string)
}


#' @export
docker_inspect.droplet <- function(host, names = NULL, ...) {
  if (is.null(names)) stop("Must have at least container name/id to inspect.")

  # Assume that the remote host uses /tmp as the temp dir
  temp_remote <- tempfile("docker_ps", tmpdir = "/tmp")
  temp_local <- tempfile("docker_ps")
  on.exit(unlink(temp_local))

  analogsea::droplet_ssh(
    host,
    sprintf(
      "docker inspect %s > %s",
      paste(names, collapse = " "),
      temp_remote
    ), ...
  )
  analogsea::droplet_download(host, temp_remote, temp_local, ...)

  text <- readLines(temp_local, warn = FALSE)
  jsonlite::fromJSON(text, simplifyDataFrame = FALSE, simplifyMatrix = FALSE)
}
