#' Create a new ssh host
#'
#' This only works with certificate-based authentication. If you use a
#' passphrase on you certificates (recommended) then this expects
#' that to have been setup with `ssh-agent`.
#'
#' @md
#' @param hostname host name or IP address
#' @param ssh_user username to `ssh` as. It is **not** recommended to run as `root`.
#'   Defaults to current user as seen by R.
#' @param ssh_port defaults to the standard `22` but you should rotate the sshield
#'   frequency to dissuade opportunistic attacks.
#' @param docker_bin full path to the `docker` binary on the remote system
#' @export
ssh_host <- function(hostname, ssh_user=Sys.info()["user"], ssh_port=22L,
                     docker_bin="docker") {

  if (ssh_user == "root") warning("Running as [root] is not recommended")

  structure(list(
    name=hostname, user=ssh_user, port=ssh_port, docker=docker_bin),
    class = c("ssh_host", "host"))
}

#' @rdname ssh_host
#' @param x object
#' @param ... unused
#' @export
print.ssh_host <- function(x, ...) {
  cat(sprintf("<ssh host %s@%s>", x$user, x$name))
}


#' @rdname docker_cmd
#' @export
docker_cmd.ssh_host <- function(host, cmd = NULL, args = NULL,
                                docker_opts = NULL, capture_text = FALSE,
                                text_from = "stdout", ...) {

  ssh <-  Sys.which("ssh")

  ssh_user <-  sprintf("%s@%s", host$user, host$name)

  args <- c("-p", host$port, ssh_user, host$docker, cmd, docker_opts, args)

  # purrr::walk(args, message)
  # message("\n")

  res <- sys::exec_internal(ssh, args = args, error = TRUE)

  if (capture_text) {
    if (text_from == "stderr") {
      return(rawToChar(res$stderr))
    } else if (text_from == "both") {
      return(list(stdout=rawToChar(res$stdout), stderr=rawToChar(res$stderr)))
    } else {
      return(rawToChar(res$stdout))
    }
  } else {
    if (text_from == "stderr") {
      message(rawToChar(res$stderr))
    } else if (text_from == "both") {
      message(rawToChar(res$stdout))
      message(rawToChar(res$stderr))
    } else {
      message(rawToChar(res$stdout))
    }
  }

  invisible(host)

}
