#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

=head1 NAME

Docker::container - Docker Container resource

=head1 DESCRIPTION

With this module it is possible to manage state of docker containers.

=head1 SYNOPSIS

 task "setup", sub {
   Docker::container "mysql",
     ensure => "running",
     image  => "mysql:latest",
     expose => {
       "2222/tcp"  => "22",
       "23306/tcp" => "3306",
     },
     bind   => {
       "/dev"      => "/dev",
       "/mnt/data" => "/data",
     },
     environment => {
       MYSQL_ROOT_PASSWORD => "s0mep4ass",
     };
 };

=head1 PARAMETER

=over 4

=item ensure

Valid options:

=over 4

=item present

Make sure that the container exists.

=item running

Make sure that the container is running.

=item stopped

Make sure that the container is stopped.

=item absent

Make sure that the given container is removed.

=back

=item image

Which image to use to for the container.

=item expose

The ports that should be exposed.

=item bind

The datadirectories which should be mounted.

=item environment

The environment variables that should be available inside the container.

=back

=cut

package Docker::container;

use strict;
use warnings;

# VERSION

use Rex -minimal;

use Rex::Resource::Common;

use Carp;

resource "container", sub {
  my $container_name = resolv_path( resource_name() );

  my $container_config = {
    ensure      => param_lookup( "ensure",      "present" ),
    name        => $container_name,
    bind        => param_lookup( "bind",        undef ),
    expose      => param_lookup( "expose",      undef ),
    environment => param_lookup( "environment", undef ),
  };

  my $provider =
    param_lookup( "provider", "Docker::container::Provider::docker" );

  Rex::Logger::debug("Get Docker::container provider: $provider");

  return ( $provider, $container_config );
};

1;
