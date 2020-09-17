REM @echo off
REM if "%MG_INSTALL_DEBUG%"=="1" echo on 
REM ************************************************************ 
REM  This batch script uses the msi_cmd.exe to add StartMenu icons.
REM  It then asks 2 questions:
REM    1) Do you want a desktop shortcut?
REM    2) Do you want ModelSim/QuestaSim added to your PATH?
REM ************************************************************ 


REM Exit the bat file if the needed parameters are not passed.
if "%1"=="" goto end
if "%~2"=="" goto end

REM Parse the parameters passed by the MMSI install to the post_install_script.
:GetParams

IF "%1"=="" GOTO Continue

IF "%1"=="-target"       set TARGET=%~2
IF "%1"=="-msicmd"       set MSI_CMD=%~2
IF "%1"=="-mgchome"      set MGC_HOME=%~2
IF "%1"=="-vco"          set VCO=%~2
IF "%1"=="-codethread"   set MC_PROGRAM_CODETHREAD=%~2
IF "%1"=="-productname"  set MC_PROGRAM_NAME=%~2
IF "%1"=="-product_type" set MC_PROGRAM_TYPE=%~2
IF "%1"=="-version"      set MC_PROGRAM_VERSION=%~2
IF "%1"=="-redist"       set MC_VC_REDIST=%~2
IF "%1"=="-redist_opts"  set MC_VC_REDIST_OPTS=%~2

REM Move to the next argument
SHIFT
SHIFT

GOTO GetParams


:Continue

REM Adjust product name
IF "%MC_PROGRAM_NAME%"=="questa_sim"        set MC_PROGRAM_NAME=Questa Sim

REM Set product name prefix (Modelsim, Questa, ...)
set MC_PROGRAM_NAME_PREFIX=%MC_PROGRAM_NAME%
IF "%MC_PROGRAM_NAME%"=="Questa Sim"       set MC_PROGRAM_NAME_PREFIX=Questa

REM Set product name postfix (SE, PE, Sim, ...)
set MC_PROGRAM_NAME_POSTFIX=%MC_PROGRAM_TYPE%
IF "%MC_PROGRAM_TYPE%"=="QS"    set MC_PROGRAM_NAME_POSTFIX=Sim
IF "%MC_PROGRAM_TYPE%"=="QS-64" set MC_PROGRAM_NAME_POSTFIX=Sim-64
IF "%MC_PROGRAM_TYPE%"=="QU"    set MC_PROGRAM_NAME_POSTFIX=Sim
IF "%MC_PROGRAM_TYPE%"=="QU-64" set MC_PROGRAM_NAME_POSTFIX=Sim-64

REM Set folder name where the 'Start' menu entries are located
set MC_PROGRAM_FOLDER=%MC_PROGRAM_NAME_PREFIX% %MC_PROGRAM_NAME_POSTFIX% %MC_PROGRAM_VERSION%

REM Set sub-folder name where the executables are located
set MC_PROGRAM_SUBFOLDER=win32
IF "%MC_PROGRAM_TYPE%"=="PE"    set MC_PROGRAM_SUBFOLDER=win32pe
IF "%MC_PROGRAM_TYPE%"=="DE"    set MC_PROGRAM_SUBFOLDER=win32pe
IF "%MC_PROGRAM_TYPE%"=="DE-64" set MC_PROGRAM_SUBFOLDER=win64pe
IF "%MC_PROGRAM_TYPE%"=="QS-64" set MC_PROGRAM_SUBFOLDER=win64
IF "%MC_PROGRAM_TYPE%"=="QU-64" set MC_PROGRAM_SUBFOLDER=win64
IF "%MC_PROGRAM_TYPE%"=="SE-64" set MC_PROGRAM_SUBFOLDER=win64

REM Set simulator executable name
set MC_PROGRAM_COMMAND=modelsim
IF "%MC_PROGRAM_NAME%"=="Questa Sim" set MC_PROGRAM_COMMAND=questasim


