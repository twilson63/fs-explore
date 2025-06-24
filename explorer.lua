local fs = require("fs")
local lua_highlighter = require("lua_highlighter")
local markdown_highlighter = require("markdown_highlighter")
local erlang_highlighter = require("erlang_highlighter")
local c_highlighter = require("c_highlighter")
local javascript_highlighter = require("javascript_highlighter")
local typescript_highlighter = require("typescript_highlighter")

local app = tui.newApp()

-- Create main flex container
local mainFlex = tui.newFlex()
mainFlex:SetDirection(0)  -- 0 for column direction

-- Create content area (top part) for file listing
local fileListView = tui.newTextView("")
fileListView:SetTitle("File Explorer - Escape to focus/scroll, Ctrl+L for path")
fileListView:SetBorder(true)
fileListView:SetScrollable(true)
fileListView:SetDynamicColors(true)
fileListView:SetWrap(false)

-- Create navigation bar (bottom part)
local pathInput = tui.newInputField()
pathInput:SetLabel("Path: ")
pathInput:SetBorder(true)
pathInput:SetFieldBackgroundColor(245)
pathInput:SetFieldTextColor(235)
pathInput:SetDoneFunc(function(key)
    -- Try different key constants for Enter
    if key == 13 or key == 10 or key == tui.KeyEnter then
        local input = pathInput:GetText()
        pathInput:SetText("")  -- Clear input after command
        processCommand(input, fileListView)
    end
end)

-- Set up flex layout - add both views to the main flex container
mainFlex:AddItem(fileListView, 0, 1, true)  -- File list takes most space
mainFlex:AddItem(pathInput, 3, 0, false)    -- Path input at bottom, fixed height

-- Global variable to track current directory
local currentDirectory = "."

-- Function to resolve relative paths
function resolvePath(path)
    if path:sub(1, 1) == "/" then
        -- Absolute path
        return path
    elseif path == ".." then
        -- Parent directory
        if currentDirectory == "/" then
            return "/"
        elseif currentDirectory == "." then
            return ".."
        else
            local parent = currentDirectory:match("(.+)/[^/]*$")
            return parent or "."
        end
    elseif path == "." then
        -- Current directory
        return currentDirectory
    else
        -- Relative path - combine with current directory
        if currentDirectory == "." then
            return path
        elseif currentDirectory:sub(-1) == "/" then
            return currentDirectory .. path
        else
            return currentDirectory .. "/" .. path
        end
    end
end

-- Function to process commands
function processCommand(input, view)
    if input == "" then
        input = "."
    end
    
    -- Handle special commands
    if input == "quit" or input == "exit" then
        app:Stop()
        return
    elseif input == "home" then
        currentDirectory = fs.getHomeDir()
        listDirectory(currentDirectory, view)
        return
    elseif input:match("^open%s+(.+)") then
        local filename = input:match("^open%s+(.+)")
        local fullPath = resolvePath(filename)
        viewFile(fullPath, view)
        return
    end
    
    -- Default: treat as directory navigation
    local resolvedPath = resolvePath(input)
    fs.stat(resolvedPath, function(err, stats)
        if err then
            view:SetText("Error: " .. err .. "\nPath: " .. resolvedPath)
            return
        end
        
        if stats.isDirectory then
            currentDirectory = resolvedPath
            listDirectory(currentDirectory, view)
        else
            viewFile(resolvedPath, view)
        end
    end)
end

-- Function to check if file has Lua extension
function isLuaFile(path)
    return path:match("%.lua$") ~= nil
end

-- Function to check if file has Markdown extension
function isMarkdownFile(path)
    return path:match("%.md$") ~= nil or path:match("%.markdown$") ~= nil
end

-- Function to check if file has Erlang extension
function isErlangFile(path)
    return path:match("%.erl$") ~= nil or path:match("%.hrl$") ~= nil
end

-- Function to check if file has C extension
function isCFile(path)
    return path:match("%.c$") ~= nil or path:match("%.h$") ~= nil
end

-- Function to check if file has JavaScript extension
function isJavaScriptFile(path)
    return path:match("%.js$") ~= nil or path:match("%.jsx$") ~= nil or path:match("%.mjs$") ~= nil
end

-- Function to check if file has TypeScript extension
function isTypeScriptFile(path)
    return path:match("%.ts$") ~= nil or path:match("%.tsx$") ~= nil
end

