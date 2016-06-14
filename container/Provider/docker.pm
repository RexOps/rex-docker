#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Docker::container::Provider::container;

use strict;
use warnings;

# VERSION

use Rex -minimal;

use Moose;
use MooseX::Aliases;

use Rex::Resource::Common;
use Data::Dumper;

with qw(Rex::Resource::Role::Ensureable);

has '+ensure_options' =>
  ( default => sub { [qw/present absent running stopped/] }, );

sub present {
  my ($self) = @_;

  my $container = $self->name;

  $self->_set_status(created);

  return 1;
}

alias running => "present";

sub absent {
  my ($self) = @_;

  $self->_set_status(removed);

  return 1;
}

1;
