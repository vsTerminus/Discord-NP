#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

use Config::Tiny;
use Discord::NP;

# This file is responsible for reading the config, creating the Discord::NP object, and calling init().

my $config = Config::Tiny->new;
my $config_file = $ARGV[0] // 'config.ini';

$config = Config::Tiny->read( $config_file, 'utf8' );
say localtime(time) . " - Loaded Config: " . $config_file;

my $discord_token = $config->{'discord'}{'token'};
$discord_token =~ s/^(?:token:)?"?"?(.*?)"?"?$/$1/;  # Extract the actual token if they user copypasted the entire field from their browser.

my $lastfm_key = $config->{'lastfm'}{'api_key'};
$lastfm_key =~ s/^"?(.*?)"?$/$1/;

my $np = Discord::NP->new(
    'interval'          => $config->{'lastfm'}{'interval'},
    'lastfm_user'       => $config->{'lastfm'}{'username'},
    'lastfm_key'        => $lastfm_key,
    'discord_token'     => $discord_token,
    'logdir'            => $config->{'discord'}{'log_dir'},
    'loglevel'          => $config->{'discord'}{'log_level'},
);

$np->init();
