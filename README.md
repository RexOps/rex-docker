# Docker

This is a docker module for Rex to manage Docker containers.

## STATUS

* This module is for the current development branch (Rex 2)
* This module is in developemnt state

## Tasks

### setup

Call this task to install docker on your system.

#### Parameters

* ensure - Default: latest
* package, Name of the package to install. - Default: docker.io
* service, Name of the service to manager. - Default: docker
* on_pkg_change, Code that should be executed when the package is updated. - Default: `service $service => "restart";`

#### Example

```perl
use Docker;

task "setup", sub {
  Docker::setup;
};
```

```perl
use Docker;

task "setup", sub {
  Docker::setup {
    on_pkg_change => sub { },  # do nothing
  };
};
```

### start | stop | restart | reload

Do the named action with the docker service.

#### Example

```perl
Docker::restart;
```

```bash
$ rex -H $host Docker:restart
```

## Resources

### container

Manage the state of a container.

#### Parameters

* ensure, State of the container - Default: present
  * present
  * running
  * stop
  * absent
* image, Which image to pull/use for this container
* expose, Ports to expose
* bind, Volumes to bind
* link, Other containers to link
* environment, Environment variables to export to the container

#### Example

```perl
Docker::container "nginx",
  ensure => "running",
  image  => "nginx:latest",
  expose => {
    "80"  => "80/tcp",
    "443" => "443/tcp",
  },
  bind => {
    "/srv/containers/nginx/etc/nginx" => "/etc/nginx",
  },
  link => {
    "redis" => "redis",
  },
  environment => {
    "MY_THING" => "value",
  };
```

