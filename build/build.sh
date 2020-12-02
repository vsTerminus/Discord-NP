#!/bin/bash

# Make sure $PERL5LIB is defined and valid.

# Point to a valid config file so the script can execute and PAR can collect dependencies.
CONFIG_FILE="$PWD/../config.ini"

# Mojo requires html_entities and Commands.pm
ENTITIES_FILE="$PERL5LIB/Mojo/resources/html_entities.txt"
COMMANDS_FILE="$PERL5LIB/Mojolicious/Commands.pm"

# Also need two folders, the Mojolicious public and templates folders.:
MOJO_PUBLIC="$PERL5LIB/Mojolicious/public"
MOJO_TEMPLATES="$PERL5LIB/Mojolicious/templates"

# Mojo::IOLoop needs its resources folder
IOLOOP_RESOURCES="$PERL5LIB/Mojo/IOLoop/resources"

# Need the TLS.pm file - an unfortunate hack so that Cwd::realpath doesn't fail. Temporary?
IOLOOP_TLS_PM="$PERL5LIB/Mojo/IOLoop/TLS.pm"

# Now we need the locations of the "lib" folders for Mojo::Discord, Mojo::WebService::LastFM, and Discord::NP, since they won't be in your perl5/lib folder.
DISCORD_NP_LIB="$PERL5LIB/Discord/NP/lib"
MOJO_WEBSERVICE_LASTFM_LIB="$PERL5LIB/Mojo/WebService/LastFM/lib"
MOJO_DISCORD_LIB="$PERL5LIB/Mojo/Discord/lib"

# Requires your valid config.ini file to be up a level and named config.ini
CONFIG_FILE=$CONFIG_FILE

# Kill timer tells discordnp.pl to stop executing after the specified number of seconds. We can use this for pp to gather dependencies.
KILL_TIMER=5

mkdir -p Mojo/IOLoop Mojolicious
cp -r $IOLOOP_RESOURCES Mojo/IOLoop/
cp    $IOLOOP_TLS_PM    Mojo/IOLoop/



pp \
    --execute \
    --xargs="--config=$CONFIG_FILE --kill_timer=$KILL_TIMER" \
    --cachedeps=depcache \
    --addfile="$ENTITIES_FILE;lib/Mojo/resources/html_entities.txt" \
    --addfile="$COMMANDS_FILE;lib/Mojolicious/Commands.pm" \
    --addfile="$IOLOOP_RESOURCES;lib/Mojo/IOLoop/resources" \
    --lib=$MOJO_DISCORD_LIB \
    --lib=$MOJO_WEBSERVICE_LASTFM_LIB \
    --lib=$DISCORD_NP_LIB \
    --module="Mojo::IOLoop::TLS" \
    --unicode \
    --output="discordnp-$OSTYPE" \
    ../discordnp.pl

rm $PWD/mojo-discord.log
rm -rf $PWD/Mojo $PWD/Mojolicious
