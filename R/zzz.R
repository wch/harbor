.onLoad <- function(libname, pkgname) {
  if (Sys.info()["sysname"] %in% c("Darwin", "Windows")) {
    machine <- getOption("harbor.autoconnect", FALSE)
    if (!identical(machine, FALSE)) {
      docker_machine_init(if (isTRUE(machine)) NULL else machine)
    }
  }
}
