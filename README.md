# IAC-FT Local Setup Manager

A collection of scripts to help manage Immigration & Asylum Court (IAC) repositories for HMCTS. This tool allows you to easily clone and build multiple IAC repositories in parallel using either iTerm2 or Terminal.app on macOS, or Command Prompt on Windows.

## Supported Repositories

### Gradle Projects
- ia-case-api
- ia-case-documents-api
- ia-case-notifications-api
- ia-home-office-integration-api
- ia-timed-event-service
- ia-case-access-api
- ia-bail-case-api
- ia-hearings-api
- ia-case-payments-api

### Yarn Projects
- ia-aip-frontend

### Infrastructure/Docker Projects
- ia-docker
- ia-shared-infrastructure

## Prerequisites

### For macOS
- macOS operating system
- iTerm2 or Terminal.app
- Git
- jq (`brew install jq`)
- Gradle (for Java projects)
- Node.js and Yarn (for frontend projects)

### For Windows
- Windows operating system
- Command Prompt or PowerShell
- Git (download from https://git-scm.com/download/win)
- jq (download from https://stedolan.github.io/jq/download/)
- Gradle (for Java projects)
- Node.js and Yarn (for frontend projects)

## Installation

### macOS
1. Clone this repository
2. Make the scripts executable:
   ```bash
   chmod +x clone.sh build.sh
   ```

### Windows
1. Clone this repository
2. No additional setup required - use the `.bat` files directly

## Usage

The functionality has been split into two separate scripts for better modularity:

### 1. Clone Script

#### macOS
```bash
./clone.sh [OPTIONS]
```

#### Windows
```batch
clone.bat [OPTIONS]
```

#### Clone Options

- `-c, --config <file>` : JSON config file path (default: repos-config.json)
- `-p, --path <dir>` : Base directory for cloning (default: ../iac-ft)
- `-t, --type <type>` : Repository type to process (gradle|yarn|none|all) (default: all)
- `-h, --help` : Show help message

### 2. Build Script

#### macOS
```bash
./build.sh [OPTIONS]
```

#### Windows
```batch
build.bat [OPTIONS]
```

#### Build Options

- `-c, --config <file>` : JSON config file path (default: repos-config.json)
- `-p, --path <dir>` : Base directory for building (default: ../iac-ft)
- `-t, --type <type>` : Repository type to process (gradle|yarn|all) (default: all)
- `-h, --help` : Show help message

### Examples

1. Clone repositories:
    ```bash
    # macOS: Clone all repositories to default path
    ./clone.sh
    
    # macOS: Clone only Gradle repositories to a specific path
    ./clone.sh -p ~/projects/hmcts -t gradle

    # Windows: Clone all repositories to default path
    clone.bat

    # Windows: Clone only Gradle repositories to a specific path
    clone.bat -p C:\projects\hmcts -t gradle
    ```

2. Build repositories:
    ```bash
    # macOS: Build all repositories in default path
    ./build.sh
    
    # macOS: Build only Gradle repositories in a specific path
    ./build.sh -p ~/projects/hmcts -t gradle

    # Windows: Build all repositories in default path
    build.bat

    # Windows: Build only Gradle repositories in a specific path
    build.bat -p C:\projects\hmcts -t gradle
    ```

## Configuration

The script uses a JSON configuration file (`repos-config.json`) to manage repository URLs. Repositories are categorized by their build system:

- `gradle`: Java-based repositories that use Gradle
- `yarn`: JavaScript/Node.js repositories that use Yarn
- `none`: Infrastructure repositories with no specific build system

You can modify `repos-config.json` to add or remove repositories as needed.

## Features

- Parallel processing of repositories using terminal tabs (macOS) or separate windows (Windows)
- Automatic detection of iTerm2 or fallback to Terminal.app on macOS
- Windows support using native Command Prompt
- Separate scripts for cloning and building operations
- Flexible repository type filtering
- Build script automatically skips non-existent repositories
- Configurable base directory for repository management

## Notes

### macOS
- The bash scripts are designed for macOS due to their dependency on AppleScript for terminal manipulation
- When using iTerm2, they will automatically create new tabs for each repository
- The scripts include built-in delays to prevent overwhelming system resources

### Windows
- The batch scripts create separate Command Prompt windows for each repository
- Windows scripts use `jq` for JSON parsing, ensure it's installed and in your PATH
- Use Windows-style paths with backslashes (e.g., `C:\projects\hmcts`)
- The scripts include built-in delays to prevent overwhelming system resources
- Build commands automatically use `gradlew.bat` for Gradle projects on Windows

Common Notes:
- Build commands are specific to each repository type (gradle/yarn)
- The build script will automatically check for repository existence before attempting to build
- Clone script supports 'none' type repositories, while build script only processes 'gradle' and 'yarn' types
