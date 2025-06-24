-- Markdown Syntax Highlighter Module
local highlighter = {}

-- Color codes for TUI (using ANSI-like codes that work with Hype)
local colors = {
    header = "[blue]",       -- Blue for headers
    bold = "[red]",          -- Red for bold text
    italic = "[yellow]",     -- Yellow for italic text
    code = "[green]",        -- Green for code
    link = "[cyan]",         -- Cyan for links
    quote = "[magenta]",     -- Magenta for blockquotes
    list = "[blue]",         -- Blue for list markers
    reset = "[white]"        -- Reset to default
}

-- Function to highlight markdown code
function highlighter.highlight(content)
    local lines = {}
    for line in content:gmatch("[^\r\n]*") do
        table.insert(lines, line)
    end
    
    local result = ""
    local in_code_block = false
    local code_fence = nil
    
    for i, line in ipairs(lines) do
        local highlighted_line = line
        
        -- Check for code fences
        if line:match("^```") then
            if not in_code_block then
                in_code_block = true
                code_fence = line:match("^```(.*)$")
                highlighted_line = colors.code .. line .. colors.reset
            else
                in_code_block = false
                code_fence = nil
                highlighted_line = colors.code .. line .. colors.reset
            end
        elseif in_code_block then
            -- Inside code block - just color as code
            highlighted_line = colors.code .. line .. colors.reset
        else
            -- Not in code block - apply markdown highlighting
            
            -- Headers (# ## ### etc.)
            if line:match("^#+%s") then
                local level = #line:match("^#+")
                highlighted_line = colors.header .. line .. colors.reset
            
            -- Blockquotes (> )
            elseif line:match("^>%s") then
                highlighted_line = colors.quote .. line .. colors.reset
            
            -- Unordered lists (- * +)
            elseif line:match("^%s*[%-%*%+]%s") then
                local indent, marker, rest = line:match("^(%s*)([%-%*%+])(%s.*)$")
                highlighted_line = indent .. colors.list .. marker .. colors.reset .. rest
            
            -- Ordered lists (1. 2. etc.)
            elseif line:match("^%s*%d+%.%s") then
                local indent, number, rest = line:match("^(%s*)(%d+%.)(%s.*)$")
                highlighted_line = indent .. colors.list .. number .. colors.reset .. rest
            
            -- Horizontal rules (--- or ***)
            elseif line:match("^%s*[%-%*_][%-%*_%s]*$") and #line:gsub("%s", "") >= 3 then
                highlighted_line = colors.header .. line .. colors.reset
            
            else
                -- Inline formatting
                highlighted_line = highlightInline(line)
            end
        end
        
        result = result .. highlighted_line
        if i < #lines then
            result = result .. "\n"
        end
    end
    
    return result
end

-- Function to highlight inline markdown elements
function highlightInline(line)
    local result = ""
    local i = 1
    local len = #line
    
    while i <= len do
        local char = line:sub(i, i)
        
        -- Inline code (`code`)
        if char == '`' then
            local start = i
            i = i + 1
            
            -- Find closing backtick
            while i <= len and line:sub(i, i) ~= '`' do
                i = i + 1
            end
            
            if i <= len then
                result = result .. colors.code .. line:sub(start, i) .. colors.reset
                i = i + 1
            else
                result = result .. char
                i = start + 1
            end
        
        -- Bold (**text** or __text__)
        elseif (char == '*' and i < len and line:sub(i + 1, i + 1) == '*') or
               (char == '_' and i < len and line:sub(i + 1, i + 1) == '_') then
            local marker = char
            local start = i
            i = i + 2
            
            -- Find closing marker
            local found = false
            while i < len do
                if line:sub(i, i + 1) == marker .. marker then
                    result = result .. colors.bold .. line:sub(start, i + 1) .. colors.reset
                    i = i + 2
                    found = true
                    break
                end
                i = i + 1
            end
            
            if not found then
                result = result .. line:sub(start, start + 1)
                i = start + 2
            end
        
        -- Italic (*text* or _text_)
        elseif char == '*' or char == '_' then
            local marker = char
            local start = i
            i = i + 1
            
            -- Find closing marker
            local found = false
            while i <= len do
                if line:sub(i, i) == marker then
                    result = result .. colors.italic .. line:sub(start, i) .. colors.reset
                    i = i + 1
                    found = true
                    break
                end
                i = i + 1
            end
            
            if not found then
                result = result .. char
                i = start + 1
            end
        
        -- Links [text](url) or [text][ref]
        elseif char == '[' then
            local start = i
            i = i + 1
            local bracket_count = 1
            
            -- Find closing bracket
            while i <= len and bracket_count > 0 do
                local current = line:sub(i, i)
                if current == '[' then
                    bracket_count = bracket_count + 1
                elseif current == ']' then
                    bracket_count = bracket_count - 1
                end
                i = i + 1
            end
            
            if bracket_count == 0 then
                -- Check if followed by (url) or [ref]
                if i <= len and (line:sub(i, i) == '(' or line:sub(i, i) == '[') then
                    local link_start = i
                    local close_char = line:sub(i, i) == '(' and ')' or ']'
                    i = i + 1
                    
                    while i <= len and line:sub(i, i) ~= close_char do
                        i = i + 1
                    end
                    
                    if i <= len then
                        result = result .. colors.link .. line:sub(start, i) .. colors.reset
                        i = i + 1
                    else
                        result = result .. line:sub(start, link_start - 1)
                        i = link_start
                    end
                else
                    result = result .. line:sub(start, i - 1)
                end
            else
                result = result .. char
                i = start + 1
            end
        
        -- Everything else
        else
            result = result .. char
            i = i + 1
        end
    end
    
    return result
end

return highlighter