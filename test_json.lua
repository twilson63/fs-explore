local json = require("json")

-- Test encode/decode with various data types
print("Testing JSON encode/decode library")
print("=" .. string.rep("=", 40))

-- Test cases
local test_cases = {
    -- Simple values
    { value = nil, name = "nil" },
    { value = json.null, name = "json.null" },
    { value = true, name = "boolean true" },
    { value = false, name = "boolean false" },
    { value = 42, name = "number integer" },
    { value = 3.14159, name = "number float" },
    { value = "hello world", name = "simple string" },
    { value = "hello\nworld\t\"quoted\"", name = "string with escapes" },
    
    -- Arrays
    { value = {}, name = "empty array" },
    { value = {1, 2, 3}, name = "number array" },
    { value = {"a", "b", "c"}, name = "string array" },
    { value = {true, false, json.null}, name = "mixed array" },
    
    -- Objects
    { value = {name = "John", age = 30}, name = "simple object" },
    { value = {
        name = "Alice",
        age = 25,
        hobbies = {"reading", "coding"},
        active = true,
        score = json.null
    }, name = "complex object" },
    
    -- Nested structures
    { value = {
        users = {
            {id = 1, name = "John"},
            {id = 2, name = "Jane"}
        },
        meta = {
            total = 2,
            page = 1
        }
    }, name = "nested structure" }
}

-- Run tests
for i, test in ipairs(test_cases) do
    print("\nTest " .. i .. ": " .. test.name)
    print("Original:", type(test.value) == "table" and "table" or tostring(test.value))
    
    local encoded = json.encode(test.value)
    print("Encoded: " .. encoded)
    
    local decoded = json.decode(encoded)
    local re_encoded = json.encode(decoded)
    print("Re-encoded: " .. re_encoded)
    
    if encoded == re_encoded then
        print("✓ Round-trip successful")
    else
        print("✗ Round-trip failed")
    end
end

-- Test error cases
print("\n" .. string.rep("=", 40))
print("Testing error cases")

local error_cases = {
    '{"invalid": }',
    '{"unclosed": "string',
    '[1, 2, 3,]',
    'undefined_value',
    '{"duplicate": 1, "duplicate": 2}'
}

for i, case in ipairs(error_cases) do
    print("\nError test " .. i .. ": " .. case)
    local success, result = pcall(json.decode, case)
    if success then
        print("✗ Expected error but got: " .. json.encode(result))
    else
        print("✓ Correctly caught error: " .. result)
    end
end

print("\nJSON library tests completed!")