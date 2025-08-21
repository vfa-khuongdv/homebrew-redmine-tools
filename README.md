# Redmine Tools

A command-line tool for working with Redmine projects, built with Go.

## Features

- Interactive configuration setup
- Connect to Redmine API
- Manage Redmine issues
- User-friendly Vietnamese interface

## Installation

### Using Homebrew

```bash
brew tap vfa-khuongdv/redmine-tools
brew install redmine-tools
```

### From Source

```bash
go install github.com/vfa-khuongdv/redmine-tools/cmd@latest
```

## Usage

Simply run the tool and follow the interactive prompts:

```bash
redmine-tools
```

The tool will guide you through:
1. Setting up your Redmine API key
2. Configuring your Redmine domain
3. Setting project key and issue ID ranges

## Configuration

The tool stores configuration in a local config file for reuse across sessions.

## Requirements

- Go 1.25+ (for building from source)
- Access to a Redmine instance with API enabled

## License

MIT
