@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Installs the Android SDK and NDK required by GEN on Windows x86_64.
rem The final paths are:
rem   ThirdPartyLibraries\android-sdk
rem   ThirdPartyLibraries\android-ndk

set "EXIT_CODE=1"
set "CHECK_ONLY=0"
set "CONFIG_FILE=%~dp0AndroidPackages.cfg"
for %%I in ("%~dp0..") do set "THIRD_PARTY_ROOT=%%~fI"
set "SDK_ROOT=%THIRD_PARTY_ROOT%\android-sdk"
set "NDK_ROOT=%THIRD_PARTY_ROOT%\android-ndk"

if /I "%~1"=="--help" goto :help
if /I "%~1"=="/?" goto :help
if /I "%~1"=="--check" set "CHECK_ONLY=1"
if not "%~1"=="" if /I not "%~1"=="--check" (
    echo ERROR: Unknown option: %~1
    goto :help_error
)

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows PowerShell is required.
    goto :cleanup
)

call :LoadConfig
if errorlevel 1 goto :cleanup

echo.
echo GEN Android environment
echo   SDK: %SDK_ROOT%
echo   NDK: %NDK_ROOT%
echo.

call :VerifySDK
if errorlevel 1 (set "SDK_READY=0") else (set "SDK_READY=1")

call :VerifyNDK
if errorlevel 1 (set "NDK_READY=0") else (set "NDK_READY=1")

if "%CHECK_ONLY%"=="1" (
    if "%SDK_READY%"=="1" if "%NDK_READY%"=="1" (
        echo.
        echo Android environment is valid.
        set "EXIT_CODE=0"
    ) else (
        echo.
        echo Android environment is incomplete or invalid.
    )
    goto :cleanup
)

if "%SDK_READY%"=="0" (
    call :InstallSDK
    if errorlevel 1 goto :cleanup
    call :VerifySDK
    if errorlevel 1 (
        echo ERROR: SDK verification failed after installation.
        goto :cleanup
    )
)

if "%NDK_READY%"=="0" (
    call :InstallNDK
    if errorlevel 1 goto :cleanup
    call :VerifyNDK
    if errorlevel 1 (
        echo ERROR: NDK verification failed after installation.
        goto :cleanup
    )
)

echo.
echo Android SDK and NDK are ready for GEN.
set "EXIT_CODE=0"
goto :cleanup

:LoadConfig
if not exist "%CONFIG_FILE%" (
    echo ERROR: Configuration file not found: %CONFIG_FILE%
    exit /b 1
)

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    set "CFG_KEY=%%A"
    set "CFG_VALUE=%%B"
    if /I "!CFG_KEY!"=="PlatformToolsMinimum" set "SDK_PLATFORM_TOOLS_MIN=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="BuildTools" set "SDK_BUILD_TOOLS=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="Platforms" set "SDK_PLATFORMS=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="CommandLineToolsArchive" set "CLT_ARCHIVE=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="CommandLineToolsUrl" set "CLT_URL=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="CommandLineToolsSHA256" set "CLT_SHA256=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="Revision" set "NDK_REVISION=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="Release" set "NDK_RELEASE=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="Archive" set "NDK_ARCHIVE=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="Url" set "NDK_URL=!CFG_VALUE!"
    if /I "!CFG_KEY!"=="SHA1" set "NDK_SHA1=!CFG_VALUE!"
)

for %%V in (SDK_PLATFORM_TOOLS_MIN SDK_BUILD_TOOLS SDK_PLATFORMS CLT_ARCHIVE CLT_URL CLT_SHA256 NDK_REVISION NDK_RELEASE NDK_ARCHIVE NDK_URL NDK_SHA1) do (
    if not defined %%V (
        echo ERROR: Missing configuration value: %%V
        exit /b 1
    )
)
exit /b 0

:VerifySDK
echo Checking Android SDK...
set "VERIFY_FAILED=0"

