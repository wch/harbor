.onLoad <- function(libname, pkgname) {
  if (Sys.info()["sysname"] %in% c("Darwin", "Windows")) {
    boot2docker_shellinit()
  }
}
