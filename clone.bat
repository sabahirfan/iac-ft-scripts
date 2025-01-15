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
echo Usage: clone.bat [OPTIONS]
echo.
echo Clone repositories using Windows Command Prompt
echo.
echo Options:
echo     -c, --config ^<file^>     JSON config file path (optional, default: repos-config.json)
echo     -p, --path ^<dir^>        Base directory for cloning (optional, default: ..\iac-ft)
echo     -t, --type ^<type^>       Repository type to process (gradle^|yarn^|none^|all) (default: all)
echo     -h, --help              Show this help message
echo.
echo Examples:
echo     # Clone all repositories to default path (..\iac-ft)
echo     clone.bat
echo.
echo     # Clone gradle repositories to specific path
echo     clone.bat -p C:\projects\repositories -t gradle
exit /b 1

:check_git
where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: git is required but not installed.
    exit /b 1
)
goto :eof

:setup_path
:: Convert relative path to absolute and create if doesn't exist
pushd "%~dp0"
if not exist "%BASE_PATH%" mkdir "%BASE_PATH%"
cd /d "%BASE_PATH%"
set "BASE_PATH=%CD%"
popd
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
    set "TYPES=gradle yarn none"
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
            
            :: Start new window for cloning
            start "Cloning !REPO_NAME!" cmd /c "cd /d "%BASE_PATH%" && echo Cloning %%r && git clone %%r && echo Clone completed for !REPO_NAME! && timeout /t 5"
            
            :: Small delay between starts
            timeout /t 1 >nul
        )
    )
)
goto :eof

:main
:: Check if git is installed
call :check_git
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Check if config file exists
if not exist "%CONFIG%" (
    echo Error: Config file '%CONFIG%' not found!
    exit /b 1
)

:: Setup base path
call :setup_path

:: Process repositories
call :process_repositories

echo All cloning processes have been initiated.
exit /b 0 