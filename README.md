# Discord Now Playing

This is a simple script that leverages [Net::Discord](https://github.com/vsTerminus/Net-Discord) and [Net::Async::LastFM](https://github.com/vsTerminus/Net-Async-LastFM) to fill your Discord "Playing" status with Now Playing info from your Last.FM account instead!

Copy or rename config.ini.example to config.ini and then follow the instructions inside to fill it in.
Then run the script when you're done.

You'll need to manually install both my [Net::Discord](https://github.com/vsTerminus/Net-Discord) and [Net::Async::LastFM](https://github.com/vsTerminus/Net-Async-LastFM) modules for this to run.
For me it was as simple as making symlinks to the Async and Net-Discord directories in ~/perl5/lib/perl5/Net/

    - ln -s /path/to/Net-Async-LastFM/lib/Net/Async ~/perl5/lib/perl5/Net/Async
    - ln -s /path/to/Net-Discord/lib/Net/Discord ~/perl5/lib/perl5/Net/Discord
    - ln -s /path/to/Net-Discord/lib/Net/Discord.pm ~/perl5/lib/perl5/Net/Discord.pm

If you don't have a user lib you'll need to do this into your system perl lib directory as root instead.

As for installing the other dependencies, simply running "cpanm --installdeps ." from this project's root folder should cover everything you need.
That command will work on Linux and Windows. On Linux you'll need to install the "cpanminus" package first. 
On Windows, it depends which distribution of Perl you are using. I recommend Strawberry Perl, which comes with cpanminus built in.
