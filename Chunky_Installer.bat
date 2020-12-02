@echo off
setlocal enabledelayedexpansion

REM Chunky Installation script v0.0.1 2020-12-02 18:27
REM https://www.dostips.com/forum/viewtopic.php?f=3&t=6581

cd /d %~dp0
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
set jdk11=0

call :get_chunkylauncher
call :java_check
call :arch_check
call :jfx_check 
REM call :create_bat

echo.  
echo ~~~
echo Chunky should now be fully setup and ready to use.
echo To launch Chunky in future, please run ChunkyLauncher.bat
echo or create a shortcut to ChunkyLauncher.bat 
echo.  
echo END
echo ~~~
echo.  

REM ChunkyLauncher.bat

PAUSE

EXIT /B %ERRORLEVEL%



REM ### ### ### ###

:get_chunkylauncher
	echo get_chunkylauncher
	REM Get ChunkyLauncher.jar if missing
	if not exist ChunkyLauncher.jar (
		powershell -Command "Invoke-WebRequest https://chunkyupdate.lemaik.de/ChunkyLauncher.jar -OutFile ChunkyLauncher.jar"
	)	
	EXIT /B 0

:java_check
	echo java_check
	REM Get Java if missing
	java -version 1>nul 2>nul || (
	   echo Java not installed or is missing.
	   call :java_install
	)
	EXIT /B 0

:arch_check
	echo arch_check
	type nul>nul
	echo OS arch = %OS%
	java -version
	java -version 2>&1 | find "64-Bit" >nul:
	rem debug- cmd/c exit 1
	if errorlevel 1 (
		echo ErrorLevel 1
	) else (
		ECHO 64BIT Java and OS detected
		goto skip
	)
	
	if %OS%==32BIT (
		echo 32BIT Java and OS detected (max 1.5GB allocation)
	) else (
		echo WARNING - 32BIT Java on 64BIT OS
		call :java_uninstall
		call :java_install
	)
	
	:skip
	call :is_jdk11
	EXIT /B 0

:is_jdk11
	echo is_jdk11
	for /f tokens^=2-5^ delims^=.-_^" %%j in ('java -fullversion 2^>^&1') do set "jver1=%%j"
	if %jver1% GEQ 11 (
		set jdk11=1
	)
	echo jdk=%jver1%
	EXIT /B 0

:java_uninstall
	echo java_uninstall
	echo.  
	echo Please find and remove Java / JDK and then rerun this script.
	echo.  
	appwiz.cpl
	
	PAUSE
	EXIT 0

:java_install
	echo java_install /nocommand

	if %OS%==32BIT (
		ECHO 32BIT Download - Change Architecture to x86
		start "" https://adoptopenjdk.net/releases.html
	) else (
		ECHO 64BIT Download
		start "" https://adoptopenjdk.net/
	)
	echo.  
	echo After installing a 64 bit Java / JDK, please rerun this script.
	echo.  
	
	PAUSE
	exit 0

:jfx_check
	echo jfx_check
	
	call :create_bat
	if %jdk11%==1 (
		call :jfx11_install
		start "jdk11+" ChunkyLauncher.bat
	) else (
		start "jdk8" ChunkyLauncher.bat
		PING localhost -n 3 >NUL
		
		if not exist log.txt (
			echo log.txt is missing... Did ChunkyLauncher.bat even start?
			pause		
		)

		2>nul ( >>log.txt (call ) ) && (
			echo unlocked - ie error coded %errorlevel%

			findstr /m "java.lang.NoClassDefFoundError: javafx/stage/Stage" log.txt
			if errorlevel 0 (
				echo "JavaFX is missing. Either download OpenJDK11+JavaFX or, if you wish to use OpenJDK8, checkout Zulu which comes with JavaFX."
				start "" "https://www.azul.com/downloads/zulu-community/?version=java-8-lts&os=windows&package=jdk-fx"
				pause
				exit 0
			) else (
				echo An unknown error has occured. Please upload log.txt.
				pause
			)
		) || (
			echo locked - is running %errorlevel%
			echo JavaFX seems to be installed or an error has occured.
			echo Please upload log.txt if the ChunkyLauncher or First time setup is not running.
		)
	)
	EXIT /B 0	

:jfx8_install
	REM removed.
	EXIT /B 0
	
:jfx11_install
	echo jfx11_install
	powershell -Command "Invoke-WebRequest https://gluonhq.com/download/javafx-11-0-2-sdk-windows/ -OutFile openjfx.zip"
	echo extracting
	powershell Expand-Archive openjfx.zip
	PAUSE
	EXIT /B 0

:create_bat
	echo create_bat
	if %jdk11%==0 (
		call :jdk8_bat
	)
	if %jdk11%==1 (
		call :jdk11_bat
	)
	EXIT /B 0
	
:jdk8_bat
	echo jdk8_bat
	@echo @echo off > ChunkyLauncher.bat
	@echo cd /d %%~dp0 >> ChunkyLauncher.bat
	@echo java -jar ChunkyLauncher.jar --launcher ^> log.txt 2^>^&1 >> ChunkyLauncher.bat
	REM @echo pause >> ChunkyLauncher.bat
	EXIT /B 0

:jdk11_bat
	echo jdk11_bat
	@echo @echo off > ChunkyLauncher.bat
	@echo cd /d %%~dp0 >> ChunkyLauncher.bat
	@echo java --module-path "%%~dp0\openjfx\javafx-sdk-11.0.2\lib" --add-modules=javafx.controls,javafx.base,javafx.graphics,javafx.fxml -jar ChunkyLauncher.jar --launcher ^> log.txt 2^>^&1 >> ChunkyLauncher.bat
	REM @echo pause >> ChunkyLauncher.bat
	EXIT /B 0
