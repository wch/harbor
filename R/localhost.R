#' An object representing the current computer that R is running on.
#'
#' @export
localhost <- structure(list(), class = c("localhost", "host"))

#' @rdname localhost
#' @param x object
#' @param ... unused
#' @export
print.localhost <- function(x, ...) {
  cat("<localhost>")
}


#' @rdname docker_cmd
#' @param text_from where to capture text from
#' @export
docker_cmd.localhost <- function(host, cmd = NULL, args = NULL,
                                 docker_opts = NULL, capture_text = FALSE,
                                 text_from = "stdout", ...) {

  docker <- Sys.which("docker")

  args <- c(cmd, docker_opts, args)

  # purrr::walk(args, message)
  # message("\n")

  res <- sys::exec_internal(docker, args = args, error = TRUE)

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
