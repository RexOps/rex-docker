#
# (c) Jan Gehring
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Docker::Client::Resources::Containers;

use Moose;

extends 'Docker::Client::Resources::Base';

around create => sub {
  my ( $orig, $self, $data, $name ) = @_;
  my $ret = $self->$orig( $data, "name=$name" );
  return $ret->{Id};
};

sub start {
  my ( $self, $id ) = @_;
  $self->client->post("/containers/$id/start");
}

sub stop {
  my ( $self, $id, $timeout ) = @_;
  $timeout ||= 15;
  $self->client->post("/containers/$id/stop?t=$timeout");
}

sub restart {
  my ( $self, $id, $timeout ) = @_;
  $timeout ||= 15;
  $self->client->post("/containers/$id/restart?t=$timeout");
}

sub kill {
  my ( $self, $id ) = @_;
  $self->client->post("/containers/$id/kill");
}

1;
