param (
    [string]$Config = "repos-config.json",
    [string]$Path = "..\iac-ft",
    [string]$Type = "all",
    [switch]$Help
)

# Function to show usage
function Show-Usage {
    Write-Host @"
Usage: .\clone.ps1 [OPTIONS]

Clone repositories using Windows Command Prompt

Options:
    -Config <file>     JSON config file path (optional, default: repos-config.json)
    -Path <dir>        Base directory for cloning (optional, default: ..\iac-ft)
    -Type <type>       Repository type to process (gradle|yarn|none|all) (default: all)
    -Help              Show this help message

Examples:
    # Clone all repositories to default path (..\iac-ft)
    .\clone.ps1

    # Clone gradle repositories to specific path
    .\clone.ps1 -Path C:\projects\repositories -Type gradle
"@
    exit 1
}

# Function to create and normalize path
function Setup-Path {
    param([string]$BasePath)
    
    # Convert relative path to absolute
    $BasePath = [System.IO.Path]::GetFullPath($BasePath)
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $BasePath)) {
        New-Item -ItemType Directory -Path $BasePath | Out-Null
    }
    
    return $BasePath
}

# Function to create new command window for cloning
function Start-CloneProcess {
    param(
        [string]$RepoUrl,
        [string]$RepoName,
        [string]$BasePath
    )
    
    $command = "cd '$BasePath' && echo 'Cloning $RepoUrl' && git clone '$RepoUrl' && echo 'Clone completed for $RepoName' && timeout /t 5"
    Start-Process cmd.exe -ArgumentList "/c $command"
}

# Function to process repositories
function Process-Repositories {
    param(
        [string]$ConfigFile,
        [string]$RepoType,
        [string]$BasePath
    )

    # Check if required tools are installed
    if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-Host "Error: git is required but not installed."
        exit 1
    }

    # Process repositories based on type
    $types = @()
    if ($RepoType -eq "all") {
        $types = @("gradle", "yarn", "none")
    }
    else {
        $types = @($RepoType)
    }

    Write-Host "Using base path: $BasePath"

    # Read and parse JSON file
    $config = Get-Content $ConfigFile | ConvertFrom-Json

    foreach ($type in $types) {
        Write-Host "Processing $type repositories..."
        $repos = $config.$type
        
        foreach ($repoUrl in $repos) {
            if ([string]::IsNullOrWhiteSpace($repoUrl)) { continue }
            
            $repoName = [System.IO.Path]::GetFileNameWithoutExtension($repoUrl)
            Start-CloneProcess -RepoUrl $repoUrl -RepoName $repoName -BasePath $BasePath
            Start-Sleep -Seconds 1
        }
    }
}

# Main script
function Main {
    if ($Help) {
        Show-Usage
        return
    }

    # Check if config file exists
    if (-not (Test-Path $Config)) {
        Write-Host "Error: Config file '$Config' not found!"
        exit 1
    }

    # Setup and normalize base path
    $BasePath = Setup-Path $Path

    # Process repositories
    Process-Repositories -ConfigFile $Config -RepoType $Type -BasePath $BasePath

    Write-Host "All cloning processes have been initiated."
}

# Run the main function
Main 