#' Integrate with Docker endpoints on Digital Ocean
#'
#' @md
#' @param host reachable hostname
#' @param cmd docker command
#' @param args args to docker command
#' @param docker_opts options passed to tocker
#' @param capture_text should we capture output text? default: `FALSE`
#' @param ... additional options passed to [analogsea::droplet_ssh] and
#'            [analogsea::droplet_download]s
#' @export
docker_cmd.droplet <- function(host, cmd = NULL, args = NULL,
                               docker_opts = NULL, capture_text = FALSE, ...) {
  cmd_string <- paste(c("docker", cmd, docker_opts, args), collapse = " ")

  if (capture_text) {
    # Assume that the remote host uses /tmp as the temp dir
    temp_remote <- tempfile("docker_cmd", tmpdir = "/tmp")
    temp_local <- tempfile("docker_cmd")
    on.exit(unlink(temp_local))

    analogsea::droplet_ssh(host, user = "analogsea",
                           paste(cmd_string, ">", temp_remote), ...)
    analogsea::droplet_download(host, user = "analogsea", temp_remote,
                                temp_local, ...)
    text <- readLines(temp_local, warn = FALSE)
    return(text)

  } else {
    return(analogsea::droplet_ssh(host, user = "analogsea", ..., cmd_string))
  }

}
