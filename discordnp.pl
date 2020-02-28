#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

use FindBin 1.51 qw( $RealBin );
use lib "$RealBin/lib";

# For PAR::Packer so we can find the files we packed
use File::Spec;
BEGIN {
    if(exists $ENV{PAR_TEMP}) {
        my $dir = File::Spec->catfile($ENV{PAR_TEMP}, 'inc');
        chdir $dir or die "chdir `$dir' failed: $!";
    }
}

use Getopt::Long;
use Config::Tiny;
use Discord::NP;
use Mojo::IOLoop;

# This file is responsible for reading the config, creating the Discord::NP object, and calling init().

my $config = Config::Tiny->new;
my $config_file = "$RealBin/config.ini";
my $kill_timer = 0;
GetOptions ("config=s" => \$config_file,
            "kill_timer:i" => \$kill_timer,
) or die ("Error in command line args\n");

$config = Config::Tiny->read( $config_file, 'utf8' );
say localtime(time) . " - Loaded Config: " . $config_file;

my $discord_token = $config->{'discord'}{'token'};
$discord_token =~ s/^(?:token:)?"?"?(.*?)"?"?$/$1/;  # Extract the actual token if they user copypasted the entire field from their browser.

my $lastfm_key = $config->{'lastfm'}{'api_key'};
$lastfm_key =~ s/^"?(.*?)"?$/$1/;

my $show_artist = ( lc $config->{'lastfm'}{'show_artist'} eq 'yes' ? 1 : 0 );
my $show_title  = ( lc $config->{'lastfm'}{'show_title'}  eq 'yes' ? 1 : 0 );

my $np = Discord::NP->new(
    'interval'          => $config->{'lastfm'}{'interval'},
    'lastfm_user'       => $config->{'lastfm'}{'username'},
    'lastfm_key'        => $lastfm_key,
    'discord_token'     => $discord_token,
    'logdir'            => $config->{'discord'}{'log_dir'},
    'loglevel'          => $config->{'discord'}{'log_level'},
    'show_artist'       => $show_artist,
    'show_title'        => $show_title,
);

# Used for PAR::Packer so it can run the application temporarily to gather dependencies.
Mojo::IOLoop->timer($kill_timer => sub { $np->discord->disconnect; Mojo::IOLoop->stop; }) if $kill_timer > 0;

$np->init();
