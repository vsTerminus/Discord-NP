package Discord::NP;
use feature 'say';
binmode(STDOUT, ":utf8");

use Moo;
use strictures 2;
use Mojo::WebService::LastFM;
use Mojo::Discord;
use Mojo::IOLoop;
use Data::Dumper;
use namespace::clean;

# Read the config file
# Default to "config.ini" unless one is passed in as an argument
has 'interval'      => ( is => 'rw', default => 60 );
has 'discord_token' => ( is => 'ro' );
has 'discord'       => ( is => 'lazy', builder => sub {
    my $self = shift;
    my $discord = Mojo::Discord->new(
        'token'         => $self->discord_token,
        'token_type'    => 'Bearer',
        'name'          => 'Discord Now Playing',
        'url'           => 'https://github.com/vsterminus',
        'version'       => '1.0',
        'logdir'        => $self->logdir,
        'loglevel'      => $self->loglevel,
        'reconnect'     => 1,
    );
});
has 'logdir'        => ( is => 'ro' );
has 'loglevel'      => ( is => 'ro' );
has 'lastfm_user'   => ( is => 'ro' );
has 'lastfm_key'    => ( is => 'ro' );
has 'lastfm'        => ( is => 'lazy', builder => sub { Mojo::WebService::LastFM->new( api_key => shift->lastfm_key ) } );
has 'my_id'         => ( is => 'rw' );
has 'last_status'   => ( is => 'rw' );
has 'show_artist'   => ( is => 'ro' );
has 'show_title'    => ( is => 'ro' );

# Poll Last.FM and update the user's Discord status
sub update_status
{
    my ($self, $update) = @_;

    # Mojo::WebService::LastFM lets us optionally specify a format to return the results in.
    # Without it we would just get a hashref back containing all of the values.
    # For this script all we need is Artist - Title.
    #
    # This call is also optionally non-blocking if a callback function is provided, which we are doing.
    $self->lastfm->nowplaying({username => $self->lastfm_user}, sub
    {   
        my $json = shift;
        my $nowplaying = $json->{'artist'} . ' - ' . $json->{'title'};
        
        my $sidebar = "Music";
        if ( $self->show_artist and $self->show_title ) { $sidebar = $nowplaying }
        elsif ( $self->show_artist ) { $sidebar = $json->{'artist'} }
        elsif ( $self->show_title )  { $sidebar = $json->{'title'} }

        # Only update if the song is currently playing
        # We can identify that by $lastfm->{'date'} being undefined.
        if ( defined $nowplaying and !defined $json->{'date'} )
        {
            # Now connect to discord. Receiving the READY packet from Discord will trigger the status update automatically.
            $self->discord->status_update({
                'name' => $sidebar,
                'type' => 2, # Listening to... $np
                'details' => $nowplaying,
                'state' => $json->{'album'}
            });

            say localtime(time) . " - Now Playing: $nowplaying";
            $self->last_status($nowplaying);
        }
        else
        {
            if ( defined $self->last_status )
            {
                $self->discord->status_update({
                    'name'  => 'Nothing',
                    'type'  => 2
                });

                say localtime(time) . " - Nothing is currently playing.";
                $self->last_status(undef);
            }
        }
    });
}

sub add_me
{
    my ($self, $user) = @_;
    $self->my_id($user->{'id'});
}

sub init
{
    my $self = shift;

    $self->discord->gw->on('READY' => sub 
    {
        my ($gw, $hash) = @_;
        say localtime(time) . " - Connected to Discord";
        $self->add_me($hash->{'user'});
        $self->update_status();
    });

    $self->discord->gw->on('FINISH', => sub {
        say localtime(time) . " - Disconnected from Discord";
    });
   
    # Connect to Discord
    $self->discord->init();
    
    # Update status on a recurring timer
    Mojo::IOLoop->recurring($self->interval => sub { $self->update_status(); });

    # Start IOLoop - Nothing below this line will execute until the loop ends (never).
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}

1;
