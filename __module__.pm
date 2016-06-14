#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
#
# (c) Jan Gehring
#

package Docker;

use strict;
use warnings;

use Rex -base;

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

  my $pkg     = $package{ get_operating_system() };
  my $service = $service_name{ get_operating_system() };

  # install docker package
  update_package_db;
  pkg $pkg, ensure => "present";

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

