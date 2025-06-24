local json = {}

-- Null value placeholder
json.null = {}

-- String escaping for JSON
local function escape_string(str)
    local escape_map = {
        ["\\"] = "\\\\",
        ["\""] = "\\\"",
        ["\b"] = "\\b",
        ["\f"] = "\\f",
        ["\n"] = "\\n",
        ["\r"] = "\\r",
        ["\t"] = "\\t"
    }
    
    return str:gsub("[\\\"\\b\\f\\n\\r\\t]", escape_map)
        :gsub("[\0-\31]", function(char)
            return string.format("\\u%04x", string.byte(char))
        end)
end

-- String unescaping for JSON
local function unescape_string(str)
    local unescape_map = {
        ["\\\\"] = "\\",
        ["\\\""] = "\"",
        ["\\b"] = "\b",
        ["\\f"] = "\f",
        ["\\n"] = "\n",
        ["\\r"] = "\r",
        ["\\t"] = "\t",
        ["\\/"] = "/"
    }
    
    return str:gsub("\\.", unescape_map)
        :gsub("\\u(%x%x%x%x)", function(hex)
            return string.char(tonumber(hex, 16))
        end)
end

-- Check if table is array-like
local function is_array(tbl)
    local count = 0
    for k, v in pairs(tbl) do
        count = count + 1
        if type(k) ~= "number" or k ~= count then
            return false
        end
    end
    return true
end

