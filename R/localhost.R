#' An object representing the current computer that R is running on.
#' @export
localhost <- structure(list(), class = c("localhost", "host"))

#' @export
print.localhost <- function(x, ...) {
  cat("<localhost>")
}


#' @export
docker_cmd.localhost <- function(host, cmd = NULL, args = NULL,
                                 docker_opts = NULL, capture_text = FALSE, ...) {
  docker <- Sys.which("docker")

  textopt <- capture_text
  # If FALSE, send output to console
  if (textopt == FALSE) textopt <- ""

  res <- system2(docker, args = c(cmd, docker_opts, args), stdout = textopt,
                 stderr = textopt)

  if (capture_text) return(res)

  invisible(host)
}
