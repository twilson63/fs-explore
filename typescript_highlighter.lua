-- TypeScript Syntax Highlighter Module
local highlighter = {}

-- TypeScript keywords (includes all JavaScript keywords plus TypeScript-specific ones)
local keywords = {
    -- JavaScript keywords
    ["break"] = true, ["case"] = true, ["catch"] = true, ["class"] = true,
    ["const"] = true, ["continue"] = true, ["debugger"] = true, ["default"] = true,
    ["delete"] = true, ["do"] = true, ["else"] = true, ["export"] = true,
    ["extends"] = true, ["finally"] = true, ["for"] = true, ["function"] = true,
    ["if"] = true, ["import"] = true, ["in"] = true, ["instanceof"] = true,
    ["let"] = true, ["new"] = true, ["return"] = true, ["super"] = true,
    ["switch"] = true, ["this"] = true, ["throw"] = true, ["try"] = true,
    ["typeof"] = true, ["var"] = true, ["void"] = true, ["while"] = true,
    ["with"] = true, ["yield"] = true, ["async"] = true, ["await"] = true,
    ["static"] = true, ["get"] = true, ["set"] = true, ["of"] = true,
    -- TypeScript-specific keywords
    ["abstract"] = true, ["as"] = true, ["declare"] = true, ["enum"] = true,
    ["implements"] = true, ["interface"] = true, ["is"] = true, ["keyof"] = true,
    ["module"] = true, ["namespace"] = true, ["never"] = true, ["override"] = true,
    ["private"] = true, ["protected"] = true, ["public"] = true, ["readonly"] = true,
    ["satisfies"] = true, ["type"] = true, ["unique"] = true, ["unknown"] = true,
    ["infer"] = true, ["out"] = true, ["asserts"] = true
}

-- TypeScript built-in types
local builtin_types = {
    ["any"] = true, ["boolean"] = true, ["number"] = true, ["string"] = true,
    ["object"] = true, ["symbol"] = true, ["bigint"] = true, ["undefined"] = true,
    ["null"] = true, ["void"] = true, ["never"] = true, ["unknown"] = true,
    ["Array"] = true, ["Promise"] = true, ["Record"] = true, ["Partial"] = true,
    ["Required"] = true, ["Readonly"] = true, ["Pick"] = true, ["Omit"] = true,
    ["Exclude"] = true, ["Extract"] = true, ["NonNullable"] = true, ["Parameters"] = true,
    ["ConstructorParameters"] = true, ["ReturnType"] = true, ["InstanceType"] = true,
    ["ThisParameterType"] = true, ["OmitThisParameter"] = true, ["ThisType"] = true,
    ["Uppercase"] = true, ["Lowercase"] = true, ["Capitalize"] = true, ["Uncapitalize"] = true
}

-- JavaScript/TypeScript built-in objects and functions
local builtins = {
    ["console"] = true, ["window"] = true, ["document"] = true, ["global"] = true,
    ["process"] = true, ["require"] = true, ["module"] = true, ["exports"] = true,
    ["Array"] = true, ["Object"] = true, ["String"] = true, ["Number"] = true,
    ["Boolean"] = true, ["Date"] = true, ["RegExp"] = true, ["Error"] = true,
    ["Function"] = true, ["Promise"] = true, ["Symbol"] = true, ["Map"] = true,
    ["Set"] = true, ["WeakMap"] = true, ["WeakSet"] = true, ["Proxy"] = true,
    ["Reflect"] = true, ["JSON"] = true, ["Math"] = true, ["parseInt"] = true,
    ["parseFloat"] = true, ["isNaN"] = true, ["isFinite"] = true, ["eval"] = true,
    ["encodeURI"] = true, ["decodeURI"] = true, ["setTimeout"] = true, ["setInterval"] = true,
    ["clearTimeout"] = true, ["clearInterval"] = true, ["true"] = true, ["false"] = true,
    ["Infinity"] = true, ["NaN"] = true
}

-- Color codes for TUI
local colors = {
    keyword = "[blue]",
    type = "[cyan]",
    builtin = "[magenta]",
    string = "[green]",
    template = "[green]",
    comment = "[yellow]",
    number = "[cyan]",
    regex = "[red]",
    operator = "[red]",
    decorator = "[magenta]",
    reset = "[white]"
}

