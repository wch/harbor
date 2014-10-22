#' Return an object representing the current computer that R is running on.
#' @export
localhost <- function() {
  structure(list(), class = c("localhost", "host"))
}

#' @export
docker_cmd.localhost <- function(host, cmd = NULL, args = NULL,
                                 docker_opts = NULL, capture_text = FALSE, ...) {
  docker <- Sys.which("docker")

  textopt <- capture_text
  # If FALSE, send output to console
  if (textopt == FALSE) textopt <- ""

  res <- system2(docker, args = c(docker_opts, cmd, args), stdout = textopt,
                 stderr = textopt)

  if (capture_text) return(res)

  invisible(host)
}

#' @export
docker_inspect.localhost <- function(host, names = NULL, ...) {
  if (is.null(names)) stop("Must have at least container name/id to inspect.")

  text <- docker_cmd(host, "inspect", args = names, capture_text = TRUE, ...)

  jsonlite::fromJSON(text, simplifyDataFrame = FALSE, simplifyMatrix = FALSE)
}
