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
2. Make the script executable:
   ```bash
   chmod +x clone-and-build.sh
   ```

## Usage

```bash
./clone-and-build.sh [OPTIONS]
```

### Options

- `-c, --config <file>` : JSON config file path (default: repos-config.json)
- `-p, --path <dir>` : Base directory for cloning/building (default: ../iac-ft)
- `-t, --type <type>` : Repository type to process (gradle|yarn|none|all) (default: all)
- `-b, --build` : Enable build after cloning (default: clone only)
- `--build-only` : Only build existing repositories (no cloning)
- `-h, --help` : Show help message

### Examples

1. Clone all repositories to default path:
   ```bash
   ./clone-and-build.sh
   ```

2. Clone and build only Gradle repositories to a specific path:
   ```bash
   ./clone-and-build.sh -p ~/projects/hmcts -t gradle -b
   ```

3. Build existing Yarn repositories in default location:
   ```bash
   ./clone-and-build.sh -t yarn --build-only
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
- Support for both cloning and building operations
- Flexible repository type filtering
- Build-only mode for existing repositories
- Configurable base directory for repository management

## Notes

- The script is designed exclusively for macOS due to its dependency on AppleScript for terminal manipulation
- When using iTerm2, it will automatically create new tabs for each repository
- The script includes built-in delays to prevent overwhelming system resources
- Build commands are specific to each repository type (gradle/yarn)
