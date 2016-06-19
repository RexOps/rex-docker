#
# (c) Jan Gehring
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Docker::Client::Resources::Images;

use Moose;

extends 'Docker::Client::Resources::Base';

around create => sub {
  my ( $orig, $self, $name ) = @_;
  $self->$orig( undef, "fromImage=$name" );
};

1;
