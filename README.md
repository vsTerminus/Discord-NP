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

You should already have Perl. If you don't, you need at least v5.10 -- Install it with your package manager.
On MacOS I recommend installing perl from Homebrew instead of system perl. It's probably not necessary for this particular project, but I recommend it in general.

Also install "cpanminus", an excellent tool for managing CPAN modules.

Most of the dependencies can be installed automatically using `cpanm`, but there are two which are still manual installations until I can get them into CPAN.
- [Mojo::Discord](https://github.com/vsTerminus/Mojo-Discord)
- [Mojo::WebService::LastFM](https://github.com/vsTerminus/Mojo-WebService-LastFM)

Once Perl and cpanminus are installed, these commands should get you going.
Make sure your PERL5LIB env variable is set and valid.

```bash
# Check out the repositories
git clone https://github.com/vsTerminus/Discord-NP.git
git clone https://github.com/vsTerminus/Mojo-Discord.git
git clone https://github.com/vsTerminus/Mojo-WebService-LastFM.git

# Create folders if needed
mkdir -p $PERL5LIB/Mojo/WebService

# Install Mojo::Discord and Mojo::WebService::LastFM
ln -s $PWD/Mojo-Discord/lib/Mojo/Discord.pm $PERL5LIB/Mojo/
ln -s $PWD/Mojo-Discord/lib/Mojo/Discord $PERL5LIB/Mojo/
ln -s $PWD/Mojo-WebService-LastFM/lib/Mojo/WebService/LastFM.pm $PERL5LIB/Mojo/WebService/LastFM.pm

# Install dependencies
cd Mojo-Discord
cpanm --installdeps .
cd ../Mojo-WebService-LastFM
cpanm --installdeps .
cd ../Discord-NP
cpanm --installdeps .

# Create your personal config file by copying the example file
cp config.ini.example config.ini
```

At this point you should be able to fill out config.ini and then run `perl discordnp.pl`

If you don't have a user lib you'll need to do this into your system perl lib directory as root instead.

### Windows

I recommend installing [Strawberry Perl](http://strawberryperl.com/), as it comes with cpanminus already installed.

You need to check out three of my repositories:

- [Discord::NP](https://github.com/vsTerminus/Discord-NP) (This one!)
- [Mojo::Discord](https://github.com/vsTerminus/Mojo-Discord) (For connecting to Discord)
- [Mojo::WebService::LastFM](https://github.com/vsTerminus/Mojo-WebService-LastFM) (For a non-blocking connection to Last.FM)

Clone each one using git

```cmd
git clone https://github.com/vsTerminus/Discord-NP.git
git clone https://github.com/vsTerminus/Mojo-Discord.git
git clone https://github.com/vsTerminus/Mojo-WebService-LastFM.git
```

Enter each folder and install the dependencies

```cmd
cd Mojo-Discord
cpanm --installdeps .
cd ../Mojo-WebService-LastFM
cpanm --installdeps .
cd ../Discord-NP
cpanm --installdeps .
```

Next take the "Mojo" folder out of each of those three projects and drop it into `C:\Strawberry\perl\lib\` and choose Yes when it asks you if you would like to merge with the existing Net folder.

Finally, make a copy of config.ini.example in the Discord-NP project folder and rename it to "config.ini". Fill it out as normal.

To run it, `perl discordnp.pl`

That's it! Have fun.

## Build From Source

### Linux, MacOS

You will need PAR::Packer, which you can install with cpanminus: `cpanm PAR::Packer`

Now enter the "build" directory and run the "build.sh" script: `sh build.sh`

If you're on Linux the script should finish and you should see a file named "discordnp-linux-gnu".
On Mac, the file will be "discordnp-darwin\*" where \* is the version number (eg "darwin19.0")

To run the file, just execute it. 

If your config.ini is in the same folder: `./discordnp-linux`

If config.ini is somewhere else: `./discordnp-linux --config=/path/to/config.ini`

### Windows

Not yet supported.
