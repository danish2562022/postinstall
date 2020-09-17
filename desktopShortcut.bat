@echo off
REM ************************************************************ 
REM  This batch script is called from postinstall.bat
REM  It adds a Desktop Icon by creating a registry entry.
REM ************************************************************ 

for /F "usebackq tokens=*" %%r IN (`%MSI_CMD% -q "Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "Desktop" HKEY_CURRENT_USER`) DO (
	set DESK_PATH=%%r
)


%WINDIR%\REGEDIT /E %TEMP%\reg1.txt "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
FOR /F "tokens=1,2 delims==" %%A IN ('TYPE %TEMP%\reg1.txt ^| %WINDIR%\SYSTEM32\FIND "Programs"') DO (
if  %%A == "Common Programs" set COMMON_PROG_PATH=%%~B
)
erase %TEMP%\reg1.txt


%WINDIR%\REGEDIT /E %TEMP%\reg2.txt "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
FOR /F "tokens=1,2 delims==" %%A IN ('TYPE %TEMP%\reg2.txt ^| %WINDIR%\SYSTEM32\FIND "Programs"') DO (
if  %%A == "Programs" set USER_PROG_PATH=%%~B
)
erase %TEMP%\reg2.txt


rem echo %USER_PROG_PATH:~6%
rem echo %COMMON_PROG_PATH:~6%
rem echo %DESK_PATH:~6%


if exist "%COMMON_PROG_PATH%\%MC_PROGRAM_FOLDER%\%MC_PROGRAM_NAME%.lnk" (
	%MSI_CMD% -c "%COMMON_PROG_PATH%\%MC_PROGRAM_FOLDER%\%MC_PROGRAM_NAME%.lnk" "%DESK_PATH:~6%\%MC_PROGRAM_FOLDER%.lnk"
) else (
	%MSI_CMD% -c "%USER_PROG_PATH%\%MC_PROGRAM_FOLDER%\%MC_PROGRAM_NAME%.lnk" "%DESK_PATH:~6%\%MC_PROGRAM_FOLDER%.lnk"
)
