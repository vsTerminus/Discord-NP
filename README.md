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



## Run from Source

If you want to contribute to the code or just prefer to run the raw perl script instead of my packaged executable, you can do that too.

### Linux, MacOS

#### Install and Configure Perl + cpanminus

**Install Perl**
You should already have Perl. If you don't, you need at least v5.10 -- Install it with your package manager.
On MacOS I recommend installing perl from Homebrew instead of system perl. It's probably not necessary for this particular project, but I recommend it in general.

**Install cpanminus**
cpanminus is an excellent tool for managing CPAN modules. Simpler and more powerful than the included CPAN shell. You may be able to install this through your package manager or you can install it with the `cpan install cpanminus` command. If you go the second route you'll have to go through the CPAN setup, which just asks you a number of questions you can (probably) just hit "Enter" and accept the defaults for every single one.

**Configure cpanminus**
Perl can install modules to the system for all users (which requires sudo) or it can install to your home directory (a "local" lib(rary)) for your user alone. This doesn't require elevated permissions and is generally preferred. But you do need to set up a couple things:

1. Set up your local lib

You should add the following to either `~/.bash_profile` or `~/.zprofile` (or if you are using a shell other than bash or zsh, in that shell's profile file). Remember to replace "username" with your own username. Use your favorite text editor.

```bash
PERL_MB_OPT='--install_base /home/username/perl5'; export PERL_MB_OPT;
PERL_MM_OPT='INSTALL_BASE=/home/username/perl5'; export PERL_MM_OPT;
PERL5LIB="/home/username/perl5/lib/perl5"; export PERL5LIB;
PATH="/home/username/perl5/bin:$PATH"; export PATH;
PERL_LOCAL_LIB_ROOT="/home/usename/perl5:$PERL_LOCAL_LIB_ROOT"; export PERL_LOCAL_LIB_ROOT;
```

Now either restart your terminal or re-source your profile (eg `source ~/.zprofile`)

2. Configure cpanminus

You should be able to just run 

```bash
cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
```

If you try to install something with cpanm it will complain and prompt you to do this anyway. 

Now anything you install with cpanminus will go to the local lib in ~/perl5 instead of to a system directory.

**Install Discord::NP**

```bash
# Clone the repository
git clone https://github.com/vsTerminus/Discord-NP.git

# Enter the project directory
cd Discord-NP
```

In the root directory of this project you should see a file called "cpanfile" which contains a list of this project's dependencies. You can point cpanminus at it to install them:

```bash
cpanm --installdeps .
```

This will install everything except for one library: 

**Install Mojo::Discord**

[Mojo::Discord](https://github.com/vsTerminus/Mojo-Discord) is the library required for this application to connect to Discord in the first place. It will go up on CPAN eventually and then you'll be able to install it with cpanm, but it needs more unit tests and documentation first. So for now you'll have to install it manually.

Luckily it's not too difficult:

```bash
# Check out the repository
git clone https://github.com/vsTerminus/Mojo-Discord.git

# Enter the project directory
cd Mojo-Discord

# Install Mojo-Discord's dependencies
cpanm --installdeps .

# Manually install Mojo::Discord by creating symlinks inside your local lib
# This way you can update it just by running "git pull" in the future.
ln -s $PWD/Mojo-Discord/lib/Mojo/Discord.pm $PERL5LIB/Mojo/
ln -s $PWD/Mojo-Discord/lib/Mojo/Discord $PERL5LIB/Mojo/
```

To validate that both modules are installed, 

```bash
perl -MMojo::Discord -MMojo::WebService::LastFM -e 1
```

If you don't see any errors then you got it right. Congrats!

**Configure the App**

Create a copy of the example config file named "config.ini"

```bash
cp config.ini.example config.ini
```

Use your favorite text editor to fill it out as you saw in the first section of this readme.

**Run the App**

Should be as simple as

```bash
perl discordnp.pl
```

from inside the Discord::NP project folder. 


### Windows

I recommend installing [Strawberry Perl](http://strawberryperl.com/), as it comes with cpanminus already installed.

You need to check out two repositories

- [Discord::NP](https://github.com/vsTerminus/Discord-NP) (This one!)
- [Mojo::Discord](https://github.com/vsTerminus/Mojo-Discord) (For connecting to Discord)

Clone each one using git

```cmd
git clone https://github.com/vsTerminus/Discord-NP.git
git clone https://github.com/vsTerminus/Mojo-Discord.git
```

Enter each folder and install the dependencies

```cmd
cd Mojo-Discord
cpanm --installdeps .
cd ../Discord-NP
cpanm --installdeps .
```

Next grab a copy of the "Mojo" folder (inside /lib) and drop it into `C:\Strawberry\perl\lib\` and choose Yes when it asks you if you would like to merge with the existing Net folder.

Finally, make a copy of config.ini.example in the Discord-NP project folder and rename it to "config.ini". Fill it out as normal.

To run it, `perl discordnp.pl`

That's it! Have fun.

## Build From Source

The build process is virtually identical for Mac, Windows, and Linux.

You will need two things: 'make' and 'pp'

'pp' is a utility provided by PAR::Packer, a perl module which you can install using cpanminus like so:

```bash
cpanm pp
```

'make' is something you should install with your package manager. On macOS you can use brew, on Windows I recommend using [Chocolatey](https://chocolatey.org/). (Once installed you run `choco install make` in an admin terminal and that's it)

Before you build, make sure you have a valid config.ini file in the project root *as well as in the 'build' folder*, I'll address that in a future update. The build process has to run the script to find dependencies, so having a valid config.ini is important.

Finally, run

```bash
make
```

and you should see it write the discordnp-OSTYPE file into the 'build' directory.

# Troubleshooting

Please, if you are having trouble open a ticket on the Issues tab. Let me know what's going on or what isn't clear so I can update it.

You can also reach me on my discord, https://discord.gg/FuKTcHF

I make no promises as to availability or time frames, but I will try to help you if I can.
