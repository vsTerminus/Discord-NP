#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

use FindBin 1.51 qw( $RealBin );
use lib "$RealBin/lib";

use File::Spec;
use File::Basename;

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

###################### Load and Validate Config ###################

my $config = Config::Tiny->new;
my $config_file = "$RealBin/config.ini";
my $kill_timer = 0;

GetOptions ("config=s" => \$config_file,
            "kill_timer:i" => \$kill_timer,
) or die ("Error in command line args\n");

# Make sure config file exists
die("Could not find config file. File does not exist or is not accessible.\n" .
    "File specified: " . $config_file . "\n")
    unless -f $config_file;
$config = Config::Tiny->read( $config_file, 'utf8' );
say localtime(time) . " - Loaded Config: " . basename( $config_file );

# Make sure the token is defined and looks kind of like a discord token
my $discord_token = $config->{'discord'}{'token'};
$discord_token =~ s/^(?:token:)?"?"?(.*?)"?"?$/$1/;  # Extract the actual token if they user copypasted the entire field from their browser.
die("Could not read Discord Token value.\n" .
    "Expected: A string of letters, numbers, periods, hyphens, and underscores. No quotes, colons, spaces, or other characters.\n" .
    "Value as entered: \n" . $discord_token)
    unless length $discord_token > 0 and $discord_token =~ /^[A-Za-z0-9-_\.]+$/;
say localtime(time) . " - Discord Token: OK (Ends with ". substr($discord_token, -4, 4) . ")";

# Make sure the LastFM API Key is defined and looks like a hex string
my $lastfm_key = $config->{'lastfm'}{'api_key'};
$lastfm_key =~ s/^"?(.*?)"?$/$1/;
die("Could not read LastFM API Key value.\n" .
    "Expected: A string of hexadecimal characters 0-9 and a-f. No special characters or spaces.\n" .
    "Value as entered: \n" . $lastfm_key)
    unless length $lastfm_key > 0 and $lastfm_key =~ /^[A-Fa-f0-9]+$/;
say localtime(time) . " - LastFM API Key: OK (Ends with " . substr($lastfm_key, -4, 4) . ")";

# Make sure the LastFM Username is defined
die("Could not read LastFM Username value.\n") unless exists $config->{'lastfm'}{'username'} and length $config->{'lastfm'}{'username'} > 0;
say localtime(time) . " - LastFM User: " . $config->{'lastfm'}{'username'};

my $show_artist = ( lc $config->{'lastfm'}{'show_artist'} eq 'yes' ? 1 : 0 );
my $show_title  = ( lc $config->{'lastfm'}{'show_title'}  eq 'yes' ? 1 : 0 );

###################### End Validation ###########################

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
