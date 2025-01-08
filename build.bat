@echo off
setlocal enabledelayedexpansion

:: Default values
set "CONFIG=repos-config.json"
set "BASE_PATH=..\iac-ft"
set "REPO_TYPE=all"

:: Parse command line arguments
:parse_args
if "%~1"=="" goto :main
if /i "%~1"=="-c" set "CONFIG=%~2" & shift & shift & goto :parse_args
if /i "%~1"=="--config" set "CONFIG=%~2" & shift & shift & goto :parse_args
if /i "%~1"=="-p" set "BASE_PATH=%~2" & shift & shift & goto :parse_args
if /i "%~1"=="--path" set "BASE_PATH=%~2" & shift & shift & goto :parse_args
if /i "%~1"=="-t" set "REPO_TYPE=%~2" & shift & shift & goto :parse_args
if /i "%~1"=="--type" set "REPO_TYPE=%~2" & shift & shift & goto :parse_args
if /i "%~1"=="-h" goto :show_usage
if /i "%~1"=="--help" goto :show_usage
shift
goto :parse_args

:show_usage
echo Usage: build.bat [OPTIONS]
echo.
echo Build HMCTS repositories using Windows Command Prompt
echo.
echo Options:
echo     -c, --config ^<file^>     JSON config file path (optional, default: repos-config.json)
echo     -p, --path ^<dir^>        Base directory containing repositories (optional, default: ..\iac-ft)
echo     -t, --type ^<type^>       Repository type to process (gradle^|yarn^|all) (default: all)
echo     -h, --help              Show this help message
echo.
echo Examples:
echo     # Build all repositories in default path (..\iac-ft)
echo     build.bat
echo.
echo     # Build gradle repositories in specific path
echo     build.bat -p C:\projects\hmcts -t gradle
exit /b 1

:check_repo_exists
set "REPO_PATH=%BASE_PATH%\%~1"
if not exist "%REPO_PATH%" (
    echo Skipping %~1 - repository not found in %BASE_PATH%
    exit /b 1
)
exit /b 0

:start_build_process
set "REPO_NAME=%~1"
set "BUILD_TYPE=%~2"

:: Determine build command based on type
if /i "%BUILD_TYPE%"=="gradle" (
    set "BUILD_CMD=.\gradlew.bat clean build"
) else if /i "%BUILD_TYPE%"=="yarn" (
    set "BUILD_CMD=yarn install"
) else (
    echo Unknown build type: %BUILD_TYPE%
    exit /b 1
)

:: Start new window for building
start "Building %REPO_NAME%" cmd /c "cd /d "%BASE_PATH%\%REPO_NAME%" && echo Building %REPO_NAME% && %BUILD_CMD% && echo Build completed for %REPO_NAME% && timeout /t 5"
timeout /t 1 >nul
goto :eof

:process_repositories
:: Check if jq is available (required for JSON parsing)
where jq >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: jq is required but not installed. Download from: https://stedolan.github.io/jq/download/
    exit /b 1
)

:: Process repositories based on type
if /i "%REPO_TYPE%"=="all" (
    set "TYPES=gradle yarn"
) else (
    set "TYPES=%REPO_TYPE%"
)

echo Using base path: %BASE_PATH%

for %%t in (%TYPES%) do (
    echo Processing %%t repositories...
    
    :: Use jq to extract repositories of current type
    for /f "tokens=* usebackq" %%r in (`jq -r ".%%t[]" "%CONFIG%"`) do (
        if not "%%r"=="" if not "%%r"=="null" (
            :: Extract repo name from URL
            for %%a in ("%%r") do set "REPO_NAME=%%~na"
            
            :: Check if repository exists
            call :check_repo_exists "!REPO_NAME!"
            if !ERRORLEVEL! equ 0 (
                call :start_build_process "!REPO_NAME!" "%%t"
            )
        )
    )
)
goto :eof

:main
:: Convert relative path to absolute
pushd "%~dp0"
if not exist "%BASE_PATH%" (
    echo Error: Base path '%BASE_PATH%' not found!
    exit /b 1
)
cd /d "%BASE_PATH%"
set "BASE_PATH=%CD%"
popd

:: Check if config file exists
if not exist "%CONFIG%" (
    echo Error: Config file '%CONFIG%' not found!
    exit /b 1
)

:: Process repositories
call :process_repositories

echo All build processes have been initiated.
exit /b 0 