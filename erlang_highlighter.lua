-- Erlang Syntax Highlighter Module
local highlighter = {}

-- Erlang keywords
local keywords = {
    ["after"] = true, ["and"] = true, ["andalso"] = true, ["band"] = true,
    ["begin"] = true, ["bnot"] = true, ["bor"] = true, ["bsl"] = true,
    ["bsr"] = true, ["bxor"] = true, ["case"] = true, ["catch"] = true,
    ["cond"] = true, ["div"] = true, ["end"] = true, ["fun"] = true,
    ["if"] = true, ["let"] = true, ["not"] = true, ["of"] = true,
    ["or"] = true, ["orelse"] = true, ["receive"] = true, ["rem"] = true,
    ["try"] = true, ["when"] = true, ["xor"] = true, ["query"] = true,
    ["spec"] = true, ["type"] = true, ["export"] = true, ["import"] = true,
    ["module"] = true, ["record"] = true, ["include"] = true, ["define"] = true,
    ["ifdef"] = true, ["ifndef"] = true, ["else"] = true, ["endif"] = true,
    ["undef"] = true, ["include_lib"] = true
}

-- Built-in functions and modules
local builtins = {
    ["spawn"] = true, ["spawn_link"] = true, ["spawn_monitor"] = true,
    ["self"] = true, ["exit"] = true, ["throw"] = true, ["error"] = true,
    ["apply"] = true, ["length"] = true, ["hd"] = true, ["tl"] = true,
    ["element"] = true, ["setelement"] = true, ["tuple_size"] = true,
    ["size"] = true, ["byte_size"] = true, ["bit_size"] = true,
    ["binary_to_list"] = true, ["list_to_binary"] = true, ["atom_to_list"] = true,
    ["list_to_atom"] = true, ["integer_to_list"] = true, ["list_to_integer"] = true,
    ["float_to_list"] = true, ["list_to_float"] = true, ["term_to_binary"] = true,
    ["binary_to_term"] = true, ["process_flag"] = true, ["register"] = true,
    ["unregister"] = true, ["whereis"] = true, ["send"] = true, ["node"] = true,
    ["nodes"] = true, ["monitor"] = true, ["demonitor"] = true, ["link"] = true,
    ["unlink"] = true, ["erlang"] = true, ["lists"] = true, ["gen_server"] = true,
    ["gen_statem"] = true, ["supervisor"] = true, ["application"] = true,
    ["io"] = true, ["file"] = true, ["ets"] = true, ["mnesia"] = true,
    ["gen_tcp"] = true, ["gen_udp"] = true, ["ssl"] = true, ["crypto"] = true
}

-- Erlang operators
local operators = {
    ["->"] = true, ["<-"] = true, ["<="] = true, [">="] = true,
    ["=="] = true, ["/="] = true, ["=<"] = true, ["=/="] = true,
    ["=:="] = true, ["++"] = true, ["--"] = true, ["<<"] = true,
    [">>"] = true, ["!"] = true, ["?"] = true
}

-- Color codes for TUI (using ANSI-like codes that work with Hype)
local colors = {
    keyword = "[blue]",      -- Blue for keywords
    builtin = "[magenta]",   -- Magenta for built-ins
    string = "[green]",      -- Green for strings
    comment = "[yellow]",    -- Yellow for comments
    number = "[cyan]",       -- Cyan for numbers
    atom = "[red]",          -- Red for atoms
    variable = "[white]",    -- White for variables (starting with uppercase)
    operator = "[red]",      -- Red for operators
    macro = "[magenta]",     -- Magenta for macros
    reset = "[white]"        -- Reset to default
}

