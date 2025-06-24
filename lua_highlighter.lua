-- Lua Syntax Highlighter Module
local highlighter = {}

-- Lua keywords
local keywords = {
    ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
    ["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
    ["function"] = true, ["if"] = true, ["in"] = true, ["local"] = true,
    ["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true,
    ["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
    ["while"] = true, ["goto"] = true
}

-- Built-in functions
local builtins = {
    ["print"] = true, ["type"] = true, ["tostring"] = true, ["tonumber"] = true,
    ["pairs"] = true, ["ipairs"] = true, ["next"] = true, ["require"] = true,
    ["pcall"] = true, ["xpcall"] = true, ["error"] = true, ["assert"] = true,
    ["setmetatable"] = true, ["getmetatable"] = true, ["rawget"] = true,
    ["rawset"] = true, ["rawlen"] = true, ["select"] = true, ["unpack"] = true,
    ["table"] = true, ["string"] = true, ["math"] = true, ["io"] = true,
    ["os"] = true, ["debug"] = true, ["coroutine"] = true, ["package"] = true
}

-- Color codes for TUI (using ANSI-like codes that work with Hype)
local colors = {
    keyword = "[blue]",      -- Blue for keywords
    builtin = "[magenta]",   -- Magenta for built-ins
    string = "[green]",      -- Green for strings
    comment = "[yellow]",    -- Yellow for comments
    number = "[cyan]",       -- Cyan for numbers
    operator = "[red]",      -- Red for operators
    reset = "[white]"        -- Reset to default
}

-- Function to highlight Lua code
function highlighter.highlight(code)
    local result = ""
    local i = 1
    local len = #code
    
    while i <= len do
        local char = code:sub(i, i)
        
        -- Handle comments
        if char == '-' and i < len and code:sub(i + 1, i + 1) == '-' then
            -- Single line comment
            local start = i
            while i <= len and code:sub(i, i) ~= '\n' do
                i = i + 1
            end
            result = result .. colors.comment .. code:sub(start, i - 1) .. colors.reset
            if i <= len then
                result = result .. '\n'
            end
        
        -- Handle strings
        elseif char == '"' or char == "'" then
            local quote = char
            local start = i
            i = i + 1
            
            -- Find end of string, handle escapes
            while i <= len do
                local current = code:sub(i, i)
                if current == quote then
                    i = i + 1
                    break
                elseif current == '\\' and i < len then
                    i = i + 2  -- Skip escaped character
                else
                    i = i + 1
                end
            end
            
            result = result .. colors.string .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle multi-line strings
        elseif char == '[' and i < len and code:sub(i + 1, i + 1) == '[' then
            local start = i
            i = i + 2
            
            -- Find closing ]]
            while i < len do
                if code:sub(i, i + 1) == ']]' then
                    i = i + 2
                    break
                end
                i = i + 1
            end
            
            result = result .. colors.string .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle numbers
        elseif char:match('%d') then
            local start = i
            
            -- Integer part
            while i <= len and code:sub(i, i):match('%d') do
                i = i + 1
            end
            
            -- Decimal part
            if i <= len and code:sub(i, i) == '.' then
                i = i + 1
                while i <= len and code:sub(i, i):match('%d') do
                    i = i + 1
                end
            end
            
            -- Scientific notation
            if i <= len and (code:sub(i, i) == 'e' or code:sub(i, i) == 'E') then
                i = i + 1
                if i <= len and (code:sub(i, i) == '+' or code:sub(i, i) == '-') then
                    i = i + 1
                end
                while i <= len and code:sub(i, i):match('%d') do
                    i = i + 1
                end
            end
            
            result = result .. colors.number .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle identifiers (keywords, built-ins, variables)
        elseif char:match('[%a_]') then
            local start = i
            
            -- Read identifier
            while i <= len and code:sub(i, i):match('[%w_]') do
                i = i + 1
            end
            
            local word = code:sub(start, i - 1)
            
            if keywords[word] then
                result = result .. colors.keyword .. word .. colors.reset
            elseif builtins[word] then
                result = result .. colors.builtin .. word .. colors.reset
            else
                result = result .. word
            end
        
        -- Handle operators
        elseif char:match('[%+%-%*/%%^#=<>~]') then
            local start = i
            
            -- Handle multi-character operators
            if i < len then
                local two_char = code:sub(i, i + 1)
                if two_char == '==' or two_char == '~=' or two_char == '<=' or 
                   two_char == '>=' or two_char == '..' or two_char == '<<' or 
                   two_char == '>>' or two_char == '//' then
                    i = i + 2
                else
                    i = i + 1
                end
            else
                i = i + 1
            end
            
            result = result .. colors.operator .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle everything else (whitespace, punctuation)
        else
            result = result .. char
            i = i + 1
        end
    end
    
    return result
end

return highlighter