# If we're on Mac and Windows, we're using boot2docker, and we need to run the
# equivalent of `$(boot2docker shellinit)`.
boot2docker_shellinit <- function() {
  if (!(Sys.info()["sysname"] %in% c("Darwin", "Windows")))
    return()
  if (Sys.which("boot2docker") == "")
    return()

  if (boot2docker_ver() < "1.3.0")
    stop("Running boot2docker locally requires boot2docker >= 1.3.0")

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

boot2docker_ver <- function(){
  out <- system2("boot2docker", "version", stdout = TRUE)
  ver <- gsub("^.*?v([0-9\\.]+).*", "\\1", out[1])
  as.package_version(ver)
}
