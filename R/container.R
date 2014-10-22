# Create an object representing a container
# Info should be the output of docker_inspect()
container <- function(host, info) {
  structure(
    list(
      host = host,
      id = substr(info$Id, 1, 12),
      name = sub("^/", "", info$Name),
      image = info$Config$Image,
      info = info
    ),
    class = "container"
  )
}
