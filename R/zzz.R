.onLoad <- function(libname, pkgname) {
  if (Sys.info()["sysname"] %in% c("Darwin", "Windows")) {
    if( ! boot2docker_ver_check() ) stop(sprintf("your boot2docker version must be %s or greater", btdver()), call. = FALSE)
    boot2docker_shellinit()
  }
}

boot2docker_ver <- function(){
  out <- system("boot2docker version", intern=TRUE)
  regmatches(out, regexpr("[0-9]+\\.[0-9]+\\.[0-9]+", out))
}

boot2docker_ver_check <- function(version = btdver()){
  out <- boot2docker_ver()
  as.package_version(out) > as.package_version(version)
}

btdver <- function() "1.3.0"
