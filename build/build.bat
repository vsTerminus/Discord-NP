:: Make sure %PERL5LIB% is defined and valid.

SET PWD=%~dp0

:: Point to a valid config file so the script can execute and PAR can collect dependencies.
SET CONFIG_FILE=%PWD%..\config.ini

:: Mojo requires html_entities and Commands.pm
SET ENTITIES_FILE=%PERL5LIB%\Mojo\resources\html_entities.txt
SET COMMANDS_FILE=%PERL5LIB%\Mojolicious\Commands.pm

:: Also need two folders, the Mojolicious public and templates folders.
SET MOJO_PUBLIC=%PERL5LIB%\Mojolicious\public
SET MOJO_TEMPLATES=%PERL5LIB%\Mojolicious\templates

:: Mojo::IOLoop needs its resources folder
SET IOLOOP_RESOURCES=%PERL5LIB%\Mojo\IOLoop\resources

:: Now we need the locations of the "lib" folders for Mojo::Discord, Mojo::WebService::LastFM, and Discord::NP, since they won't be in your perl5\lib folder.
SET DISCORD_NP_LIB=%PERL5LIB%\Discord\NP\lib
SET MOJO_WEBSERVICE_LASTFM_LIB=%PERL5LIB%\Mojo\WebService\LastFM\lib
SET MOJO_DISCORD_LIB=%PERL5LIB%\Mojo\Discord\lib

:: Kill timer tells discordnp.pl to stop executing after the specified number of seconds. We can use this for pp to gather dependencies.
SET KILL_TIMER=2

pp ^
    --execute ^
    --xargs="--config='%CONFIG_FILE%' --kill_timer=%KILL_TIMER%" ^
    --cachedeps="depcache" ^
	-l libeay32__.dll ^
    -l zlib1__.dll ^
    -l ssleay32__.dll ^
    --addfile="%ENTITIES_FILE%;Mojo\resources\html_entities.txt" ^
    --addfile="%COMMANDS_FILE%;Mojolicious\Commands.pm" ^
	--addfile="%IOLOOP_RESOURCES%;lib\Mojo\IOLoop\resources" ^
    --addfile="%IOLOOP_RESOURCES%;Mojo\IOLoop\resources" ^
	--addfile="%PERL5LIB%\Mojo\IOLoop\TLS.pm;Mojo\IOLoop\TLS.pm" ^
    --lib="%MOJO_DISCORD_LIB%" ^
    --lib="%MOJO_WEBSERVICE_LASTFM_LIB%" ^
    --lib="%DISCORD_NP_LIB%" ^
    --output="discordnp-windows.exe" ^
    %PWD%\..\discordnp.pl

rm %PWD%\mojo-discord.log

::     --unicode ^
:: 	--module="IO::Socket::SSL" ^