call :ReadProperty "%SDK_ROOT%\platform-tools\source.properties" "Pkg.Revision" SDK_ACTUAL_PLATFORM_TOOLS
if not defined SDK_ACTUAL_PLATFORM_TOOLS (
    echo   MISSING platform-tools
    set "VERIFY_FAILED=1"
) else (
    set "GEN_ACTUAL_VERSION=!SDK_ACTUAL_PLATFORM_TOOLS!"
    set "GEN_MIN_VERSION=%SDK_PLATFORM_TOOLS_MIN%"
    powershell.exe -NoLogo -NoProfile -NonInteractive -Command "try { $actual=[version]$env:GEN_ACTUAL_VERSION; $minimum=[version]$env:GEN_MIN_VERSION; if ($actual -ge $minimum) { exit 0 }; exit 1 } catch { exit 2 }" >nul 2>&1
    if errorlevel 1 (
        echo   INVALID platform-tools !SDK_ACTUAL_PLATFORM_TOOLS! ^(minimum %SDK_PLATFORM_TOOLS_MIN%^)
        set "VERIFY_FAILED=1"
    ) else (
        echo   OK platform-tools !SDK_ACTUAL_PLATFORM_TOOLS!
    )
)

for %%V in (%SDK_BUILD_TOOLS%) do (
    call :ReadProperty "%SDK_ROOT%\build-tools\%%V\source.properties" "Pkg.Revision" SDK_ACTUAL_VERSION
    if /I "!SDK_ACTUAL_VERSION!"=="%%V" (
        echo   OK build-tools;%%V
    ) else (
        echo   MISSING OR INVALID build-tools;%%V
        set "VERIFY_FAILED=1"
    )
)

for %%V in (%SDK_PLATFORMS%) do (
    call :ReadProperty "%SDK_ROOT%\platforms\android-%%V\source.properties" "AndroidVersion.ApiLevel" SDK_ACTUAL_API
    if "!SDK_ACTUAL_API!"=="%%V" (
        echo   OK platforms;android-%%V
    ) else (
        echo   MISSING OR INVALID platforms;android-%%V
        set "VERIFY_FAILED=1"
    )
)

if "%VERIFY_FAILED%"=="1" exit /b 1
exit /b 0

:VerifyNDK
echo Checking Android NDK...
call :ReadProperty "%NDK_ROOT%\source.properties" "Pkg.Revision" NDK_ACTUAL_REVISION
if /I not "!NDK_ACTUAL_REVISION!"=="%NDK_REVISION%" (
    if defined NDK_ACTUAL_REVISION (
        echo   INVALID revision !NDK_ACTUAL_REVISION! ^(required %NDK_REVISION% / %NDK_RELEASE%^)
    ) else (
        echo   MISSING revision %NDK_REVISION% / %NDK_RELEASE%
    )
    exit /b 1
)
if not exist "%NDK_ROOT%\build\cmake\android.toolchain.cmake" (
    echo   INVALID missing build\cmake\android.toolchain.cmake
    exit /b 1
)
if not exist "%NDK_ROOT%\toolchains\llvm\prebuilt\windows-x86_64\bin\clang.exe" (
    echo   INVALID missing Windows LLVM toolchain
    exit /b 1
)
echo   OK NDK %NDK_REVISION% ^(%NDK_RELEASE%^)
exit /b 0

:InstallSDK
echo.
echo Installing Android SDK packages...

if exist "%SDK_ROOT%\platform-tools.backup\source.properties" (
    echo WARNING: platform-tools.backup is inside the Android SDK.
    echo          sdkmanager will report it as a duplicate package.
    echo          Move that backup outside android-sdk when convenient.
)

if not exist "%SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat" (
    if exist "%SDK_ROOT%\cmdline-tools\latest\" (
        echo ERROR: Incomplete command-line tools directory exists:
        echo        %SDK_ROOT%\cmdline-tools\latest
        echo        Rename or remove that directory, then run this installer again.
        exit /b 1
    )
    call :InstallCommandLineTools
    if errorlevel 1 exit /b 1
)

