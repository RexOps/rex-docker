#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Docker::container::Provider::docker;

use strict;
use warnings;

# VERSION

use Rex -minimal;

use Moose;

use Rex::Resource::Common;
use Data::Dumper;

extends qw(Docker::container::Provider::base);
with qw(Rex::Resource::Role::Ensureable);
has '+ensure_options' =>
  ( default => sub { [qw/present absent running stopped/] }, );

sub present {
  my ($self) = @_;

  my $container_name = $self->name;

  $self->client->images->create( $self->config->{image} );

  my @binds;
  if ( $self->config->{bind} ) {
    for my $local ( keys %{ $self->config->{bind} } ) {
      push @binds, "$local:" . $self->config->{bind}->{$local};
    }
  }

  my @links;
  if ( $self->config->{link} ) {
    for my $link_local ( keys %{ $self->config->{link} } ) {
      push @links, "$link_local:" . $self->config->{link}->{$link_local};
    }
  }

  my @env;
  if ( $self->config->{environment} ) {
    for my $key ( keys %{ $self->config->{environment} } ) {
      push @env, "$key=" . $self->config->{environment}->{$key};
    }
  }

  my %ports;
  if ( $self->config->{expose} ) {
    for my $local ( keys %{ $self->config->{expose} } ) {
      $ports{ $self->config->{expose}->{$local} } = [
        {
          HostPort => $local,
        }
      ];
    }
  }

  my $id = $self->client->containers->create(
    {
      Image => $self->config->{image},
      ( @env ? ( Env => \@env ) : () ),
      HostConfig => {
        ( @binds ? ( Binds => \@binds ) : () ),
        ( $self->config->{link} ? ( Links => $self->config->{link} ) : () ),
        ( %ports ? ( PortBindings => \%ports ) : () ),
      },
    },
    $container_name,
  );

  $self->_set_message("Container created with id: $id");
  $self->_set_status(created);

  return 1;
}

sub running {
  my ($self) = @_;
  $self->present unless $self->container_exists;
  $self->client->containers->start( $self->name );
  $self->_set_status("running");
}

sub absent {
  my ($self) = @_;

  $self->_set_status(removed);

  return 1;
}

1;
