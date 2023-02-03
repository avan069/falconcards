@ECHO OFF
set arg1=%1
if "%arg1%" == "" (echo [33mNo filename passed, using 7982.dds[0m) else (echo [33mOperating on:[0m %1) 
ECHO "%arg1%"
REM /// Get BASEDIR and PILOTBIN from Registry.
REM /// Note: This part will need to be updated in future versions of BMS.
REM /// delims is a TAB followed by a space
FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY "HKLM\SOFTWARE\WOW6432Node\Benchmark Sims\Falcon BMS 4.37" /v baseDir') DO SET BASEDIR=%%B
ECHO BASEDIR=%BASEDIR%

FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY "HKLM\SOFTWARE\WOW6432Node\Benchmark Sims\Falcon BMS 4.37" /v PilotCallsign') DO SET PILOTBIN=%%B
ECHO PILOTBIN=%PILOTBIN%

FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY "HKLM\SOFTWARE\WOW6432Node\Benchmark Sims\Falcon BMS 4.37" /v curTheater') DO SET THEATER=%%B
ECHO THEATER=%THEATER%

REM /// Convert the REG_BINARY callsign from Registry to a string
SETLOCAL EnableDelayedExpansion
ECHO !PILOTBIN!> temp.hex
CALL certutil -decodehex temp.hex str.txt >nul
ENDLOCAL
SET /p PILOTCALLSIGN=<str.txt
( DEL temp.hex & DEL str.txt )>nul

ECHO PILOTCALLSIGN=%PILOTCALLSIGN%

SET BRIEFINGTXT="%BASEDIR%\User\Briefings\briefing.txt"
ECHO BRIEFINGTXT=%BRIEFINGTXT%
SET CALLSIGNINI="%BASEDIR%\User\Config\%PILOTCALLSIGN%.ini"
ECHO CALLSIGNINI=%CALLSIGNINI%

REM /// Kneeboards textures are in files 7982.dds and following.
REM /// One file holds a left+right double page for the kneeboards.

SET TARGETFILE="TEST"
if "%arg1%" == "" (SET TARGETFILE=7982.dds) else (SET TARGETFILE=%arg1%)

REM /// Path to theater dds files. Default to Korea KTO.
SET THEATERPATH=%BASEDIR%\Data\TerrData\Objects\KoreaObj

REM /// Looks into the Theaters.txt and tries to match %THEATER% with one on the list,
REM /// Then returns the partial path of the objects folder containing the .dss files.
FOR /F "usebackq tokens=1-2 delims=," %%G IN (Theaters.txt) DO IF %%G == "%THEATER%" SET THEATERPATH=%BASEDIR%%%H

SET TARGET="%THEATERPATH%\%TARGETFILE%"
ECHO TARGET=%TARGET%
IF NOT EXIST %TARGET% (
  ECHO [91mTarget file doesn't exist. Check theater.[0m
  GOTO ERROR
)


ECHO Converting the briefing.png image file to a DDS texture file.
rem dir
rem a dir here proves that the default operating directory is Documents... not sure how to get a bat file to operate in it's own directory?
bin\texconv.exe -f DXT1 -m 1 -y -srgb -h 2048 -w 2048 briefing.PNG
ECHO [33mReady to copy for use in %THEATER%:[0m %TARGET%
ECHO [33mPress any key to continue with copy, or ESC to cancel copy.[0m
PAUSE >nul

IF NOT EXIST briefing.DDS GOTO ERROR
ECHO [32mOk.[0m

ECHO [33mMoving the result to %TARGET%.[0m
MOVE /y briefing.DDS %TARGET%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
REM ECHO [32mOk.[0m

ECHO [42m[97mSUCCESS.[0m
REM IF "%~1"=="" PAUSE
EXIT 0

:ERROR
ECHO [41m[97m### ERROR ###[0m

IF "%~1"=="" PAUSE
EXIT 1
