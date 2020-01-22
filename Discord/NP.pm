package Discord::NP;
use feature 'say';

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
has 'discord'       => ( is => 'rwp' );
has 'logdir'        => ( is => 'ro' );
has 'loglevel'      => ( is => 'ro' );
has 'lastfm_user'   => ( is => 'ro' );
has 'lastfm_key'    => ( is => 'ro' );
has 'lastfm'        => ( is => 'rwp' );
has 'my_id'         => ( is => 'rw' );

sub BUILD
{
    my $self = shift;

    $self->_set_lastfm(  Mojo::WebService::LastFM->new( api_key => $self->lastfm_key ) );

    $self->_set_discord(
        Mojo::Discord->new(
            'token'         => $self->discord_token,
            'token_type'    => 'Bearer',
            'name'          => 'Discord Now Playing',
            'url'           => 'https://github.com/vsterminus',
            'version'       => '1.0',
            'logdir'        => $self->logdir,
            'loglevel'      => $self->loglevel,
            'reconnect'     => 1,
            'callbacks'     => {
                'READY'     => sub { $self->on_ready(@_) },
                'FINISH'    => sub { $self->on_finish(@_) },
                'PRESENCE_UPDATE'   => sub { $self->on_presence_update(@_) },
            },
        )
    );
}

# Poll Last.FM and update the user's Discord status if the track has changed.
sub update_status
{
    my ($self, $update) = @_;

    # Mojo::WebService::LastFM lets us optionally specify a format to return the results in.
    # Without it we would just get a hashref back containing all of the values.
    # For this script all we need is Artist - Title.
    #
    # This call is also optionally non-blocking if a callback function is provided, which we are doing.
    $self->lastfm->nowplaying(
    {   
        user     => $self->lastfm_user,
        callback => sub { 
            my $json = shift;
            my $nowplaying = $json->{'artist'} . ' - ' . $json->{'title'};

            # Only update if the song is currently playing
            # We can identify that by $lastfm->{'date'} being undefined.
            if ( defined $nowplaying and !defined $json->{'date'} )
            {
                # Now connect to discord. Receiving the READY packet from Discord will trigger the status update automatically.
                $self->discord->status_update({
                  'name' => $json->{'artist'},
                  'type' => 2, # Listening to... $np
                  'details' => $nowplaying,
                  'state' => $json->{'album'}
                });

                say localtime(time) . " - Status Updated: $nowplaying";
            }
            else
            {
                say localtime(time) . " - Unable to retrieve Last.FM data.";
            }
        }
    });
}

# It tells us that it is now safe to send a status update.
sub on_ready
{
    my ($self, $hash) = @_;

    $self->add_me($hash->{'user'});

    $self->update_status();
}

sub add_me
{
    my ($self, $user) = @_;
    say "Adding my ID as " . $user->{'id'};
    $self->my_id($user->{'id'});
}

sub on_finish
{
    my ($self) = @_;

    say localtime(time) . " - Disconnected from Discord.";
}

sub on_presence_update
{
    my ($self, $hash) = @_;

    if ( exists $hash->{'user'}{'id'} )
    {
        if ( $self->my_id == $hash->{'user'}{'id'} )
        {
            say " - Presence update";
            say Data::Dumper->Dump([$hash], ['hash']);
        }
    }
}

sub init
{
    my $self = shift;

    # This is the first line of code executed by the script (aside from setting variables).
    # It should trigger the first poll to Last.FM immediately.
    $self->discord->init();

    # Now set up a recurring timer to periodically poll Last.FM for new updates.
    Mojo::IOLoop->recurring($self->interval => sub { $self->update_status(); });

    # Start the IOLoop. This will connect to discord and begin the LastFM timers.
    # Anything below this line will not execute until the IOLoop completes (which is never).
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}

1;
