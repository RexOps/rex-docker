#
# (c) Jan Gehring
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Docker::Client::Resources::Base;

use Moose;

has client => (
  is  => 'ro',
  isa => 'Docker::Client',
);

sub list {
  my $self  = shift;
  my $res_s = $self->_res;
  return $self->client->get("/\L$res_s/json");
}

sub create {
  my $self  = shift;
  my $data  = shift;
  my $qry   = shift || '';
  my $res_s = $self->_res;
  return $self->client->post( "/\L$res_s/create?$qry", $data );
}

sub _res {
  my $self    = shift;
  my $ref_s   = ref $self;
  my ($res_s) = ( $ref_s =~ m/::([^:]+)$/ );
  return lc($res_s);
}

1;
