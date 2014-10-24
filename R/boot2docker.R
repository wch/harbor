# If we're on Mac and Windows, we're using boot2docker, and we need to run the
# equivalent of `$(boot2docker shellinit)`.
boot2docker_shellinit <- function() {
  if (!(Sys.info()["sysname"] %in% c("Darwin", "Windows"))) {
    return()
  }

  # Run shellinit and capture the output, which are comands setting env vars
  # for sh. We need read them in and set them from R.
  envvars <- system2("boot2docker", "shellinit", stdout = TRUE)
  if (length(envvars) != 0) {
    envvars <- sub("^ +export +", "", envvars)
    envvars <- strsplit(envvars, "=")
    envvars <- setNames(pluck(envvars, 2), pluck(envvars, 1))
    do.call(Sys.setenv, envvars)
  }
}
