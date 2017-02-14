#!/usr/bin/env perl

use v5.10;
use warnings;
use strict;

use Mojo::LastFM;
use Net::Discord;
use Config::Tiny;
use Mojo::IOLoop;

my $config = Config::Tiny->new;
my $config_file = $ARGV[0] // 'config.ini';

$config = Config::Tiny->read( $config_file, 'utf8' );
say localtime(time) . " - Loaded Config: $config_file";

my $last_played = "";
my $interval = $config->{'lastfm'}->{'interval'};

my $lastfm = Mojo::LastFM->new(
    api_key     => $config->{'lastfm'}->{'api_key'}
);

my $discord = Net::Discord->new(
    # Ctrl+Shift+I and type localStorage.token in the console to get the user token.
    'token'         => $config->{'discord'}->{'token'},
    'token_type'    => 'Bearer',
    'name'          => 'Discord Now Playing',
    'url'           => 'https://github.com/vsterminus',
    'version'       => '1.0',
    'verbose'       => $config->{'discord'}->{'verbose'},
    'reconnect'     => 1,
    'callbacks'     => {
        'on_ready'  => \&on_ready,
#        'on_finish' => \&on_finish,
    },
);

sub update_status
{
    $lastfm->nowplaying({   user     => $config->{'lastfm'}->{'username'}, 
                            format   => "%artist% - %title%", 
                            callback => sub 
    {
        my $np = shift;

        if ( defined $np )
        {
            if ( $np ne $last_played )
            {
                $discord->status_update({'game' => $np});
                say localtime(time) . " - Status Updated: $np";
                $last_played = $np;
            }
        }
        else
        {
            say localtime(time) . " - Unable to retrieve Last.FM data.";
        }    
    }});

    

}

sub on_ready
{
    my ($hash) = @_;

    say localtime(time) . " - Connected to Discord.";

    # Update status immediately
    update_status();

    # This will trigger the Last.FM lookup timer
    Mojo::IOLoop->recurring($config->{'lastfm'}->{'interval'} => sub { update_status(); });
}

# Set up the Discord Gateway Websocket connection
$discord->init();

# Start the IOLoop. This will connect to discord and begin the LastFM timers.
Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
