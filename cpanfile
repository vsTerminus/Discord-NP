# To use: cpanm --installdeps .

# Mojo::Discord and Mojo::WebService::LastFM are not up on cpan. You'll have to get it from my github and install them yourself into your perl lib folder.
# requires 'Mojo::Discord';
# requires 'Mojo::WebService::LastFM';

requires 'Moo';                 # OO Framework
requires 'strictures~2';        # Enables strict and warnings with specific settings
requires 'Mojo::IOLoop';        # Simple event loop for persistent websocket connection
requires 'Config::Tiny';        # For reading config.ini
requires 'Data::Dumper';        # For debugging complex objects
requires 'namespace::clean';    # Removes declared and imported symbols from your compiled package
