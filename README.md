# Discord Now Playing

This script will update your Discord "Listening to" status with whatever you are listening to according to Last.FM

![Discord Screenshot](/img/sidebar-big.png)

Setup will take a few minutes and requires two main things:

## **1. Last.FM API Key**

Head over to the [Last.FM API Page](https://www.last.fm/api/account/create) and sign in with your existing Last.FM username and password. It should bring you to the **Create API account** page and ask you for a few things.

It doesn't really matter what you put in most of the fields, but it should probably look something like this:

![LastFM Create API Account Screenshot](/img/create-account.png)

After clicking Submit you should get a confirmation page with two items: *API Key* and *Shared Secret*. The API Key is the only one you need for this, but I recommend you save both for future use just in case, as they don't actually provide a way to retrieve these later.

![LastFM API Account Created Screenshot](/img/account-created.png)

Copy and paste the API Key value into the config file in the `api_key = xxx` line

## **2. Discord User Token**

For this one you'll need to use the Desktop or Web app - it will not work on mobile.

WARNING: Anyone who knows your Discord token has **FULL ACCESS** to your account. Do not share it with anyone!
You *should* read this application's source code for yourself and make sure you trust it before inputting your token.

If you still want to proceed, head over to https://discordhelp.net/discord-token and follow the instructions there. 

## When you're done

Save your config file as "*config.ini*" and it should look something like this:

![Finished Config File](/img/config.png)

Now just run the executable. It should connect to Discord and immediately start setting your "*Playing*" status to whatever you're listening to on Last.FM

If it's working, it will look something like this:

![Running Executable](/img/running.png)



## Build from Source

If you want to contribute to the code or just prefer to run the raw perl script instead of my packaged executable, you can do that too.

### Linux, MacOS

You should already have Perl. If you don't, you need at least v5.10 -- Install it with your package manager.
On MacOS I recommend installing perl from Homebrew instead of system perl. It's probably not necessary for this particular project, but I recommend it in general.

Also install "cpanminus", an excellent tool for managing CPAN modules.

Next, run `cpanminus --installdeps .` (the . is important) in the Discord-NP directory and it should automatically install everything you need, with the exception of my two other modules from here on Github, which you will have to install manually.

- [Mojo::Discord](https://github.com/vsTerminus/Net-Discord) (For connecting to Discord)
- [Mojo::WebService::LastFM](https://github.com/vsTerminus/Net-Async-LastFM) (For a non-blocking connection to Last.FM)

For me it was as simple as making symlinks to the module directories in ~/perl5/lib/perl5/Net/

    - ln -s /path/to/Mojo-WebService-LastFM/lib/Mojo/WebService ~/perl5/lib/perl5/Mojo/WebService
    - ln -s /path/to/Mojo-Discord/lib/Mojo/Discord ~/perl5/lib/perl5/Mojo/Discord
    - ln -s /path/to/Mojo-Discord/lib/Mojo/Discord.pm ~/perl5/lib/perl5/Mojo/Discord.pm

If you don't have a user lib you'll need to do this into your system perl lib directory as root instead.

### Windows

I recommend installing [Strawberry Perl](http://strawberryperl.com/), as it comes with cpanminus already installed.

From here, the instructions are very similar to Linux:

In the Discord-NP directory, open a CMD window and run the  `cpanminus --installdeps .` command (Note the period, it is important. Some users have also reported that `cpanminus installdeps` without the -- and . works better for them.)

That should install all dependencies except for two, which you can get from my Github page and will need to install manually:

- [Mojo::Discord](https://github.com/vsTerminus/Mojo-Discord) (For connecting to Discord)
- [Mojo::WebService::LastFM](https://github.com/vsTerminus/Mojo-WebService-LastFM) (For a non-blocking connection to Last.FM)

Take the "Mojo" folder out of each and drop it into `C:\Strawberry\perl\lib\` and choose Yes when it asks you if you would like to merge with the existing Net folder.

That's it! Have fun.
