# Docker Socket Firewall

The docker socket firewall provides a way to protect the docker socket using OPA rego policies.
For more information  on the rego format see: [Open Policy Agent](https://www.openpolicyagent.org/)\
Used rego version: [0.68.0](https://www.openpolicyagent.org/docs/v0.68.0/policy-reference/)

When running the firewall opens a unix socket that proxies all requests through to the real docker socket, 
you can define policies that lock down:
- commands to the docker daemon
- images, commands, ... in Dockerfiles

## Usage

Simply run the docker image with the following mounts:

| path in container     | description                                                    |
|-----------------------|----------------------------------------------------------------|
| /mnt/in/docker.sock   | original docker-socket                                         |
| /mnt/out              | an empty dir; the proxied docker.sock will be created in there |
| /mnt/conf             | a dir which contains the *.rego files                          |

If the env-var ```VERBOSE``` is set to ```1``` then the log will contain every request with its decision.

For the usage of the underlying binary and more (possible outdated) examples
visit the [original repo](https://github.com/linead/docker-socket-firewall).

## Policy examples

### Run policies - authz.rego

Only allow ```docker ps```

```
package docker.authz

import rego.v1

allow if { ping }
allow if { version }
allow if { list }

ping if {
	input.Method == "HEAD"
	path == "/_ping"
}

version if {
	input.Method == "GET"
	path == "/version"
}

list if {
	input.Method == "GET"
	path == "/containers/json"
}


# helpers

versioned := regex.match(`^/v\d+.*`, input.Path)

path := output if {
	not versioned
	index := indexof(input.Path, "?")
	output = substring(input.Path, 0, index)
}

path := output if {
	versioned
	path := substring(input.Path, 2, -1)
	start := indexof(path, "/")
	end := indexof(path, "?") - start
	output = substring(path, start, end)
}
```

### Build Policies - build.rego

Disable dockerfiles containing the line "FROM node"

```
package docker.build
  
allow {
  not nodeImage
}

nodeImage {
  images[_] = "node"
} {
  true
}

## Get all FROM lines ##
images[output] {
  line := input.Dockerfile[_]
  startswith(line, "FROM")
  output = substring(line, 5, -1)
}
```

## Building

```docker build -t docker_socket_firewall .```
