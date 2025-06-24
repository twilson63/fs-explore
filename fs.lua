-- Cross-platform filesystem module for Hype
local fs = {}

-- Detect operating system
local function getOS()
    local sep = package.config:sub(1,1)
    if sep == '\\' then
        return 'windows'
    else
        return 'unix'
    end
end

local OS = getOS()

-- Execute command and capture output
local function execute(cmd)
    local handle = io.popen(cmd)
    if not handle then
        return nil, "Failed to execute command"
    end
    local result = handle:read("*a")
    local success = handle:close()
    return result, success
end

-- Read directory contents
function fs.readdir(path, callback)
    if not path or path == "" then
        path = "."
    end
    
    local cmd
    if OS == 'windows' then
        cmd = 'dir "' .. path .. '" /B 2>NUL'
    else
        cmd = 'ls -1 "' .. path .. '" 2>/dev/null'
    end
    
    local result, success = execute(cmd)
    
    if not success or not result then
        callback("Directory not found or access denied", nil)
        return
    end
    
    local files = {}
    for file in result:gmatch("[^\r\n]+") do
        if file and file ~= "" then
            table.insert(files, file)
        end
    end
    
    callback(nil, files)
end

-- Get file/directory stats
function fs.stat(path, callback)
    if not path or path == "" then
        callback("Invalid path", nil)
        return
    end
    
    local cmd
    if OS == 'windows' then
        cmd = 'dir "' .. path .. '" 2>NUL | findstr /C:"<DIR>"'
    else
        cmd = 'test -d "' .. path .. '" && echo "directory" || echo "file"'
    end
    
    local result, success = execute(cmd)
    
    if not success then
        callback("Path not found", nil)
        return
    end
    
    local isDirectory = false
    if OS == 'windows' then
        isDirectory = result and result:find("<DIR>") ~= nil
    else
        isDirectory = result and result:find("directory") ~= nil
    end
    
    local stats = {
        isDirectory = isDirectory
    }
    
    callback(nil, stats)
end

-- Read file contents
function fs.readFile(path, callback)
    if not path or path == "" then
        callback("Invalid file path", nil)
        return
    end
    
    local file = io.open(path, "rb")
    if not file then
        callback("Cannot open file", nil)
        return
    end
    
    local content = file:read("*a")
    file:close()
    
    if not content then
        callback("Cannot read file", nil)
        return
    end
    
    -- Check if file is binary by looking for null bytes
    local isBinary = content:find("\0") ~= nil
    
    callback(nil, {
        content = content,
        isBinary = isBinary
    })
end

-- Get home directory
function fs.getHomeDir()
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
    return home or "."
end

return fs