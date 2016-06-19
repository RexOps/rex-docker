#
# (c) Jan Gehring
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Docker::Client::Resources::Base;

use Moose;
use URI::Query;

has client => (
  is  => 'ro',
  isa => 'Docker::Client',
);
sub list {
  my $self = shift;
  my @qry  = @_;

  my $qq = URI::Query->new(@qry);

  my $res_s = $self->_res;
  return $self->client->get("/\L$res_s/json?$qq");
}

sub create {
  my $self  = shift;
  my $data  = shift;
  my $qry   = shift || '';
  my $res_s = lc( $self->_res );
  return $self->client->post( "/$res_s/create?$qry", $data );
}

sub _res {
  my $self    = shift;
  my $ref_s   = ref $self;
  my ($res_s) = ( $ref_s =~ m/::([^:]+)$/ );
  return lc($res_s);
}

1;