set "SDKMANAGER=%SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat"
where java.exe >nul 2>&1
if errorlevel 1 (
    if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" set "PATH=%JAVA_HOME%\bin;%PATH%"
)
where java.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: A Java runtime is required by sdkmanager.
    echo        Install a current JDK or set JAVA_HOME, then try again.
    exit /b 1
)

if not exist "%SDK_ROOT%" mkdir "%SDK_ROOT%"

echo Accepting Android SDK licenses...
(for /L %%N in (1,1,100) do @echo y) | call "%SDKMANAGER%" --sdk_root="%SDK_ROOT%" --licenses
if errorlevel 1 (
    echo ERROR: Android SDK licenses were not accepted successfully.
    exit /b 1
)

set "SDK_PACKAGE_ARGS=platform-tools"
for %%V in (%SDK_BUILD_TOOLS%) do set "SDK_PACKAGE_ARGS=!SDK_PACKAGE_ARGS! "build-tools;%%V""
for %%V in (%SDK_PLATFORMS%) do set "SDK_PACKAGE_ARGS=!SDK_PACKAGE_ARGS! "platforms;android-%%V""

echo Installing required SDK packages...
call "%SDKMANAGER%" --sdk_root="%SDK_ROOT%" !SDK_PACKAGE_ARGS!
if errorlevel 1 (
    echo ERROR: sdkmanager failed to install the required packages.
    exit /b 1
)
exit /b 0

:InstallCommandLineTools
echo Downloading Android SDK Command-line Tools...
set "WORK_DIR=%TEMP%\GEN-Android-%RANDOM%-%RANDOM%"
set "DOWNLOAD_FILE=!WORK_DIR!\%CLT_ARCHIVE%"
set "EXTRACT_DIR=%SDK_ROOT%\cmdline-tools.installing"
mkdir "!WORK_DIR!" || exit /b 1

if not exist "%SDK_ROOT%" mkdir "%SDK_ROOT%"
if exist "!EXTRACT_DIR!\" (
    echo ERROR: A previous temporary Command-line Tools installation exists:
    echo        !EXTRACT_DIR!
    echo        Remove it manually after confirming it is not needed.
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)

call :DownloadAndVerify "%CLT_URL%" "!DOWNLOAD_FILE!" SHA256 "%CLT_SHA256%"
if errorlevel 1 (
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)

echo Extracting Command-line Tools...
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "Expand-Archive -LiteralPath $env:GEN_ARCHIVE -DestinationPath $env:GEN_EXTRACT_DIR -Force" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not extract %CLT_ARCHIVE%.
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)

if not exist "!EXTRACT_DIR!\cmdline-tools\bin\sdkmanager.bat" (
    echo ERROR: Unexpected Command-line Tools archive layout.
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)

if not exist "%SDK_ROOT%\cmdline-tools" mkdir "%SDK_ROOT%\cmdline-tools"
move "!EXTRACT_DIR!\cmdline-tools" "%SDK_ROOT%\cmdline-tools\latest" >nul
if errorlevel 1 (
    echo ERROR: Could not install Command-line Tools.
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)
rmdir "!EXTRACT_DIR!" >nul 2>&1
call :RemoveWorkDir "!WORK_DIR!"
exit /b 0

:InstallNDK
echo.
echo Installing Android NDK %NDK_REVISION% ^(%NDK_RELEASE%^) for Windows x86_64...
if exist "%NDK_ROOT%\" (
    echo ERROR: An incompatible or incomplete NDK directory already exists:
    echo        %NDK_ROOT%
    echo        Rename or remove it manually, then run this installer again.
    exit /b 1
)

set "WORK_DIR=%TEMP%\GEN-Android-%RANDOM%-%RANDOM%"
set "DOWNLOAD_FILE=!WORK_DIR!\%NDK_ARCHIVE%"
set "INSTALLING_DIR=%THIRD_PARTY_ROOT%\android-ndk.installing"
mkdir "!WORK_DIR!" || exit /b 1

