# Based on https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019

FROM mcr.microsoft.com/windows:20H2

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

RUN mkdir C:\\TEMP

RUN powershell -Command "Invoke-WebRequest -OutFile C:\\TEMP\\cmake.msi https://github.com/Kitware/CMake/releases/download/v3.8.0/cmake-3.8.0-win64-x64.msi" && \
C:\\TEMP\\cmake.msi /qn /norestart && \
setx path "%path%;C:\Program Files\cmake\bin"

# The newest version of cygwin had problems with symlinks, so use an old one
RUN powershell -Command "Invoke-WebRequest -OutFile C:\\TEMP\\cygwin.exe https://cygwin.com/setup-x86_64.exe" && \
C:\\TEMP\\cygwin.exe --quiet-mode --local-package-dir C:\\cygwinlocalpackagedir --disable-buggy-antivirus --root C:\\cygwin --packages patch -X --site http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/64bit/2020/05/31/142136/ && \
setx path "%path%;C:\cygwin\bin"

RUN powershell -Command "Invoke-WebRequest -OutFile C:\\TEMP\\python.msi https://www.python.org/ftp/python/2.7.17/python-2.7.17.msi" && \
C:\\TEMP\\python.msi /qn /norestart && \
setx path "%path%;C:\Python27;C:\Python27\Scripts"

RUN powershell -Command "Invoke-WebRequest -OutFile C:\\TEMP\\Git-2.26.2-64-bit.exe https://github.com/git-for-windows/git/releases/download/v2.26.2.windows.1/Git-2.26.2-64-bit.exe" && \
C:\\TEMP\\Git-2.26.2-64-bit.exe /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="help,plugins" 

RUN pip install git+https://vcs.firestormviewer.org/autobuild-1.1#egg=autobuild && \
pip install requests

RUN git clone https://vcs.firestormviewer.org/fs-build-variables C:\\fs-build-variables && \
setx AUTOBUILD_VARIABLES_FILE "C:\\fs-build-variables\variables"

# From https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019

RUN powershell -Command "Invoke-WebRequest -OutFile C:\TEMP\vs_buildtools.exe https://aka.ms/vs/15/release/vs_buildtools.exe" && \
start /wait C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache \
    --installPath C:\BuildTools \
    --add Microsoft.VisualStudio.Workload.VCTools \
	--includeRecommended \
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

RUN setx AUTOBUILD_VSVER "150"

COPY GetFMOD.py C:\\GetFMOD.py
COPY SetUpFMOD.bat C:\\SetUpFMOD.bat

ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
# ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]