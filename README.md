harbor
======

This is an R package for controlling docker containers on local and remote hosts.


It presently works with:

* The local computer that R is running on (`localhost`)
* Remote virtual machines running on Digital Ocean, with the [analogsea](https://github.com/sckott/analogsea) package.
* Remote virtual machines running on Google Compute Engine, with the [googleComputeEngineR](https://github.com/cloudyr/googleComputeEngineR) package.

## Installation

```R
devtools::install_github("wch/harbor")

# Optional
devtools::install_github("sckott/analogsea")

# Optional
devtools::install_github("cloudyr/googleComputeEngineR")
```


## Usage

If you have docker or boot2docker installed on your local computer, you can control it with the `localhost` object.

```R
library(harbor)

# Run a command and exit
docker_run(localhost, "ubuntu", "echo foo")
#> foo

# Running it returns a container object, which we can print
con <- docker_run(localhost, "ubuntu", "echo foo")
con
#> <container>
#>   ID:       c981531604a7 
#>   Name:     harbor_5jbdf6 
#>   Image:    ubuntu 
#>   Command:  echo foo 
#>   Host:     <localhost>

# Automatically remove the container when finished
docker_run(localhost, "ubuntu", "echo foo", rm = TRUE)

# Run a command with Rscript, using the rocker/r-base image.
# Arguments can be in a char vector.
docker_run(localhost, "rocker/r-base", c("Rscript", "-e", '"sum(1:10)"'), rm = TRUE)
#> [1] 55
```

The same commands can be used with docker images on a remote host, using the analogsea package. The only difference in the interface is that, instead of `localhost`, you must pass in the object representing the remote host.

Note: you may need to configure ssh host keys on Digital Ocean for the following to work.

## DigitalOcean

```R
library(analogsea)

# Create a virtual machine on Digital Ocean
dhost <- droplet_create("dhost", image = "docker")

# Create and run a container in the virtual machine.
# This might take a while.
con <- docker_run(dhost, "debian", "echo foo")
#> Unable to find image 'debian' locally
#> debian:latest: The image you are pulling has been verified
#> Status: Downloaded newer image for debian:latest
#> foo

con
#> <container>
#>   ID:       5aa987cef673 
#>   Name:     harbor_8pfvgi 
#>   Image:    busybox 
#>   Command:  echo foo 
#>   Host:     <droplet>dhost (2941098)
#>     IP:     107.170.247.231
#>     Status: active
#>     Region: San Francisco 1
#>     Image:  Docker 1.3.0 on Ubuntu 14.04
#>     Size:   512mb ($0.00744 / hr)

# Destroy the virtual machine from Digital Ocean
droplet_delete(dhost)
```

## Google Compute Engine

```R
library(googleComputeEngineR)

# Create a virtual machine on Digital Ocean
ghost <- gce_vm_create("demo", 
                       image_project = "google-containers",
                       image_family = "gci-stable")

# Create and run a container in the virtual machine.
# This might take a while.
con <- docker_run(ghost, "debian", "echo foo")
#> Unable to find image 'debian' locally
#> debian:latest: The image you are pulling has been verified
#> Status: Downloaded newer image for debian:latest
#> foo

con
#> <container>
#>   ID:       5aa987cef673 
#>   Name:     harbor_8pfvgi 
#>   Image:    busybox 
#>   Command:  echo foo 
#>   Host:     <droplet>dhost (2941098)
#>     IP:     107.170.247.231
#>     Status: active
#>     Region: San Francisco 1
#>     Image:  Docker 1.3.0 on Ubuntu 14.04
#>     Size:   512mb ($0.00744 / hr)

# Destroy the virtual machine from Google Compute Engine
gce_vm_delete(ghost)
```
