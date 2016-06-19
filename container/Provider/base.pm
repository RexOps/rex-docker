#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Docker::container::Provider::base;

use strict;
use warnings;

# VERSION

use Moose;
use Data::Dumper;
use List::MoreUtils qw/any/;

use Docker::Client;

extends qw(Rex::Resource::Provider);
has client => (
  is      => 'ro',
  isa     => 'Docker::Client',
  lazy    => 1,
  default => sub {
    Docker::Client->new;
  },
);

has container_exists => (
  is      => 'ro',
  isa     => 'Bool',
  writer  => '_set_container_exists',
  default => sub { 0 },
);

sub test {
  my ($self) = @_;

  my $docker_name = $self->name;

  my $all_containers = $self->client->containers->list( all => 1 );

  my @container_names =
    map { @{ $_->{Names} } } @{$all_containers};

  if ( any { $_ eq "/$docker_name" } @container_names ) {
    $self->_set_container_exists(1);

    if ( $self->config->{ensure} eq "present" ) {
      return 1;
    }

    if ( $self->config->{ensure} eq "running"
      && $self->_container_running( $docker_name, $all_containers ) )
    {
      return 1;
    }
  }

  # no container found
  return 0;
}

sub _container_running {
  my ( $self, $name, $containers ) = @_;
  $containers ||= $self->client->containers->list( all => 1 );

  for my $c ( @{$containers} ) {
    if ( any { $_ eq "/$name" } @{ $c->{Names} } ) {
      if ( lc( $c->{Status} ) =~ /^Up/i ) {
        return 1;
      }
    }
  }

  return 0;
}

1;
