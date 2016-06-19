#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
#
# (c) Jan Gehring
#

package Docker;

use strict;
use warnings;

use Rex -minimal;
use Rex::Commands::Pkg;
use Rex::Commands::Service;
use Rex::Commands::Gather;

use Rex::Resource::Common;

use Rex::Helper::Rexfile::ParamLookup;

use Docker::container::Provider::docker;
eval {
  # For Rex > 1
  use Rex::Commands::Template;
  use Rex::Commands::Task;
};

# some package-wide variables

our %package = (
  Debian => "docker.io",
  Ubuntu => "docker.io",
);

our %service_name = (
  Debian => "docker",
  Ubuntu => "docker",
);

task "setup", sub {

  my $ensure = param_lookup "ensure", "latest";

  my $pkg     = param_lookup "package", $package{ get_operating_system() };
  my $service = param_lookup "service", $service_name{ get_operating_system() };
  my $on_pkg_change = param_lookup "on_change",
    sub { service $service => "restart" };

  # install docker package
  pkg $pkg, ensure => $ensure, on_change => $on_pkg_change;

  # ensure that docker is started
  service $service => "ensure" => "started";
};

task "start", sub {

  my $service = $service_name{ get_operating_system() };
  service $service => "start";

};

task "stop", sub {

  my $service = $service_name{ get_operating_system() };
  service $service => "stop";

};

task "restart", sub {

  my $service = $service_name{ get_operating_system() };
  service $service => "restart";

};

task "reload", sub {

  my $service = $service_name{ get_operating_system() };
  service $service => "reload";

};

resource "container", sub {
  my $container_name = resource_name();

  my $container_config = {
    ensure      => param_lookup( "ensure",      "present" ),
    name        => $container_name,
    image       => param_lookup("image"),
    bind        => param_lookup( "bind",        undef ),
    link        => param_lookup( "link",        undef ),
    expose      => param_lookup( "expose",      undef ),
    environment => param_lookup( "environment", undef ),
  };

  my $provider =
    param_lookup( "provider", "Docker::container::Provider::docker" );

  Rex::Logger::debug("Get Docker::container provider: $provider");

  return ( $provider, $container_config );
};

1;

=pod

=head1 NAME

Docker - Module to install Docker Server

=head1 USAGE

Put it in your I<Rexfile>

 use Docker;
  
 # your tasks
 task "one", sub {};
 task "two", sub {};
    

And call it:

 rex -H $host Docket:setup

Or, to use it as a library

 task "yourtask", sub {
    Docker::setup();
 };
   


=head1 TASKS

=over 4

=item setup

This task will install docker server.

=item start

This task will start the docker daemon.

=item stop

This task will stop the docker daemon.

=item restart

This task will restart the docker daemon.

=item reload

This task will reload the docker daemon.

=back

=cut