-- Function to highlight Erlang code
function highlighter.highlight(code)
    local result = ""
    local i = 1
    local len = #code
    
    while i <= len do
        local char = code:sub(i, i)
        
        -- Handle comments
        if char == '%' then
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
        elseif char == '"' then
            local start = i
            i = i + 1
            
            -- Find end of string, handle escapes
            while i <= len do
                local current = code:sub(i, i)
                if current == '"' then
                    i = i + 1
                    break
                elseif current == '\\' and i < len then
                    i = i + 2  -- Skip escaped character
                else
                    i = i + 1
                end
            end
            
            result = result .. colors.string .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle atoms (quoted)
        elseif char == "'" then
            local start = i
            i = i + 1
            
            -- Find end of atom, handle escapes
            while i <= len do
                local current = code:sub(i, i)
                if current == "'" then
                    i = i + 1
                    break
                elseif current == '\\' and i < len then
                    i = i + 2  -- Skip escaped character
                else
                    i = i + 1
                end
            end
            
            result = result .. colors.atom .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle macros
        elseif char == '?' then
            local start = i
            i = i + 1
            
            -- Read macro name
            while i <= len and code:sub(i, i):match('[%w_]') do
                i = i + 1
            end
            
            result = result .. colors.macro .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle numbers
        elseif char:match('%d') then
            local start = i
            
            -- Handle different number formats (decimal, hex, octal, binary)
            if char == '1' and i < len then
                local next_char = code:sub(i + 1, i + 1)
                if next_char == '6' and i + 1 < len and code:sub(i + 2, i + 2) == '#' then
                    -- Hex number (16#FF)
                    i = i + 3
                    while i <= len and code:sub(i, i):match('[%da-fA-F]') do
                        i = i + 1
                    end
                elseif next_char:match('[0-9]') and i + 2 < len and code:sub(i + 3, i + 3) == '#' then
                    -- Other base numbers (2#101, 8#777, etc.)
                    i = i + 1
                    while i <= len and code:sub(i, i):match('%d') do
                        i = i + 1
                    end
                    if i <= len and code:sub(i, i) == '#' then
                        i = i + 1
                        while i <= len and code:sub(i, i):match('[%da-zA-Z]') do
                            i = i + 1
                        end
                    end
                else
                    -- Regular number
                    while i <= len and (code:sub(i, i):match('%d') or code:sub(i, i) == '.') do
                        i = i + 1
                    end
                end
            else
                -- Regular decimal number
                while i <= len and (code:sub(i, i):match('%d') or code:sub(i, i) == '.') do
                    i = i + 1
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
            end
            
            result = result .. colors.number .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle identifiers (atoms, variables, keywords, built-ins)
        elseif char:match('[%a_]') then
            local start = i
            
            -- Read identifier
            while i <= len and code:sub(i, i):match('[%w_@]') do
                i = i + 1
            end
            
            local word = code:sub(start, i - 1)
            
            if keywords[word] then
                result = result .. colors.keyword .. word .. colors.reset
            elseif builtins[word] then
                result = result .. colors.builtin .. word .. colors.reset
            elseif word:match('^[A-Z_]') then
                -- Variables start with uppercase or underscore
                result = result .. colors.variable .. word .. colors.reset
            else
                -- Atoms (unquoted)
                result = result .. colors.atom .. word .. colors.reset
            end
        
        -- Handle operators
        elseif char:match('[=<>!+%-%*/\\^|&~]') or char == '?' then
            local start = i
            local found_op = false
            
            -- Check for multi-character operators
            for j = 3, 1, -1 do
                if i + j - 1 <= len then
                    local op = code:sub(i, i + j - 1)
                    if operators[op] or (j == 1 and char:match('[=<>!+%-%*/\\^|&~?]')) then
                        result = result .. colors.operator .. op .. colors.reset
                        i = i + j
                        found_op = true
                        break
                    end
                end
            end
            
            if not found_op then
                result = result .. char
                i = i + 1
            end
        
        -- Handle special Erlang syntax
        elseif char == '-' and i < len then
            local start = i
            -- Check for module attributes (-module, -export, etc.)
            i = i + 1
            while i <= len and code:sub(i, i):match('[%w_]') do
                i = i + 1
            end
            
            local attr = code:sub(start, i - 1)
            if attr:match('^%-[%w_]+$') then
                result = result .. colors.keyword .. attr .. colors.reset
            else
                result = result .. code:sub(start, i - 1)
            end
        
        -- Handle everything else (whitespace, punctuation)
        else
            result = result .. char
            i = i + 1
        end
    end
    
    return result
end

return highlighter