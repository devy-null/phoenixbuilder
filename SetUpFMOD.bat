pushd C:\\
git clone https://vcs.firestormviewer.org/3p-libraries/3p-fmodstudio C:\\3p-fmodstudio
bash -c "sed -i 's/\r$//' 3p-fmodstudio/build-cmd.sh"

C:\\GetFMOD.py %1

cd 3p-fmodstudio
set AUTOBUILD_CONFIG_FILE=autobuild.xml
autobuild build -p windows64 --all
autobuild package -p windows64 > build.log

findstr /r "^wrote" build.log > wrote
findstr /r "^md5" build.log > md5

set /P wrote=<wrote
set /P md5=<md5

set wrote=%wrote:wrote=%
set wrote=%wrote: =%

set md5=%md5:md5=%
set md5=%md5: =%

cd ..\phoenix-firestorm
cp autobuild.xml my_autobuild.xml
set AUTOBUILD_CONFIG_FILE=my_autobuild.xml
autobuild installables edit fmodstudio platform=windows64 hash=%md5% url=file:///%wrote%
popd