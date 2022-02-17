local BindTools = cc.load("bind").bindTools

local saveTool = {}
saveTool.LocalCache = {}

local function fret(...)
    local args = {...}
    return function()
        return unpack(args)
    end
end

function saveTool.stringify(val, needSort, cache)
    cache = cache or {}
    val = BindTools.getBindInfo(val)
    return (({
        ["nil"]         = fret "nil",
        ["boolean"]     = fret(tostring(val)),
        ["number"]      = fret(val),
        ["function"]    = function()
            return "function(...)" ..
                "return load(" ..
                    saveTool.stringify(string.dump(val), needSort, cache)..
                ")(...)" ..
            "end"
        end,
        ["string"]      = function()
            local s = "\""
            for c in string.gmatch(val, ".") do
                s = s .. "\\" .. c:byte()
            end
            return s .. "\""
        end,
        ["table"]       = function()
            if cache[val] then 
                error("loop stringify")
                return
            end
            cache[val] = true
            local members = {}
            if needSort then
                local keys = {}
                for k , _ in pairs(val) do
                    table.insert(keys, k)
                end
                table.sort( keys )
                for _ , v in ipairs(keys) do
                    table.insert(members, "[" .. saveTool.stringify(v, needSort, cache) .. "]=" .. saveTool.stringify(val[v], needSort, cache))
                end
            else
                for k , v in pairs(val) do
                    table.insert(members, "[" .. saveTool.stringify(k, needSort, cache) .. "]=" .. saveTool.stringify(v, needSort, cache))
                end
            end
            return "{" .. table.concat(members, ",") .. "}"
        end,
    })[type(val)] or function() 
        error("cannot stringify type:" .. type(val), 2)
    end)()
end

function saveTool.saveData(key, value)
    local key = saveTool.stringify(key, true)
    saveTool.LocalCache[key] = value or saveTool.LocalCache[key]
    cc.UserDefault:getInstance():setStringForKey("HyData:" .. key, saveTool.stringify(saveTool.LocalCache[key]))
end

function saveTool.removeData(key)
    local key = saveTool.stringify(key, true)
    saveTool.LocalCache[key] = nil
    cc.UserDefault:getInstance():deleteValueForKey("HyData:" .. key)
end

function saveTool.getData(key)
    local key = saveTool.stringify(key, true)
    if saveTool.LocalCache[key] then
        return saveTool.LocalCache[key]
    end
    local str = cc.UserDefault:getInstance():getStringForKey("HyData:" .. key)
    if str and str ~= "" then
        local obj = load("return " .. str)()
        saveTool.LocalCache[key] = obj
        return obj
    end
    return nil
end

return saveTool