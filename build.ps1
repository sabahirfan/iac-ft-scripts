param (
    [string]$Config = "repos-config.json",
    [string]$Path = "..\iac-ft",
    [string]$Type = "all",
    [switch]$Help
)

# Function to show usage
function Show-Usage {
    Write-Host @"
Usage: .\build.ps1 [OPTIONS]

Build repositories using Windows Command Prompt

Options:
    -Config <file>     JSON config file path (optional, default: repos-config.json)
    -Path <dir>        Base directory containing repositories (optional, default: ..\iac-ft)
    -Type <type>       Repository type to process (gradle|yarn|all) (default: all)
    -Help              Show this help message

Examples:
    # Build all repositories in default path (..\iac-ft)
    .\build.ps1

    # Build gradle repositories in specific path
    .\build.ps1 -Path C:\projects\repositories -Type gradle
"@
    exit 1
}

# Function to check if repository exists
function Test-RepoExists {
    param(
        [string]$RepoName,
        [string]$BasePath
    )
    
    return Test-Path (Join-Path $BasePath $RepoName)
}

# Function to create new command window for building
function Start-BuildProcess {
    param(
        [string]$RepoName,
        [string]$BasePath,
        [string]$BuildType
    )
    
    $buildCmd = switch ($BuildType) {
        "gradle" { ".\gradlew.bat clean build" }
        "yarn" { "yarn install" }
    }
    
    $command = "cd '$BasePath\$RepoName' && echo 'Building $RepoName' && $buildCmd && echo 'Build completed for $RepoName' && timeout /t 5"
    Start-Process cmd.exe -ArgumentList "/c $command"
}

# Function to process repositories
function Process-Repositories {
    param(
        [string]$ConfigFile,
        [string]$RepoType,
        [string]$BasePath
    )

    # Process repositories based on type
    $types = @()
    if ($RepoType -eq "all") {
        $types = @("gradle", "yarn")
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
            
            if (-not (Test-RepoExists -RepoName $repoName -BasePath $BasePath)) {
                Write-Host "Skipping $repoName - repository not found in $BasePath"
                continue
            }
            
            Start-BuildProcess -RepoName $repoName -BasePath $BasePath -BuildType $type
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

    # Convert relative path to absolute
    $BasePath = [System.IO.Path]::GetFullPath($Path)

    # Process repositories
    Process-Repositories -ConfigFile $Config -RepoType $Type -BasePath $BasePath

    Write-Host "All build processes have been initiated."
}

# Run the main function
Main 