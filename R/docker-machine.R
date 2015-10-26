##' Initialise environment variables to connect to a docker machine.
##'
##' In the case where there is only a single docker machine and no
##' machine is specified there is no difficult logic.
##'
##' \enumerate{
##' \item{If \code{machine} is not specified (or is \code{NULL}) then
##' \enumerate{
##' \item{If \code{DOCKER_MACHINE_NAME} is set (i.e., \emph{something}
##' has already set \code{docker-machine} variables) do nothing and
##' use these.}
##'
##' \item{Otherwise pick the first name listed among running machines
##' (see \code{docker ls --filter state=Running}) with a message if
##' more than one was found}
##' }}
##'
##' \item{If \code{machine} is specified and non-\code{NULL} then use
##' this machine only, throwing an error if it is not running}
##' }
##'
##' @title Connect to a docker machine
##' @param machine Name of a machine
##' @export
docker_machine_init <- function(machine=NULL) {
  machine <- docker_machine_init_which(machine)
  if (!is.null(machine)) {
    message(sprintf("Setting up docker-machine '%s'", machine))
    docker_machine <- callr_Sys_which("docker-machine")
    status <- callr_call_system(docker_machine, c("status", machine))
    if (!identical(status, "Running")) {
      stop(sprintf("docker-machine '%s' not running? Status: '%s'",
                   machine, status))
    }

    res <- callr_call_system(docker_machine, paste("env ", machine),
                              stderr=FALSE)

    ## Filter to lines containing `export`
    re <- "^\\s*export\\s+"
    res <- res[grep(re, res)]
    vars <- strsplit(sub("^\\s*export\\s+", "", res), "=", fixed=TRUE)
    if (!all(vapply(vars, length, integer(1)) == 2)) {
      stop("Unexpected output from docker-machine")
    }

    strip_quotes <- function(x) {
      gsub('(^"|"$)', "", x)
    }
    vcapply <- function(...) vapply(..., FUN.VALUE=character(1))
    var_name <- vcapply(vars, function(x) x[[1]])
    var_val  <- as.list(strip_quotes(vcapply(vars, function(x) x[[2]])))

    names(var_val) <- var_name
    do.call("Sys.setenv", var_val)

    if (Sys.getenv("DOCKER_MACHINE_NAME") == "") {
      stop("Failed to set docker_machine variables")
    }
    tryCatch(callr_call_system(callr_Sys_which("docker"), "ps"),
             error=function(e)
               stop("While trying to test docker:\n", e$message))
  }
}

docker_machine_init_which <- function(machine) {
  if (Sys.getenv("DOCKER_MACHINE_NAME") == "") {
    docker_machine <- callr_Sys_which("docker-machine")
    args <- c("ls", "-q", "--filter", "state=Running")
    machines <- callr_call_system(docker_machine, args)
    if (is.null(machine)) {
      if (length(machines) < 1L) {
        stop("No running docker machines detected")
      } else if (length(machines) > 1L) {
        message("More than one machine present, taking the first")
      }
      machines[[1]]
    } else {
      if (!(machine %in% machines)) {
        stop(sprintf("machine '%s' requested but not in running set: %s",
                     machine, paste(machines, collapse=", ")))
      }
      machine
    }
  } else if (!is.null(machine) && Sys.getenv("DOCKER_MACHINE_NAME") != machine) {
    machine
  } else {
    NULL
  }
}

## Ported from callr for now (sorry) - I can refactor this later or
## depend on callr later.
callr_Sys_which <- function(name) {
  ret <- Sys.which(name)
  if (ret == "") {
    stop(sprintf("%s not found in $PATH", name))
  }
  ret
}

callr_call_system <- function(command, args, env=character(), max_lines=20,
                              p=0.8, stdout=TRUE, stderr=TRUE) {
  res <- suppressWarnings(system2(command, args,
                                  env=env, stdin="",
                                  stdout=stdout, stderr=stderr))
  ok <- attr(res, "status")
  if (!is.null(ok) && ok != 0) {
    max_nc <- getOption("warning.length")

    cmd <- paste(c(env, shQuote(command), args), collapse = " ")
    msg <- sprintf("Running command:\n  %s\nhad status %d", cmd, ok)
    errmsg <- attr(cmd, "errmsg")
    if (!is.null(errmsg)) {
      msg <- c(msg, sprintf("%s\nerrmsg: %s", errmsg))
    }
    sep <- paste(rep("-", getOption("width")), collapse="")

    ## Truncate message:
    if (length(res) > max_lines) {
      n <- ceiling(max_lines * p)
      res <- c(head(res, ceiling(max_lines - n)),
               sprintf("[[... %d lines dropped ...]]", length(res) - max_lines),
               tail(res, ceiling(n)))
    }

    ## compute the number of characters so far, including three new lines:
    nc <- (nchar(msg) + nchar(sep) * 2) + 3
    i <- max(1, which(cumsum(rev(nchar(res) + 1L)) < (max_nc - nc)))
    res <- res[(length(res) - i + 1L):length(res)]
    msg <- c(msg, "Program output:", sep, res, sep)
    stop(paste(msg, collapse="\n"))
  }
  invisible(res)
}
