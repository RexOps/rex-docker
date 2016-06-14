#
# (c) Jan Gehring
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Docker::Client;

use Moose;

use JSON::XS;
use HTTP::Request;

#use HTTP::Response;

use Mojo::Message::Response;

use Rex::Helper::Run;
use Rex::Helper::Path;
use Rex::Commands::File;
use Rex::Commands::Fs;

use Docker::Client::Resources::Containers;

has socket => (
  is      => 'ro',
  isa     => 'Str',
  default => sub { "/var/run/docker.sock" },
);

has containers => (
  is      => 'ro',
  isa     => 'Docker::Client::Resources::Containers',
  lazy    => 1,
  default => sub {
    Docker::Client::Resources::Containers->new( client => shift );
  },
);

sub get {
  my $self = shift;
  my $url  = shift;

  my $req = HTTP::Request->new(
    GET => "http://localhost$url",
    [
      "Accept"     => "application/json",
      "Host"       => "localhost",
      "Connection" => "Close",
    ]
  );
  my @req_s = split( /\n/, $req->as_string );
  my $x = shift @req_s;
  unshift @req_s, "$x HTTP/1.1";

  my $socket_file = $self->socket;

  my $t_file = get_tmp_file;

  Rex::Logger::debug("Sending to docker daemon: ");
  Rex::Logger::debug( join( "\n", @req_s ) );

  file $t_file, content => join( "\n", @req_s );
  my @lines = i_run "( cat $t_file; echo ) | nc -U $socket_file";
  unlink $t_file;

  my $res = Mojo::Message::Response->new;
  $res->parse( join( "\n", @lines ) );
  if ( $res->code == 200 || $res->code == 201 ) {
    return $res->json;
  }
  elsif ( $res->code == 204 ) {
    return "";
  }
  else {
    die "Error parsing response from Docker daemon.\n"
      . "Status: "
      . $res->code . " "
      . $res->message;
  }
}

sub post {
  my $self = shift;
  my $url  = shift;
  my $data = shift;

  my $enc_data = $data ? encode_json($data) : "";

  my $req = HTTP::Request->new(
    POST => "http://localhost$url",
    [
      "Accept"         => "application/json",
      "Host"           => "localhost",
      "Connection"     => "Close",
      "Content-Type"   => "application/json",
      "Content-Length" => length $enc_data,
    ],
    $enc_data,
  );

  my @req_s = split( /\n/, $req->as_string );
  my $x = shift @req_s;
  unshift @req_s, "$x HTTP/1.1";

  my $socket_file = $self->socket;

  my $t_file = get_tmp_file;

  Rex::Logger::debug("Sending to docker daemon: ");
  Rex::Logger::debug( join( "\n", @req_s ) );

  file $t_file, content => join( "\n", @req_s );
  my @lines = i_run "( cat $t_file; echo ) | nc -U $socket_file";
  unlink $t_file;

  my $res = Mojo::Message::Response->new;
  $res->parse( join( "\n", @lines ) );
  if ( $res->code == 200 || $res->code == 201 ) {
    return $res->json;
  }
  elsif ( $res->code == 204 ) {
    return "";
  }
  else {
    die "Error parsing response from Docker daemon.\n"
      . "Status: "
      . $res->code . " "
      . $res->message;
  }
}

1;
