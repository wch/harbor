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
library(harbor)

# Create a virtual machine on Google Compute Engine
job <-   gce_vm_create("demo", 
                       image_project = "google-containers",
                       image_family = "gci-stable",
                       predefined_type = "f1-micro")

## wait for the operation to complete
gce_check_zone_op(job)

## get the instance
ghost <- gce_get_instance("demo")
ghost
#> ==Google Compute Engine Instance==
#> 
#> Name:                demo
#> Created:             2016-10-06 04:41:56
#> Machine Type:        f1-micro
#> Status:              RUNNING
#> Zone:                europe-west1-b
#> External IP:         104.155.0.147
#> Disks: 
#>       deviceName       type       mode boot autoDelete
#> 1 demo-boot-disk PERSISTENT READ_WRITE TRUE       TRUE


# Create and run a container in the virtual machine.
# 'user' is the one you used to create the SSH keys

# This might take a while.
con <- docker_run(ghost, "debian", "echo foo", user = "mark")
#> Warning: Permanently added '104.155.0.147' (RSA) to the list of known hosts.
#> Unable to find image 'debian:latest' locally
#> latest: Pulling from library/debian
#> 6a5a5368e0c2: Pulling fs layer
#> 6a5a5368e0c2: Verifying Checksum
#> 6a5a5368e0c2: Download complete
#> 6a5a5368e0c2: Pull complete
#> Digest: sha256:677f184a5969847c0ad91d30cf1f0b925cd321e6c66e3ed5fbf9858f58425d1a
#> Status: Downloaded newer image for debian:latest
#> foo

con
#> <container>
#>   ID:       92f96d32d081 
#>   Name:     harbor_6rdevp 
#>   Image:    debian 
#>   Command:  echo foo 
#>   Host:     ==Google Compute Engine Instance==
#>   
#>   Name:                demo
#>   Created:             2016-10-06 04:41:56
#>   Machine Type:        f1-micro
#>   Status:              RUNNING
#>   Zone:                europe-west1-b
#>  External IP:         104.155.0.147
#>   Disks: 
#>         deviceName       type       mode boot autoDelete
#>   1 demo-boot-disk PERSISTENT READ_WRITE TRUE       TRUE
  
  
# Destroy the virtual machine from Google Compute Engine
gce_vm_delete(ghost)
```
