#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

use FindBin 1.51 qw( $RealBin );
use lib "$RealBin/lib";

use File::Spec;

my $print_par = 0; # Set to 1 to print the PAR directory for debugging packed executables
BEGIN {
    if( exists $ENV{PAR_TEMP} and defined $ENV{PAR_TEMP} ) 
	{
        # If this is a PAR packed executable, include the packed lib directory so we get packed libraries in our path.
		my $par_lib = $ENV{PAR_TEMP} . '/inc/lib';
		push @INC, "$par_lib";
        
        if ( $print_par )
        {
		    say Data::Dumper->Dump([$ENV{PAR_TEMP}], ['par_temp']);
		    say Data::Dumper->Dump([$par_lib], ['par_lib']);
        }
    }
}

use Getopt::Long;
use Config::Tiny;
use Discord::NP;
use Mojo::IOLoop;

use IO::Socket::SSL;
# use IO::Socket::SSL qw(debug99); # Debugging output for troubleshooting connections

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
