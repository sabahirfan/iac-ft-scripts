#!/bin/bash

# Function to show usage
show_usage() {
    cat << EOF
Usage: ./clone.sh [OPTIONS]

Clone repositories using iTerm2 or Terminal.app

Options:
    -c, --config <file>     JSON config file path (optional, default: repos-config.json)
    -p, --path <dir>        Base directory for cloning (optional, default: ../iac-ft)
    -t, --type <type>       Repository type to process (gradle|yarn|none|all) (default: all)
    -h, --help             Show this help message

Examples:
    # Clone all repositories to default path (.../iac-ft)
    ./clone.sh

    # Clone gradle repositories to specific path
    ./clone.sh -p ~/projects/repositories -t gradle
EOF
    exit 1
}

# Function to check if application is running
is_app_running() {
    osascript -e "tell application \"System Events\" to (name of processes) contains \"$1\""
}

# Function to create and normalize path
setup_path() {
    local base_path="$1"
    
    # Convert relative path to absolute
    if [[ "$base_path" != /* ]]; then
        base_path="$(pwd)/$base_path"
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$base_path"
    
    # Return normalized absolute path
    echo "$(cd "$base_path" && pwd)"
}

# Function to execute commands in iTerm
create_iterm_tab() {
    local repo_url="$1"
    local repo_name="$2"
    local base_path="$3"
    
    osascript - <<EOF
tell application "iTerm2"
    tell current window
        create tab with default profile
        tell current session
            write text "cd '$base_path' && echo 'Cloning $repo_url' && git clone '$repo_url' && echo 'Clone completed for $repo_name'"
        end tell
    end tell
end tell
EOF
}

# Function to execute commands in Terminal.app
create_terminal_tab() {
    local repo_url="$1"
    local repo_name="$2"
    local base_path="$3"
    
    osascript - <<EOF
tell application "Terminal"
    tell application "System Events" to keystroke "t" using command down
    delay 0.5
    do script "cd '$base_path' && echo 'Cloning $repo_url' && git clone '$repo_url' && echo 'Clone completed for $repo_name'" in selected tab of the front window
end tell
EOF
}

# Function to process repositories
process_repositories() {
    local config_file="$1"
    local repo_type="$2"
    local base_path="$3"
    local terminal_type="$4"

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed. Install with: brew install jq"
        exit 1
    fi

    # Process repositories based on type
    if [ "$repo_type" = "all" ]; then
        types=("gradle" "yarn" "none")
    else
        types=("$repo_type")
    fi

    echo "Using base path: $base_path"

    for type in "${types[@]}"; do
        echo "Processing $type repositories..."
        repos=$(jq -r ".$type[]" "$config_file")
        
        while IFS= read -r repo_url; do
            [ -z "$repo_url" ] && continue
            
            repo_name=$(basename "$repo_url" .git)
            
            if [ "$terminal_type" = "iterm" ]; then
                create_iterm_tab "$repo_url" "$repo_name" "$base_path"
            else
                create_terminal_tab "$repo_url" "$repo_name" "$base_path"
            fi
            
            sleep 0.5
        done <<< "$repos"
    done
}

# Main script
main() {
    # Default values
    config_file="repos-config.json"
    repo_type="all"
    base_path="../iac-ft"  # Default to parallel directory

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                config_file="$2"
                shift 2
                ;;
            -p|--path)
                base_path="$2"
                shift 2
                ;;
            -t|--type)
                repo_type="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                ;;
        esac
    done

    # Check if running on macOS
    if [ "$(uname)" != "Darwin" ]; then
        echo "This script is designed for macOS only."
        exit 1
    fi

    # Check if config file exists
    if [ ! -f "$config_file" ]; then
        echo "Error: Config file '$config_file' not found!"
        exit 1
    fi

    # Setup and normalize base path
    base_path=$(setup_path "$base_path")

    # Determine which terminal to use
    if is_app_running "iTerm2"; then
        echo "Using iTerm2..."
        terminal_type="iterm"
    else
        echo "Using Terminal.app..."
        terminal_type="terminal"
        # Ensure Terminal.app is running
        open -a Terminal
        sleep 1
    fi

    # Process repositories
    process_repositories "$config_file" "$repo_type" "$base_path" "$terminal_type"

    echo "All cloning processes have been initiated."
}

# Show usage only if help is requested
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_usage
fi

# Run the main function with all arguments
main "$@" 