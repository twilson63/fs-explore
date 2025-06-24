# 📁 fs-explore

> The coolest TUI file explorer in the galaxy! 🚀

A cross-platform TUI (Text User Interface) file explorer built with Lua and the Hype framework. Navigate files with style, syntax highlighting, and vim-inspired shortcuts for maximum awesomeness!

[![GitHub release](https://img.shields.io/github/release/twilson63/fs-explore.svg)](https://github.com/twilson63/fs-explore/releases)
[![GitHub stars](https://img.shields.io/github/stars/twilson63/fs-explore.svg)](https://github.com/twilson63/fs-explore/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**🌐 [View Documentation →](https://twilson63.github.io/fs-explore)**

## ✨ Features

- 📁 **Smart Directory Navigation** - Browse directories with keyboard shortcuts and intuitive commands
- 🎨 **Beautiful Syntax Highlighting** - Support for 6+ programming languages with custom color schemes  
- 🖥️ **Cross-Platform Magic** - Works seamlessly on Windows, macOS, and Linux
- ⌨️ **Vim-Inspired Navigation** - Escape to scroll, Ctrl+L to focus, and more shortcuts
- 📄 **Intelligent File Viewing** - View text files with syntax highlighting, detect binary files
- 🚀 **Lightning Fast** - Built with Lua and Hype framework for maximum performance
- 🔧 **Command Interface** - Simple commands: navigate, open files, go home, quit

## Supported File Types

| Language   | Extensions          | Features                              |
|------------|---------------------|---------------------------------------|
| Lua        | `.lua`              | Keywords, functions, strings          |
| Markdown   | `.md`, `.markdown`  | Headers, links, code blocks          |
| Erlang     | `.erl`, `.hrl`      | Atoms, variables, macros             |
| C          | `.c`, `.h`          | Preprocessor, stdlib functions       |
| JavaScript | `.js`, `.jsx`, `.mjs` | ES6+, template literals, regex      |
| TypeScript | `.ts`, `.tsx`       | Types, decorators, interfaces       |

## 🚀 Installation

### Quick Install (Recommended)

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/twilson63/fs-explore/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/twilson63/fs-explore/main/install.ps1 | iex
```

### Alternative Installation Methods

<details>
<summary>📦 <strong>Manual Installation</strong></summary>

1. Download the latest binary for your platform from [Releases](https://github.com/twilson63/fs-explore/releases)
2. Extract the archive:
   - **Linux/macOS**: `tar -xzf fs-explore-*.tar.gz`
   - **Windows**: Extract the `.zip` file
3. Move the binary to a directory in your PATH
4. Run `fs-explore` from anywhere!

**Supported Platforms:**
- Linux (x86_64, ARM64)
- macOS (Intel, Apple Silicon)  
- Windows (x86_64, ARM64)

</details>

<details>
<summary>🛠️ <strong>Development Installation</strong></summary>

Perfect for contributing or customizing:

1. Install [Hype](https://github.com/twilson63/hype) framework
2. Clone this repository:
   ```bash
   git clone https://github.com/twilson63/fs-explore.git
   cd fs-explore
   ```
3. Run the file explorer:
   ```bash
   hype run explorer.lua
   ```

</details>

### Verify Installation

```bash
fs-explore --version  # Check if installed correctly
fs-explore            # Start exploring! 🎉
```

## 🎮 Usage

**[📖 Full Documentation](https://twilson63.github.io/fs-explore)** | **[🎥 Demo GIF](https://github.com/twilson63/fs-explore/blob/main/demo.gif)**

### Quick Start
1. Run `fs-explore` in your terminal
2. Use **Escape** to scroll through files, **Ctrl+L** to focus the command input
3. Type commands in the bottom input field and press **Enter**

### 📂 Navigation Commands
| Command | Description | Example |
|---------|-------------|---------|
| `<path>` | Navigate to directory | `/home/user`, `../`, `Documents` |
| `home` | Go to home directory | `home` |
| `quit` | Exit the application | `quit` or `exit` |

### 📄 File Operations  
| Command | Description | Example |
|---------|-------------|---------|
| `open <filename>` | View file with syntax highlighting | `open main.lua`, `open README.md` |

### ⌨️ Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| **Escape** | Focus file view for scrolling |
| **Ctrl+L** | Focus path input (and clear it) |
| **↑ ↓** | Scroll through file listings |
| **Page Up/Down** | Fast scrolling |
| **Enter** | Execute command |

## Project Structure

```
fs-explore/
├── explorer.lua              # Main application file
├── fs.lua                    # Cross-platform filesystem module
├── lua_highlighter.lua       # Lua syntax highlighter
├── markdown_highlighter.lua  # Markdown syntax highlighter
├── erlang_highlighter.lua    # Erlang syntax highlighter
├── c_highlighter.lua         # C syntax highlighter
├── javascript_highlighter.lua # JavaScript syntax highlighter
├── typescript_highlighter.lua # TypeScript syntax highlighter
└── README.md                 # This file
```

## 🎯 Examples

<details>
<summary><strong>🚀 Basic Navigation</strong></summary>

```bash
# Navigate to different directories
Path: /home/user/Documents
Path: ../
Path: code/my-project
Path: home
```

</details>

<details>
<summary><strong>📄 File Operations</strong></summary>

```bash
# View files with beautiful syntax highlighting
Path: open README.md
Path: open src/main.lua  
Path: open package.json
Path: open config.yaml
```

</details>

<details>
<summary><strong>⚡ Quick Commands</strong></summary>

```bash
Path: home    # Jump to home directory
Path: ..      # Go up one level  
Path: quit    # Exit gracefully
```

</details>

## Architecture

The application uses a vertical flex layout with two main components:
- **File View** (top): Scrollable display area with syntax highlighting
- **Path Input** (bottom): Command input with light gray background

### Key Components
- `tui.newFlex()` with column direction for vertical layout
- `tui.newTextView()` for scrollable content display
- `tui.newInputField()` for command input
- Custom syntax highlighters with TUI color codes
- Cross-platform filesystem operations using `os.execute`

## Development

### Adding New Syntax Highlighters

1. Create a new highlighter module (e.g., `python_highlighter.lua`)
2. Follow the existing pattern with color codes and keyword definitions
3. Add file extension detection function in `explorer.lua`
4. Include the highlighter in the file type checking logic

### Color Scheme
- **Blue**: Keywords, headers
- **Magenta**: Built-ins, preprocessor directives, decorators
- **Green**: Strings, code blocks, template literals
- **Yellow**: Comments, italic text
- **Cyan**: Numbers, links, types
- **Red**: Operators, atoms, bold text, regex

## 🤝 Contributing

We love contributions! Check out our [Contributing Guide](CONTRIBUTING.md) for details.

### Quick Start for Contributors

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)  
3. **Commit** your changes (`git commit -m 'feat: add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Ways to Contribute
- 🐛 **Report bugs** or suggest features
- 📝 **Improve documentation** 
- 🎨 **Add new syntax highlighters** for more languages
- ⚡ **Performance improvements**
- 🧪 **Add tests** and improve code quality

**[📋 View Open Issues](https://github.com/twilson63/fs-explore/issues)** | **[💡 Request Features](https://github.com/twilson63/fs-explore/issues/new)**

## 📋 Requirements

- **Runtime**: [Hype Framework](https://github.com/twilson63/hype) (for development)
- **System**: Lua 5.1+ (auto-managed in releases)
- **Terminal**: Any terminal with color support
- **OS**: Linux, macOS, or Windows

*Note: Pre-built binaries include all dependencies!*

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- 🚀 Built with the amazing [Hype](https://github.com/twilson63/hype) TUI framework
- 💡 Inspired by vim and other legendary terminal-based file managers  
- 🎨 Syntax highlighting patterns adapted from various language specifications
- 🤖 Created with assistance from [Claude Code](https://claude.ai/code)

---

<div align="center">

**⭐ Star this repo if you found it useful! ⭐**

**[🌐 Documentation](https://twilson63.github.io/fs-explore)** • **[📦 Releases](https://github.com/twilson63/fs-explore/releases)** • **[🐛 Issues](https://github.com/twilson63/fs-explore/issues)** • **[💡 Discussions](https://github.com/twilson63/fs-explore/discussions)**

Made with ❤️ and lots of ☕

</div>