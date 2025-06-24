# fs-explore

A cross-platform TUI (Text User Interface) file explorer built with Lua and the Hype framework. Features syntax highlighting for multiple programming languages and an intuitive command-based navigation system.

## Features

- 📁 **Directory Navigation** - Browse directories with keyboard shortcuts
- 🎨 **Syntax Highlighting** - Support for 6+ programming languages
- 🖥️ **Cross-Platform** - Works on Windows, macOS, and Linux
- ⌨️ **Keyboard Navigation** - Vim-inspired shortcuts and commands
- 📄 **File Viewing** - View text files with syntax highlighting
- 🔍 **Binary File Detection** - Safely handles binary files

## Supported File Types

| Language   | Extensions          | Features                              |
|------------|---------------------|---------------------------------------|
| Lua        | `.lua`              | Keywords, functions, strings          |
| Markdown   | `.md`, `.markdown`  | Headers, links, code blocks          |
| Erlang     | `.erl`, `.hrl`      | Atoms, variables, macros             |
| C          | `.c`, `.h`          | Preprocessor, stdlib functions       |
| JavaScript | `.js`, `.jsx`, `.mjs` | ES6+, template literals, regex      |
| TypeScript | `.ts`, `.tsx`       | Types, decorators, interfaces       |

## Installation

### Quick Install

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/twilson63/fs-explore/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/twilson63/fs-explore/main/install.ps1 | iex
```

### Manual Installation

1. Download the latest binary for your platform from [Releases](https://github.com/twilson63/fs-explore/releases)
2. Extract the archive
3. Move the binary to a directory in your PATH
4. Run `fs-explore`

### Development Installation

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

## Usage

### Navigation Commands
- `<path>` - Navigate to directory (e.g., `/home/user`, `../`, `Documents`)
- `home` - Go to home directory
- `quit` or `exit` - Exit the application

### File Operations
- `open <filename>` - View file contents with syntax highlighting

### Keyboard Shortcuts
- **Escape** - Focus file view for scrolling
- **Ctrl+L** - Focus path input (and clear it)
- **Arrow Keys** - Scroll through file listings (when file view is focused)
- **Page Up/Down** - Fast scrolling
- **Enter** - Execute command in path input

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

## Examples

### Basic Navigation
```
Path: /home/user/Documents
Path: ../
Path: code/my-project
```

### File Operations
```
Path: open README.md
Path: open src/main.lua
Path: open package.json
```

### Quick Commands
```
Path: home
Path: quit
```

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

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Requirements

- [Hype Framework](https://github.com/twilson63/hype)
- Lua 5.1+
- Cross-platform terminal with color support

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with the [Hype](https://github.com/twilson63/hype) TUI framework
- Inspired by vim and other terminal-based file managers
- Syntax highlighting patterns adapted from various language specifications