-- Function to view file contents
function viewFile(path, view)
    view:SetText("Loading file: " .. path .. "\n\nReading...")
    
    fs.readFile(path, function(err, data)
        if err then
            view:SetText("Error reading file " .. path .. ":\n\n" .. err)
            return
        end
        
        if data.isBinary then
            view:SetText("File: " .. path .. "\n\nCannot view binary file.\n\nPress any key to return to directory listing.")
        else
            local content = "File: " .. path .. "\n" .. string.rep("-", 50) .. "\n\n"
            
            -- Apply syntax highlighting based on file type
            if isLuaFile(path) then
                content = content .. lua_highlighter.highlight(data.content)
            elseif isMarkdownFile(path) then
                content = content .. markdown_highlighter.highlight(data.content)
            elseif isErlangFile(path) then
                content = content .. erlang_highlighter.highlight(data.content)
            elseif isCFile(path) then
                content = content .. c_highlighter.highlight(data.content)
            elseif isJavaScriptFile(path) then
                content = content .. javascript_highlighter.highlight(data.content)
            elseif isTypeScriptFile(path) then
                content = content .. typescript_highlighter.highlight(data.content)
            else
                content = content .. data.content
            end
            
            view:SetText(content)
        end
    end)
end

-- Function to list directory contents
function listDirectory(path, view)
    view:SetText("Loading directory: " .. path .. "\n\nReading...")
    
    -- Read directory contents
    fs.readdir(path, function(err, files)
        if err then
            view:SetText("Error reading directory " .. path .. ":\n\n" .. tostring(err))
            return
        end
        
        local content = "Directory: " .. path .. "\n" .. string.rep("=", 50) .. "\n\n"
        
        if not files or #files == 0 then
            content = content .. "Directory is empty"
        else
            -- Add parent directory option if not at root
            if path ~= "/" and path ~= "." then
                content = content .. "📁 .. (parent directory)\n"
            end
            
            -- Separate directories and files
            local directories = {}
            local regularFiles = {}
            
            for _, file in ipairs(files) do
                if file ~= "." and file ~= ".." then
                    local fullPath = path .. "/" .. file
                    if path == "." then
                        fullPath = file
                    elseif path:sub(-1) == "/" then
                        fullPath = path .. file
                    end
                    
                    -- Check if it's a directory
                    fs.stat(fullPath, function(statErr, stats)
                        if not statErr and stats and stats.isDirectory then
                            table.insert(directories, file)
                        else
                            table.insert(regularFiles, file)
                        end
                        
                        -- Update display when all files are processed
                        if #directories + #regularFiles == #files then
                            updateFileDisplay(view, path, directories, regularFiles)
                        end
                    end)
                end
            end
            
            -- Fallback if no files trigger the callback
            if #files == 0 then
                updateFileDisplay(view, path, directories, regularFiles)
            end
        end
        
        if #files == 0 then
            view:SetText(content)
        end
    end)
end

-- Function to update file display with sorted directories and files
function updateFileDisplay(view, path, directories, regularFiles)
    local content = "Directory: " .. path .. "\n" .. string.rep("=", 50) .. "\n\n"
    
    -- Add parent directory option if not at root
    if path ~= "/" and path ~= "." then
        content = content .. "📁 .. (parent directory)\n"
    end
    
    -- Sort directories and files
    table.sort(directories)
    table.sort(regularFiles)
    
    -- Display directories first
    for _, dir in ipairs(directories) do
        content = content .. "📁 " .. dir .. "\n"
    end
    
    -- Display files
    for _, file in ipairs(regularFiles) do
        local icon = getFileIcon(file)
        content = content .. icon .. " " .. file .. "\n"
    end
    
    if #directories == 0 and #regularFiles == 0 then
        content = content .. "Directory is empty"
    end
    
    -- Add command help
    content = content .. "\n" .. string.rep("-", 30) .. "\n"
    content = content .. "Commands: <path> | open <file> | home | quit\n"
    
    view:SetText(content)
end

-- Function to get file icon based on extension
function getFileIcon(filename)
    local ext = filename:match("%.([^%.]+)$")
    if not ext then
        return "📄"
    end
    
    ext = ext:lower()
    if ext == "lua" then
        return "🌙"
    elseif ext == "js" or ext == "ts" then
        return "📜"
    elseif ext == "json" then
        return "📋"
    elseif ext == "md" then
        return "📝"
    elseif ext == "txt" then
        return "📄"
    elseif ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "gif" then
        return "🖼️"
    elseif ext == "zip" or ext == "tar" or ext == "gz" then
        return "📦"
    else
        return "📄"
    end
end

-- Initialize with welcome message and current directory
fileListView:SetText("Welcome to File Explorer!\n\nCommands:\n- <path> - Navigate to directory\n- open <file> - View file contents\n- home - Go to home directory\n- quit - Exit application\n\nPress Enter in the path field below to start.")

-- Initialize current directory
currentDirectory = "."
listDirectory(currentDirectory, fileListView)


-- Set up keyboard shortcuts for focus switching (like browser example)
app:SetInputCapture(function(event)
    local key = event:Key()
    if key == 12 then -- Ctrl+L - focus path input and clear it
        app:SetFocus(pathInput)
        pathInput:SetText("")
        return nil
    elseif key == 27 then -- Escape - focus file view for scrolling
        app:SetFocus(fileListView)
        return nil
    end
    return key
end)

-- Set up and run the app
app:SetRoot(mainFlex, true)  -- Set mainFlex as root with focus enabled
app:SetFocus(pathInput)  -- Start with path focused like the browser example
app:Run()
