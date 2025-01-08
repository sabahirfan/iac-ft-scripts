# IAC-FT Local Setup Manager

A collection of scripts to help manage Immigration & Asylum Court (IAC) repositories for HMCTS. This tool allows you to easily clone and build multiple IAC repositories in parallel using either iTerm2 or Terminal.app on macOS.

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

- macOS operating system
- iTerm2 or Terminal.app
- Git
- jq (`brew install jq`)
- Gradle (for Java projects)
- Node.js and Yarn (for frontend projects)

## Installation

1. Clone this repository
2. Make the scripts executable:
   ```bash
   chmod +x clone.sh build.sh
   ```

## Usage

The functionality has been split into two separate scripts for better modularity:

### 1. Clone Script

```bash
./clone.sh [OPTIONS]
```

#### Clone Options

- `-c, --config <file>` : JSON config file path (default: repos-config.json)
- `-p, --path <dir>` : Base directory for cloning (default: ../iac-ft)
- `-t, --type <type>` : Repository type to process (gradle|yarn|none|all) (default: all)
- `-h, --help` : Show help message

### 2. Build Script

```bash
./build.sh [OPTIONS]
```

#### Build Options

- `-c, --config <file>` : JSON config file path (default: repos-config.json)
- `-p, --path <dir>` : Base directory for building (default: ../iac-ft)
- `-t, --type <type>` : Repository type to process (gradle|yarn|all) (default: all)
- `-h, --help` : Show help message

### Examples

1. Clone repositories:
    ```bash
    # Clone all repositories to default path
    ./clone.sh
    
    # Clone only Gradle repositories to a specific path
    ./clone.sh -p ~/projects/hmcts -t gradle
    ```

2. Build repositories:
    ```bash
    # Build all repositories in default path
    ./build.sh
    
    # Build only Gradle repositories in a specific path
    ./build.sh -p ~/projects/hmcts -t gradle
    ```

## Configuration

The script uses a JSON configuration file (`repos-config.json`) to manage repository URLs. Repositories are categorized by their build system:

- `gradle`: Java-based repositories that use Gradle
- `yarn`: JavaScript/Node.js repositories that use Yarn
- `none`: Infrastructure repositories with no specific build system

You can modify `repos-config.json` to add or remove repositories as needed.

## Features

- Parallel processing of repositories using terminal tabs
- Automatic detection of iTerm2 or fallback to Terminal.app
- Separate scripts for cloning and building operations
- Flexible repository type filtering
- Build script automatically skips non-existent repositories
- Configurable base directory for repository management

## Notes

- The scripts are designed exclusively for macOS due to their dependency on AppleScript for terminal manipulation
- When using iTerm2, they will automatically create new tabs for each repository
- The scripts include built-in delays to prevent overwhelming system resources
- Build commands are specific to each repository type (gradle/yarn)
- The build script will automatically check for repository existence before attempting to build
- Clone script supports 'none' type repositories, while build script only processes 'gradle' and 'yarn' types
