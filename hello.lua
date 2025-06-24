local http = require("http")
local json = require("json")

local app = tui.newApp()

-- Create main layout container
local flex = tui.newFlex()
flex:SetDirection(tui.FlexColumn)

-- Create content area (top part)
local contentView = tui.newTextView("")
contentView:SetTitle("Browser Content")
contentView:SetBorder(true)
contentView:SetScrollable(true)
contentView:SetDynamicColors(true)

-- Create address bar (bottom part) 
local addressInput = tui.newInputField()
addressInput:SetLabel("Address: ")
addressInput:SetBorder(true)
addressInput:SetDoneFunc(function(key)
    if key == tui.KeyEnter then
        local url = addressInput:GetText()
        fetchAndDisplay(url, contentView)
    end
end)

-- Set up flex layout
flex:AddItem(contentView, 0, 1, true)  -- Content takes most space
flex:AddItem(addressInput, 3, 0, false)  -- Address bar at bottom, fixed height

-- Function to fetch and display content
function fetchAndDisplay(url, view)
    if url == "" then
        view:SetText("Enter a URL to browse")
        return
    end
    
    view:SetText("[yellow]Fetching from: " .. url .. "[white]\n\n[blue]Loading...")
    
    -- Make HTTP request using Hype's HTTP client
    http.get(url, function(err, response)
        if err then
            view:SetText("[red]Error fetching " .. url .. ":[white]\n\n" .. tostring(err))
            return
        end
        
        if response.status ~= 200 then
            view:SetText("[red]HTTP " .. response.status .. " Error:[white]\n\n" .. (response.body or "No response body"))
            return
        end
        
        local content = response.body or ""
        local displayContent = ""
        
        -- Try to parse as JSON and format it
        local success, parsedJson = pcall(json.decode, content)
        if success then
            local formattedJson = formatJson(parsedJson, 0)
            displayContent = "[green]JSON Response from: " .. url .. "[white]\n\n" .. formattedJson
        else
            -- Display as plain text if not valid JSON
            displayContent = "[cyan]Text Response from: " .. url .. "[white]\n\n" .. content
        end
        
        view:SetText(displayContent)
    end)
end

-- Simple JSON formatter
function formatJson(obj, indent)
    local spaces = string.rep("  ", indent)
    local result = ""
    
    if type(obj) == "table" then
        local isArray = true
        local count = 0
        for k, v in pairs(obj) do
            count = count + 1
            if type(k) ~= "number" or k ~= count then
                isArray = false
                break
            end
        end
        
        if isArray then
            result = result .. "[\n"
            for i, v in ipairs(obj) do
                result = result .. spaces .. "  " .. formatJson(v, indent + 1)
                if i < #obj then result = result .. "," end
                result = result .. "\n"
            end
            result = result .. spaces .. "]"
        else
            result = result .. "{\n"
            local keys = {}
            for k, v in pairs(obj) do table.insert(keys, k) end
            table.sort(keys)
            
            for i, k in ipairs(keys) do
                local v = obj[k]
                result = result .. spaces .. "  [cyan]\"" .. k .. "\"[white]: " .. formatJson(v, indent + 1)
                if i < #keys then result = result .. "," end
                result = result .. "\n"
            end
            result = result .. spaces .. "}"
        end
    elseif type(obj) == "string" then
        result = "[green]\"" .. obj .. "\"[white]"
    elseif type(obj) == "number" then
        result = "[yellow]" .. tostring(obj) .. "[white]"
    elseif type(obj) == "boolean" then
        result = "[red]" .. tostring(obj) .. "[white]"
    else
        result = tostring(obj)
    end
    
    return result
end

-- Initialize with welcome message
contentView:SetText("[white]Welcome to Hype Text Browser!\n\nEnter a URL in the address bar below and press Enter to browse.\nJSON responses will be formatted and displayed here.")

-- Set up and run the app
app:SetRoot(flex, true)
app:SetFocus(addressInput)
app:Run()