REM **************************
REM *** Start the real work...

REM Create Start menu entry for 'Help & Manuals'
"%MSI_CMD%" -a "%MC_PROGRAM_FOLDER%" "Help & Manuals" "%TARGET%\docs\infohubs\index.html" "" "" "" 0 "" TRUE

REM Skip creating 'Verification Run Manager' Star menu entry for inapplicable products
IF "%MC_PROGRAM_SUBFOLDER%"=="win32pe"         GOTO TEMP3
IF "%MC_PROGRAM_SUBFOLDER%"=="win64pe"         GOTO TEMP3

REM Create Start menu entry for 'Verification Run Manager'
"%MSI_CMD%" -a "%MC_PROGRAM_FOLDER%" "Verification Run Manager" "%TARGET%\%MC_PROGRAM_SUBFOLDER%\vrun.exe" "-gui" "%TARGET%\examples" "%TARGET%\%MC_PROGRAM_SUBFOLDER%\vrun.exe" 0 "" TRUE

:TEMP3
REM Create Start menu entry for the simulator (ex: 'Questa Sim')
"%MSI_CMD%" -a "%MC_PROGRAM_FOLDER%" "%MC_PROGRAM_NAME%" "%TARGET%\%MC_PROGRAM_SUBFOLDER%\%MC_PROGRAM_COMMAND%.exe" "" "%TARGET%\examples" "%TARGET%\%MC_PROGRAM_SUBFOLDER%\%MC_PROGRAM_COMMAND%.exe" 0 "" TRUE
REM Create Start menu entry for 'Release Notes'
"%MSI_CMD%" -a "%MC_PROGRAM_FOLDER%" "Release Notes" "%TARGET%\RELEASE_NOTES.html" "" "" "" 0 "" TRUE

REM *****  COMMANDS BELOW WILL BE SKIPPED in batch mode   ********
IF "%MG_INSTALL_MODE%"=="batch" GOTO Batch

"%MSI_CMD%" -tk_showDialog "" "" "basic_templates/outputDialog.html" "messageIcon=Question.gif" ".header=%MC_PROGRAM_NAME% Desktop Shortcut" "messagePrompt=Would you like a shortcut to %MC_PROGRAM_NAME% placed on your desktop?" ".btnSet=24"
call "%MSI_CMD%\..\tk_getCmdResult.bat"
if %TK_CMD_RESULT%==8 call "%TARGET%\desktopShortcut.bat"
	
"%MSI_CMD%" -tk_showDialog "" "" "basic_templates/outputDialog.html" "messageIcon=Question.gif" ".header=Add %MC_PROGRAM_NAME% To Path" "messagePrompt=Would you like the %MC_PROGRAM_NAME% executable directory added to your path?<br>This is useful for running batch compiles and simulations from DOS boxes." ".btnSet=24"
call "%MSI_CMD%\..\tk_getCmdResult.bat"
REM *** For SYSTEM PATH use: if %TK_CMD_RESULT%==8 "%MSI_CMD%" -env Path "%TARGET%\%MC_PROGRAM_SUBFOLDER%" A
if %TK_CMD_RESULT%==8 "%MSI_CMD%" -s Environment path REGDB_STRING_EXPAND "%TARGET%\%MC_PROGRAM_SUBFOLDER%" HKEY_CURRENT_USER A

START /WAIT "%MC_PROGRAM_NAME%" "%TARGET%\%MC_VC_REDIST%" "%MC_VC_REDIST_OPTS%"
DEL /F "%TARGET%\%MC_VC_REDIST%"

REM *****  END OF SKIPPED COMMANDS in batch mode  *******
GOTO :EOF
:Batch
REM  ***** Commands below will be executed in batch mode ONLY   *******

call "%TARGET%\desktopShortcut.bat"


DEL /F "%TARGET%\desktopShortcut.bat"
DEL /F "%TARGET%\postinstall.bat"