-- JSON encode function
function json.encode(value)
    local value_type = type(value)
    
    if value == json.null then
        return "null"
    elseif value_type == "nil" then
        return "null"
    elseif value_type == "boolean" then
        return value and "true" or "false"
    elseif value_type == "number" then
        if value ~= value then  -- NaN check
            return "null"
        elseif value == math.huge or value == -math.huge then  -- Infinity check
            return "null"
        else
            return tostring(value)
        end
    elseif value_type == "string" then
        return "\"" .. escape_string(value) .. "\""
    elseif value_type == "table" then
        if is_array(value) then
            -- Encode as array
            local parts = {}
            for i = 1, #value do
                parts[i] = json.encode(value[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            -- Encode as object
            local parts = {}
            local count = 0
            for k, v in pairs(value) do
                if type(k) == "string" then
                    count = count + 1
                    parts[count] = "\"" .. escape_string(k) .. "\":" .. json.encode(v)
                end
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    else
        error("Cannot encode value of type " .. value_type)
    end
end

-- JSON decode function
function json.decode(str)
    local pos = 1
    local len = #str
    
    -- Skip whitespace
    local function skip_whitespace()
        while pos <= len and str:sub(pos, pos):match("[ \t\n\r]") do
            pos = pos + 1
        end
    end
    
    -- Parse string
    local function parse_string()
        if str:sub(pos, pos) ~= "\"" then
            error("Expected '\"' at position " .. pos)
        end
        pos = pos + 1
        
        local start = pos
        local result = ""
        
        while pos <= len do
            local char = str:sub(pos, pos)
            if char == "\"" then
                result = result .. str:sub(start, pos - 1)
                pos = pos + 1
                return unescape_string(result)
            elseif char == "\\" then
                result = result .. str:sub(start, pos - 1)
                pos = pos + 1
                if pos <= len then
                    local escaped = str:sub(pos, pos)
                    if escaped == "u" then
                        -- Unicode escape
                        local hex = str:sub(pos + 1, pos + 4)
                        if #hex == 4 and hex:match("^%x%x%x%x$") then
                            result = result .. "\\" .. escaped .. hex
                            pos = pos + 5
                        else
                            error("Invalid unicode escape at position " .. pos)
                        end
                    else
                        result = result .. "\\" .. escaped
                        pos = pos + 1
                    end
                    start = pos
                else
                    error("Unexpected end of string")
                end
            else
                pos = pos + 1
            end
        end
        
        error("Unterminated string")
    end
    
    -- Parse number
    local function parse_number()
        local start = pos
        
        -- Optional minus
        if str:sub(pos, pos) == "-" then
            pos = pos + 1
        end
        
        -- Integer part
        if str:sub(pos, pos) == "0" then
            pos = pos + 1
        elseif str:sub(pos, pos):match("[1-9]") then
            pos = pos + 1
            while pos <= len and str:sub(pos, pos):match("[0-9]") do
                pos = pos + 1
            end
        else
            error("Invalid number at position " .. start)
        end
        
        -- Fractional part
        if pos <= len and str:sub(pos, pos) == "." then
            pos = pos + 1
            if not (pos <= len and str:sub(pos, pos):match("[0-9]")) then
                error("Invalid number at position " .. start)
            end
            while pos <= len and str:sub(pos, pos):match("[0-9]") do
                pos = pos + 1
            end
        end
        
        -- Exponent part
        if pos <= len and str:sub(pos, pos):match("[eE]") then
            pos = pos + 1
            if pos <= len and str:sub(pos, pos):match("[+-]") then
                pos = pos + 1
            end
            if not (pos <= len and str:sub(pos, pos):match("[0-9]")) then
                error("Invalid number at position " .. start)
            end
            while pos <= len and str:sub(pos, pos):match("[0-9]") do
                pos = pos + 1
            end
        end
        
        return tonumber(str:sub(start, pos - 1))
    end
    
    -- Forward declaration
    local parse_value
    
    -- Parse array
    local function parse_array()
        local result = {}
        pos = pos + 1  -- Skip '['
        skip_whitespace()
        
        if pos <= len and str:sub(pos, pos) == "]" then
            pos = pos + 1
            return result
        end
        
        local count = 0
        while true do
            count = count + 1
            result[count] = parse_value()
            skip_whitespace()
            
            if pos <= len and str:sub(pos, pos) == "]" then
                pos = pos + 1
                break
            elseif pos <= len and str:sub(pos, pos) == "," then
                pos = pos + 1
                skip_whitespace()
            else
                error("Expected ',' or ']' at position " .. pos)
            end
        end
        
        return result
    end
    
    -- Parse object
    local function parse_object()
        local result = {}
        pos = pos + 1  -- Skip '{'
        skip_whitespace()
        
        if pos <= len and str:sub(pos, pos) == "}" then
            pos = pos + 1
            return result
        end
        
        while true do
            skip_whitespace()
            local key = parse_string()
            skip_whitespace()
            
            if not (pos <= len and str:sub(pos, pos) == ":") then
                error("Expected ':' at position " .. pos)
            end
            pos = pos + 1
            skip_whitespace()
            
            result[key] = parse_value()
            skip_whitespace()
            
            if pos <= len and str:sub(pos, pos) == "}" then
                pos = pos + 1
                break
            elseif pos <= len and str:sub(pos, pos) == "," then
                pos = pos + 1
            else
                error("Expected ',' or '}' at position " .. pos)
            end
        end
        
        return result
    end
    
    -- Parse value
    parse_value = function()
        skip_whitespace()
        
        if pos > len then
            error("Unexpected end of input")
        end
        
        local char = str:sub(pos, pos)
        
        if char == "\"" then
            return parse_string()
        elseif char == "{" then
            return parse_object()
        elseif char == "[" then
            return parse_array()
        elseif char:match("[-0-9]") then
            return parse_number()
        elseif str:sub(pos, pos + 3) == "true" then
            pos = pos + 4
            return true
        elseif str:sub(pos, pos + 4) == "false" then
            pos = pos + 5
            return false
        elseif str:sub(pos, pos + 3) == "null" then
            pos = pos + 4
            return json.null
        else
            error("Unexpected character '" .. char .. "' at position " .. pos)
        end
    end
    
    local result = parse_value()
    skip_whitespace()
    
    if pos <= len then
        error("Unexpected character after JSON at position " .. pos)
    end
    
    return result
end

return json