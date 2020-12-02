# Make sure $PERL5LIB is defined and valid.

# Assumes default installation. Change as required.
STRAWBERRY_BIN=C:\Strawberry\c\bin
ZLIB=$(STRAWBERRY_BIN)\ZLIB1__.DLL
LIBCRYPTO=$(STRAWBERRY_BIN)\LIBCRYPTO-1_1-X64__.DLL
LIBSSL=$(STRAWBERRY_BIN)\LIBSSL-1_1-X64__.DLL

# Point to a valid config file so the script can execute and PAR can collect dependencies.
CONFIG_FILE=config.ini

# Mojo requires html_entities and Commands.pm
ENTITIES_FILE=$(PERL5LIB)/Mojo/resources/html_entities.txt
COMMANDS_FILE=$(PERL5LIB)/Mojolicious/Commands.pm

# Also need two folders, the Mojolicious public and templates folders.:
MOJO_PUBLIC=$(PERL5LIB)/Mojolicious/public
MOJO_TEMPLATES=$(PERL5LIB)/Mojolicious/templates

# Mojo::IOLoop needs its resources folder
IOLOOP_RESOURCES=$(PERL5LIB)/Mojo/IOLoop/resources

# Need the TLS.pm file - an unfortunate hack so that Cwd::realpath doesn't fail. Temporary?
IOLOOP_TLS_PM=$(PERL5LIB)/Mojo/IOLoop/TLS.pm

# Now we need the locations of the "lib" folders for Mojo::Discord, Mojo::WebService::LastFM, and Discord::NP, since they won't be in your perl5/lib folder.
DISCORD_NP_LIB=$(PERL5LIB)/Discord/NP/lib
MOJO_WEBSERVICE_LASTFM_LIB=$(PERL5LIB)/Mojo/WebService/LastFM/lib
MOJO_DISCORD_LIB=$(PERL5LIB)/Mojo/Discord/lib

#CACERT File
CACERT=$(PERL5LIB)/Mozilla/CA/cacert.pem

# Kill timer tells discordnp.pl to stop executing after the specified number of seconds. We can use this for pp to gather dependencies.
KILL_TIMER=5

define PP_ARGS
		--execute \
		--xargs="--config=$(CONFIG_FILE) --kill_timer=$(KILL_TIMER)" \
		--cachedeps=build/depcache \
		--addfile="$(ENTITIES_FILE);lib/Mojo/resources/html_entities.txt" \
		--addfile="$(COMMANDS_FILE);lib/Mojolicious/Commands.pm" \
		--addfile="$(IOLOOP_RESOURCES);lib/Mojo/IOLoop/resources" \
		--addfile="$(CACERT);cacert.pem" \
		--lib=$(MOJO_DISCORD_LIB) \
		--lib=$(MOJO_WEBSERVICE_LASTFM_LIB) \
		--lib=$(DISCORD_NP_LIB) \
		--module="Mojo::IOLoop::TLS" \
		--module="IO::Socket::SSL" \
		--module="Net::SSLeay" \
		--unicode 
endef

# File extension (Only used for Windows
EXT=
ifeq ($(OS),Windows_NT)
	OSTYPE=windows
	EXT=.exe
	PP_ARGS+=--link=$(ZLIB) 
	PP_ARGS+=--link=$(LIBCRYPTO) 
	PP_ARGS+=--link=$(LIBSSL) 
else
    UNAME_S:=$(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        OSTYPE=linux
    endif
    ifeq ($(UNAME_S),Darwin)
        OSTYPE=macos
    endif
endif

PP_ARGS+=--output="build/discordnp-$(OSTYPE)$(EXT)"

default:
	@echo "Building Discord-NP for $(OSTYPE)"
	pp $(PP_ARGS) discordnp.pl
	@echo "Wrote file: build/discordnp-$(OSTYPE)$(EXT)"

clean:
	rm build/depcache
	rm build/discordnp-*
	rm build/mojo-discord.log
	rm mojo-discord.log

cleanwin:
	del build\depcache
	del build\discordnp-windows.exe
	del build\mojo-discord.log
	del mojo-discord.log
