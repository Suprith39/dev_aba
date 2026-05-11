@REM Maven wrapper script for Windows
@REM Downloads Maven 3.9.x automatically on first run — no local install needed.

@echo off
setlocal

set MAVEN_PROJECTBASEDIR=%~dp0
set MAVEN_WRAPPER_PROPERTIES=%MAVEN_PROJECTBASEDIR%.mvn\wrapper\maven-wrapper.properties

@REM Parse distributionUrl
for /f "tokens=2 delims==" %%a in ('findstr "^distributionUrl" "%MAVEN_WRAPPER_PROPERTIES%"') do set DISTRIBUTION_URL=%%a

@REM Resolve cache directory
if defined MAVEN_USER_HOME (set USER_HOME=%MAVEN_USER_HOME%) else (set USER_HOME=%USERPROFILE%\.m2\wrapper)
for %%f in ("%DISTRIBUTION_URL%") do set MAVEN_ZIP_NAME=%%~nxf
set MAVEN_HOME=%USER_HOME%\dists\%MAVEN_ZIP_NAME:.zip=%

@REM Download and unpack if not already cached
if not exist "%MAVEN_HOME%" (
    if not exist "%USER_HOME%\dists" mkdir "%USER_HOME%\dists"
    echo Downloading Maven: %DISTRIBUTION_URL%
    powershell -Command "Invoke-WebRequest -Uri '%DISTRIBUTION_URL%' -OutFile '%USER_HOME%\dists\%MAVEN_ZIP_NAME%'"
    powershell -Command "Expand-Archive -Path '%USER_HOME%\dists\%MAVEN_ZIP_NAME%' -DestinationPath '%USER_HOME%\dists' -Force"
)

"%MAVEN_HOME%\bin\mvn.cmd" %*
