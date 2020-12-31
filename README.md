# phonixbuilder
A docker container for building phonix-firestorm

## About

This is for 64 bit windows, nothing else is supported (you could customize it for 32, but that is left as an exercise for the reader :p). <br>
And it is for SL and not OpenSim (but you can change that in the build command)

Normaly the normal build steps at https://wiki.firestormviewer.org/fs_compiling_firestorm_windows might work, but if you have lots of different versions of python and visual studio etc installed, it can become messy, and then this project might help out.

To note is that the docker image takes quite some space.

## Cloning
You are expected to download this to D:\phonixbuilder
```
git clone https://github.com/devy-null/phonixbuilder D:\phonixbuilder
```

If you download it to somewhere else, you have to change that path in dockerrun.bat after you cloned it

## Docker

Install [Docker](https://www.docker.com/products/docker-desktop) if not installed

The normal docker install requires Hyper-V to be enabled, and if you can't turn it on for some reason (for example if you also run VMWare) you can try the Docker EE:

To install Docker EE (works without Hyper-V)
https://www.kauffmann.nl/2019/03/04/how-to-install-docker-on-windows-10-without-hyper-v/
* InstallDockerEE.ps1 is a modified version of above, works without IE

## Download the firestorm project

```
git clone https://vcs.firestormviewer.org/phoenix-firestorm D:\phoenix-firestorm
```

If you place it somewhere else, update the path in dockerrun.bat

## Building

Run dockerbuild.bat

## Running

Run dockerrun.bat

Do check that the paths inside are correct in case you have put stuff in other places.

## Getting FMOD (used for sounds)

Inside the container

Run "SetUpFMOD.bat" or <br>
Run "SetUpFMOD.bat 2.01.02" (where 2.01.02 is the version that we want)

Create a new account if you don't have one: https://www.fmod.com/profile/register <br>
Enter credentials when prompted (they could also be put inside D:\config\fmodauth.json, as `{ "username": "<username>", "password": "<password>" }`)

## Building the project

Inside the container

```
cd C:\\phoenix-firestorm <br>
set AUTOBUILD_CONFIG_FILE=my_autobuild.xml
```

Replace the "Private-&lt;your-build-name-here&gt;" with a name for your build, like "Private-My-First-Build"

```
autobuild build -A 64 -c ReleaseFS_open -- --fmodstudio --package --no-opensim --avx2 --chan Private-&lt;your-build-name-here&gt; -DLL_TESTS:BOOL=FALSE -DCMAKE_CXX_FLAGS="/EHsc /utf-8"
```

Commit the docker image, else you will have to rerun the above steps each time you start the container

Then when you have done some changes, build the project again

The output can be found in D:\phoenix-firestorm\build-vc150-64\newview\Release

## Final words

Steps can break, you might want other configurations etc <br>
But with this project you can probably figure out how to make the adjustments you need

Also look at https://wiki.firestormviewer.org/fs_compiling_firestorm_windows for more details
