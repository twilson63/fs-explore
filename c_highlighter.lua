-- C Syntax Highlighter Module
local highlighter = {}

-- C keywords
local keywords = {
    ["auto"] = true, ["break"] = true, ["case"] = true, ["char"] = true,
    ["const"] = true, ["continue"] = true, ["default"] = true, ["do"] = true,
    ["double"] = true, ["else"] = true, ["enum"] = true, ["extern"] = true,
    ["float"] = true, ["for"] = true, ["goto"] = true, ["if"] = true,
    ["inline"] = true, ["int"] = true, ["long"] = true, ["register"] = true,
    ["restrict"] = true, ["return"] = true, ["short"] = true, ["signed"] = true,
    ["sizeof"] = true, ["static"] = true, ["struct"] = true, ["switch"] = true,
    ["typedef"] = true, ["union"] = true, ["unsigned"] = true, ["void"] = true,
    ["volatile"] = true, ["while"] = true, ["_Bool"] = true, ["_Complex"] = true,
    ["_Imaginary"] = true, ["_Alignas"] = true, ["_Alignof"] = true,
    ["_Atomic"] = true, ["_Static_assert"] = true, ["_Noreturn"] = true,
    ["_Thread_local"] = true, ["_Generic"] = true
}

-- Preprocessor directives
local preprocessor = {
    ["include"] = true, ["define"] = true, ["undef"] = true, ["ifdef"] = true,
    ["ifndef"] = true, ["if"] = true, ["else"] = true, ["elif"] = true,
    ["endif"] = true, ["error"] = true, ["pragma"] = true, ["line"] = true
}

-- Standard library functions
local stdlib_functions = {
    ["printf"] = true, ["scanf"] = true, ["malloc"] = true, ["free"] = true,
    ["calloc"] = true, ["realloc"] = true, ["strlen"] = true, ["strcpy"] = true,
    ["strcat"] = true, ["strcmp"] = true, ["strncmp"] = true, ["strstr"] = true,
    ["memcpy"] = true, ["memset"] = true, ["memmove"] = true, ["memcmp"] = true,
    ["fopen"] = true, ["fclose"] = true, ["fread"] = true, ["fwrite"] = true,
    ["fprintf"] = true, ["fscanf"] = true, ["fgets"] = true, ["fputs"] = true,
    ["exit"] = true, ["abort"] = true, ["atexit"] = true, ["getenv"] = true,
    ["system"] = true, ["qsort"] = true, ["bsearch"] = true, ["abs"] = true,
    ["rand"] = true, ["srand"] = true, ["atoi"] = true, ["atof"] = true,
    ["strtol"] = true, ["strtod"] = true
}

-- Color codes for TUI
local colors = {
    keyword = "[blue]",
    preprocessor = "[magenta]",
    function_name = "[cyan]",
    string = "[green]",
    char = "[green]",
    comment = "[yellow]",
    number = "[cyan]",
    operator = "[red]",
    reset = "[white]"
}

-- Function to highlight C code
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
        
        -- Handle preprocessor directives
        elseif char == '#' then
            local start = i
            i = i + 1
            
            -- Skip whitespace
            while i <= len and code:sub(i, i):match('%s') do
                i = i + 1
            end
            
            -- Read directive name
            local dir_start = i
            while i <= len and code:sub(i, i):match('[%w_]') do
                i = i + 1
            end
            
            local directive = code:sub(dir_start, i - 1)
            
            -- Read rest of line
            while i <= len and code:sub(i, i) ~= '\n' do
                i = i + 1
            end
            
            if preprocessor[directive] then
                result = result .. colors.preprocessor .. code:sub(start, i - 1) .. colors.reset
            else
                result = result .. code:sub(start, i - 1)
            end
            
            if i <= len then
                result = result .. '\n'
            end
        
        -- Handle strings
        elseif char == '"' then
            local start = i
            i = i + 1
            
            while i <= len do
                local current = code:sub(i, i)
                if current == '"' then
                    i = i + 1
                    break
                elseif current == '\\' and i < len then
                    i = i + 2
                else
                    i = i + 1
                end
            end
            
            result = result .. colors.string .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle character literals
        elseif char == "'" then
            local start = i
            i = i + 1
            
            while i <= len do
                local current = code:sub(i, i)
                if current == "'" then
                    i = i + 1
                    break
                elseif current == '\\' and i < len then
                    i = i + 2
                else
                    i = i + 1
                end
            end
            
            result = result .. colors.char .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle numbers
        elseif char:match('%d') or (char == '.' and i < len and code:sub(i + 1, i + 1):match('%d')) then
            local start = i
            
            -- Handle hex numbers
            if char == '0' and i < len and (code:sub(i + 1, i + 1) == 'x' or code:sub(i + 1, i + 1) == 'X') then
                i = i + 2
                while i <= len and code:sub(i, i):match('[%da-fA-F]') do
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
            
            -- Handle suffixes (L, U, F, etc.)
            while i <= len and code:sub(i, i):match('[lLuUfF]') do
                i = i + 1
            end
            
            result = result .. colors.number .. code:sub(start, i - 1) .. colors.reset
        
        -- Handle identifiers
        elseif char:match('[%a_]') then
            local start = i
            
            while i <= len and code:sub(i, i):match('[%w_]') do
                i = i + 1
            end
            
            local word = code:sub(start, i - 1)
            
            if keywords[word] then
                result = result .. colors.keyword .. word .. colors.reset
            elseif stdlib_functions[word] then
                result = result .. colors.function_name .. word .. colors.reset
            else
                result = result .. word
            end
        
        -- Handle operators
        elseif char:match('[%+%-%*/%%=<>!&|^~]') then
            local start = i
            
            -- Check for multi-character operators
            if i < len then
                local two_char = code:sub(i, i + 1)
                if two_char == '++' or two_char == '--' or two_char == '==' or 
                   two_char == '!=' or two_char == '<=' or two_char == '>=' or
                   two_char == '&&' or two_char == '||' or two_char == '<<' or
                   two_char == '>>' or two_char == '+=' or two_char == '-=' or
                   two_char == '*=' or two_char == '/=' or two_char == '%=' or
                   two_char == '&=' or two_char == '|=' or two_char == '^=' or
                   two_char == '->' then
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