-- Function to highlight TypeScript code
function highlighter.highlight(code)
    local result = ""
    local i = 1
    local len = #code
    
    while i <= len do
        local char = code:sub(i, i)
        
        -- Handle single-line comments (//)
        if char == '/' and i < len and code:sub(i + 1, i + 1) == '/' then
            local start = i
            while i <= len and code:sub(i, i) ~= '\n' do
                i = i + 1
            end
            result = result .. colors.comment .. code:sub(start, i - 1) .. colors.reset
            if i <= len then
                result = result .. '\n'
            end
        
        -- Handle multi-line comments (/* */)
        elseif char == '/' and i < len and code:sub(i + 1, i + 1) == '*' then
            local start = i
            i = i + 2
            while i < len do
                if code:sub(i, i + 1) == '*/' then
                    i = i + 2
                    break
                end
                i = i + 1
            end
            result = result .. colors.comment .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle decorators (@decorator)
        elseif char == '@' then
            local start = i
            i = i + 1
            
            -- Read decorator name
            while i <= len and code:sub(i, i):match('[%w_$]') do
                i = i + 1
            end
            
            result = result .. colors.decorator .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle template literals (`string`)
        elseif char == '`' then
            local start = i
            i = i + 1
            
            while i <= len do
                local current = code:sub(i, i)
                if current == '`' then
                    i = i + 1
                    break
                elseif current == '\\' and i < len then
                    i = i + 2
                elseif current == '$' and i < len and code:sub(i + 1, i + 1) == '{' then
                    -- Handle template expression ${...}
                    local expr_start = i
                    i = i + 2
                    local brace_count = 1
                    while i <= len and brace_count > 0 do
                        if code:sub(i, i) == '{' then
                            brace_count = brace_count + 1
                        elseif code:sub(i, i) == '}' then
                            brace_count = brace_count - 1
                        end
                        i = i + 1
                    end
                else
                    i = i + 1
                end
            end
            
            result = result .. colors.template .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle strings
        elseif char == '"' or char == "'" then
            local quote = char
            local start = i
            i = i + 1
            
            while i <= len do
                local current = code:sub(i, i)
                if current == quote then
                    i = i + 1
                    break
                elseif current == '\\' and i < len then
                    i = i + 2
                else
                    i = i + 1
                end
            end
            
            result = result .. colors.string .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle regular expressions
        elseif char == '/' and i > 1 then
            -- Simple regex detection
            local prev_char = code:sub(i - 1, i - 1)
            if prev_char:match('[=(%[,;:!&|?+%-%*/%%^~<>]') or prev_char:match('%s') then
                local start = i
                i = i + 1
                
                while i <= len do
                    local current = code:sub(i, i)
                    if current == '/' then
                        i = i + 1
                        -- Handle regex flags
                        while i <= len and code:sub(i, i):match('[gimuy]') do
                            i = i + 1
                        end
                        break
                    elseif current == '\\' and i < len then
                        i = i + 2
                    elseif current == '\n' then
                        break
                    else
                        i = i + 1
                    end
                end
                
                result = result .. colors.regex .. code:sub(start, i - 1) .. colors.reset
            else
                result = result .. char
                i = i + 1
            end
        
        -- Handle numbers
        elseif char:match('%d') or (char == '.' and i < len and code:sub(i + 1, i + 1):match('%d')) then
            local start = i
            
            -- Handle hex numbers
            if char == '0' and i < len and (code:sub(i + 1, i + 1) == 'x' or code:sub(i + 1, i + 1) == 'X') then
                i = i + 2
                while i <= len and code:sub(i, i):match('[%da-fA-F]') do
                    i = i + 1
                end
            -- Handle binary numbers
            elseif char == '0' and i < len and (code:sub(i + 1, i + 1) == 'b' or code:sub(i + 1, i + 1) == 'B') then
                i = i + 2
                while i <= len and code:sub(i, i):match('[01]') do
                    i = i + 1
                end
            -- Handle octal numbers
            elseif char == '0' and i < len and (code:sub(i + 1, i + 1) == 'o' or code:sub(i + 1, i + 1) == 'O') then
                i = i + 2
                while i <= len and code:sub(i, i):match('[0-7]') do
                    i = i + 1
                end
            else
                -- Regular number
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
        
        -- Handle identifiers
        elseif char:match('[%a_$]') then
            local start = i
            
            while i <= len and code:sub(i, i):match('[%w_$]') do
                i = i + 1
            end
            
            local word = code:sub(start, i - 1)
            
            if keywords[word] then
                result = result .. colors.keyword .. word .. colors.reset
            elseif builtin_types[word] then
                result = result .. colors.type .. word .. colors.reset
            elseif builtins[word] then
                result = result .. colors.builtin .. word .. colors.reset
            else
                result = result .. word
            end
        
        -- Handle operators and type annotations
        elseif char:match('[%+%-%*/%%=<>!&|^~?:]') then
            local start = i
            
            -- Check for multi-character operators
            if i < len then
                local three_char = i + 2 <= len and code:sub(i, i + 2) or ""
                local two_char = code:sub(i, i + 1)
                
                if three_char == '===' or three_char == '!==' or three_char == '>>>' or
                   three_char == '<<=' or three_char == '>>=' or three_char == '**=' then
                    i = i + 3
                elseif two_char == '++' or two_char == '--' or two_char == '==' or 
                       two_char == '!=' or two_char == '<=' or two_char == '>=' or
                       two_char == '&&' or two_char == '||' or two_char == '<<' or
                       two_char == '>>' or two_char == '+=' or two_char == '-=' or
                       two_char == '*=' or two_char == '/=' or two_char == '%=' or
                       two_char == '&=' or two_char == '|=' or two_char == '^=' or
                       two_char == '=>' or two_char == '??' or two_char == '?.' or
                       two_char == '**' or two_char == '?:' then
                    i = i + 2
                else
                    i = i + 1
                end
            else
                i = i + 1
            end
            
            result = result .. colors.operator .. code:sub(start, i - 1) .. colors.reset
        
        -- Everything else
        else
            result = result .. char
            i = i + 1
        end
    end
    
    return result
end

return highlighter