if exist "!INSTALLING_DIR!\" (
    echo ERROR: A previous temporary NDK installation exists:
    echo        !INSTALLING_DIR!
    echo        Remove it manually after confirming it is not needed.
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)

call :DownloadAndVerify "%NDK_URL%" "!DOWNLOAD_FILE!" SHA1 "%NDK_SHA1%"
if errorlevel 1 (
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)

echo Extracting NDK. This can take several minutes...
set "GEN_ARCHIVE=!DOWNLOAD_FILE!"
set "GEN_EXTRACT_DIR=!INSTALLING_DIR!"
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "Expand-Archive -LiteralPath $env:GEN_ARCHIVE -DestinationPath $env:GEN_EXTRACT_DIR -Force"
if errorlevel 1 (
    echo ERROR: Could not extract %NDK_ARCHIVE%.
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)

set "EXTRACTED_NDK=!INSTALLING_DIR!\android-ndk-%NDK_RELEASE%"
call :ReadProperty "!EXTRACTED_NDK!\source.properties" "Pkg.Revision" EXTRACTED_NDK_REVISION
if /I not "!EXTRACTED_NDK_REVISION!"=="%NDK_REVISION%" (
    echo ERROR: Extracted NDK revision is invalid: !EXTRACTED_NDK_REVISION!
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)

move "!EXTRACTED_NDK!" "%NDK_ROOT%" >nul
if errorlevel 1 (
    echo ERROR: Could not move the NDK into its final location.
    call :RemoveWorkDir "!WORK_DIR!"
    exit /b 1
)
rmdir "!INSTALLING_DIR!" >nul 2>&1
call :RemoveWorkDir "!WORK_DIR!"
exit /b 0

:DownloadAndVerify
set "GEN_DOWNLOAD_URL=%~1"
set "GEN_DOWNLOAD_FILE=%~2"
set "GEN_HASH_ALGORITHM=%~3"
set "GEN_EXPECTED_HASH=%~4"
set "GEN_ARCHIVE=%~2"
set "GEN_EXTRACT_DIR=%EXTRACT_DIR%"

powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri $env:GEN_DOWNLOAD_URL -OutFile $env:GEN_DOWNLOAD_FILE"
if errorlevel 1 (
    echo ERROR: Download failed: %~1
    exit /b 1
)

for /f "usebackq delims=" %%H in (`powershell.exe -NoLogo -NoProfile -NonInteractive -Command "(Get-FileHash -LiteralPath $env:GEN_DOWNLOAD_FILE -Algorithm $env:GEN_HASH_ALGORITHM).Hash.ToLowerInvariant()"`) do set "ACTUAL_HASH=%%H"
if /I not "!ACTUAL_HASH!"=="%~4" (
    echo ERROR: Checksum mismatch for %~2
    echo        Expected: %~4
    echo        Actual:   !ACTUAL_HASH!
    exit /b 1
)
echo Checksum verified: %~3 %~4
exit /b 0

:ReadProperty
set "%~3="
if not exist "%~1" exit /b 0
set "PROPERTY_VALUE="
for /f "usebackq tokens=1,* delims==" %%A in (`findstr /b /i /c:"%~2" "%~1"`) do set "PROPERTY_VALUE=%%B"
if defined PROPERTY_VALUE for /f "tokens=*" %%V in ("!PROPERTY_VALUE!") do set "PROPERTY_VALUE=%%V"
set "%~3=!PROPERTY_VALUE!"
exit /b 0

:RemoveWorkDir
if not "%~1"=="" if exist "%~1\" rmdir /s /q "%~1"
exit /b 0

:help
echo Usage: %~nx0 [--check]
echo.
echo With no option, installs or repairs the required Android environment.
echo --check validates the existing SDK and NDK without changing anything.
set "EXIT_CODE=0"
goto :cleanup

:help_error
echo Usage: %~nx0 [--check]
set "EXIT_CODE=2"

:cleanup
exit /b %EXIT_CODE%
