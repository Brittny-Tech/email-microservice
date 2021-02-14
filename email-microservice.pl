#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use Mojo::Log;
use Dotenv;
use HTTP::Request::Common;
use MIME::Base64 qw(encode_base64);
use Encode qw(encode);
require LWP::UserAgent;
use Syntax::Keyword::Try;

Dotenv->load;    # merge the contents of .env in %ENV

# Enable Log to STDERR
my $log = Mojo::Log->new;

# Get vars set in env 
my $PORT = $ENV{'PORT'};
my $MAILGUN_API_KEY = $ENV{'MAILGUN_API_KEY'};
my $MAILGUN_DOMAIN = $ENV{'MAILGUN_DOMAIN'};
my $MAILGUN_RECIPIENT = $ENV{'MAILGUN_RECIPIENT'};


if(defined $PORT){
  $log->info("Running on production, setting port.");
  $ENV{'MOJO_LISTEN'} = "http://0.0.0.0:$PORT";
}

get '/' => sub ($c) {
  $c->render(text => 'Hello World!');
};

post '/email' => sub ($c) {
  try {

    my $subject = $c->param("subject");
    my $html = $c->param("html");
    my $from = $c->param("from");

    my $encoded_auth_info = encode_base64(encode("UTF-8", "api:$MAILGUN_API_KEY"));

    my $ua = LWP::UserAgent->new;
    $ua->default_header('Authorization',  "Basic " . $encoded_auth_info);
    
    my $request = HTTP::Request::Common::POST( $MAILGUN_DOMAIN, [
      from => 'Brittny.Tech Form Response <mailgun@sandbox11ee66a9e00240238a5244a9e63f30a0.mailgun.org>', 
      to => $MAILGUN_RECIPIENT, 
      subject => $subject, 
      html => $html . " - Please reply to: " . $from
    ]);
    
    my $response = $ua->request($request);
    $c->render(json => $response->decoded_content);

  } catch ($e) {

    $c->render(json => { error => "something bad happened: $e" });

  }
};

app->start;