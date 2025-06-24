# Contributing to fs-explore

Thank you for your interest in contributing to fs-explore! This document provides guidelines and information for contributors.

## How to Contribute

### Reporting Issues
- Use the GitHub issue tracker to report bugs
- Include steps to reproduce the issue
- Specify your operating system and Hype version
- Provide sample files if the issue is related to syntax highlighting

### Suggesting Features
- Open an issue with the "enhancement" label
- Describe the feature and its use case
- Consider backward compatibility

### Code Contributions

1. **Fork the repository**
   ```bash
   git fork https://github.com/yourusername/fs-explore.git
   cd fs-explore
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Test your changes thoroughly

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add: descriptive commit message"
   ```

5. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Development Guidelines

### Code Style
- Use 4 spaces for indentation
- Add comments for complex functions
- Follow Lua naming conventions (snake_case for functions and variables)
- Keep lines under 100 characters when possible

### Adding New Syntax Highlighters

1. **Create the highlighter file** (e.g., `python_highlighter.lua`)
   ```lua
   -- Python Syntax Highlighter Module
   local highlighter = {}
   
   local keywords = {
       ["def"] = true, ["class"] = true, -- etc.
   }
   
   local colors = {
       keyword = "[blue]",
       -- etc.
   }
   
   function highlighter.highlight(code)
       -- Implementation
   end
   
   return highlighter
   ```

2. **Add file detection function** in `explorer.lua`
   ```lua
   function isPythonFile(path)
       return path:match("%.py$") ~= nil
   end
   ```

3. **Include in the highlighting logic**
   ```lua
   elseif isPythonFile(path) then
       content = content .. python_highlighter.highlight(data.content)
   ```

4. **Update README.md** with the new supported file type

### Testing
- Test on multiple operating systems if possible
- Test with various file types and edge cases
- Ensure keyboard shortcuts work as expected
- Verify syntax highlighting accuracy

### Color Scheme
Maintain consistency with the existing color scheme:
- **Blue**: Keywords, headers
- **Magenta**: Built-ins, preprocessor directives
- **Green**: Strings, code blocks
- **Yellow**: Comments
- **Cyan**: Numbers, types
- **Red**: Operators, special syntax

## Project Structure

```
fs-explore/
├── explorer.lua              # Main application
├── fs.lua                    # Filesystem operations
├── *_highlighter.lua         # Syntax highlighters
├── README.md                 # Documentation
├── CONTRIBUTING.md           # This file
├── LICENSE                   # MIT License
└── .gitignore               # Git ignore rules
```

## Pull Request Guidelines

### Before Submitting
- Ensure your code follows the style guidelines
- Test thoroughly on your platform
- Update documentation if needed
- Make sure the PR has a clear description

### PR Description Template
```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Tested on [OS]
- [ ] Added/updated tests
- [ ] Verified syntax highlighting works

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

## Getting Help

- Check existing issues and documentation first
- Join discussions in GitHub issues
- Be respectful and constructive in all interactions

## Recognition

Contributors will be recognized in:
- The main README.md file
- Release notes for significant contributions
- GitHub contributor statistics

Thank you for helping make fs-explore better!