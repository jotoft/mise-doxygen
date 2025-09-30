# mise-doxygen

[Doxygen](https://www.doxygen.nl/) plugin for [mise](https://mise.jdx.dev/).

This plugin builds doxygen from source, allowing you to install any version available from the [official GitHub releases](https://github.com/doxygen/doxygen/releases).

## Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Usage](#usage)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Dependencies

**All Operating Systems:**

- `bash`, `curl`, `tar`: Generic POSIX utilities
- `cmake`: Build system generator
- `make`: Build automation tool
- `gcc` or `clang`: C/C++ compiler
- `flex`: Fast lexical analyzer generator (required by doxygen)
- `bison`: Parser generator (required by doxygen)

**Arch Linux:**
```bash
sudo pacman -S base-devel cmake flex bison
```

**Ubuntu/Debian:**
```bash
sudo apt-get install build-essential cmake flex bison
```

**macOS:**
```bash
brew install cmake flex bison
```

> **Note:** macOS ships with an old version of bison (2.3) that doesn't meet doxygen's requirements (≥2.7). The plugin automatically detects and uses the Homebrew-installed versions of bison and flex if available.

## Install

### Using mise

```bash
# Install the plugin
mise plugin install doxygen https://github.com/jotoft/mise-doxygen.git

# Show all installable versions
mise ls-remote doxygen

# Install specific version
mise install doxygen@1.13.0

# Set a version globally
mise use -g doxygen@1.13.0

# Or add to mise.toml
echo '[tools]
doxygen = "1.13.0"' >> mise.toml
```

Check [mise](https://mise.jdx.dev/) documentation for more information.

## Usage

Once installed, doxygen will be available in your PATH:

```bash
doxygen --version
```

To generate documentation for a project:

```bash
# Generate a default Doxyfile configuration
doxygen -g

# Run doxygen with the configuration
doxygen Doxyfile
```

## Development

This repository includes a `.mise.toml` file with tasks for plugin development and testing.

### Plugin Structure

```
mise-doxygen/
├── metadata.lua          # Plugin metadata
├── hooks/               # Hook functions
│   ├── available.lua    # List available versions
│   ├── pre_install.lua  # Provide download URL
│   ├── post_install.lua # Compile from source
│   └── env_keys.lua     # Set up PATH
├── lib/                 # Helper libraries
│   └── helper.lua       # Platform detection and utilities
└── .mise.toml          # Development tasks
```

### Available Tasks

```bash
# Test listing versions
mise run test-list

# Test installation locally
mise run test-install

# Uninstall test version
mise run test-cleanup
```

### Testing Locally

To test the plugin locally before pushing:

```bash
# Clone the repository
git clone https://github.com/jotoft/mise-doxygen.git
cd mise-doxygen

# Link the plugin for testing
mise plugin link doxygen .

# Test listing versions
mise ls-remote doxygen

# Test installation
mise install doxygen@1.13.0

# Test execution
doxygen --version
```

## Implementation Notes

This plugin uses mise's tool plugin architecture with Lua hooks:

- **Available Hook**: Fetches version list from GitHub API
- **PreInstall Hook**: Provides download URL for source tarball
- **PostInstall Hook**: Compiles doxygen using cmake and make
- **EnvKeys Hook**: Adds the bin directory to PATH

The plugin handles platform-specific requirements:
- On macOS, it automatically uses Homebrew's bison and flex
- Parallel compilation based on available CPU cores
- Compiler-specific flags for compatibility

## Related Projects

- [asdf-doxygen](https://github.com/jotoft/asdf-doxygen) - ASDF plugin for doxygen (also compatible with mise via ASDF backend)
- [doxygen](https://github.com/doxygen/doxygen) - Official doxygen repository

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See [LICENSE](LICENSE)
