local csv = cc.load("csv").csv

local function startswith(str, substr)
    if str == nil or substr == nil then
        return nil, "the string or the sub-stirng parameter is nil"
    end
    if string.find(str, substr) ~= 1 then
        return false
    else
        return true
    end
end

local configLoader = {}
local nameRowID = 1
local typeRowID = 2
local TypeNames = {
    Array = "ARR",
    Num = "NUM",
    String = "STR",
}
local SPLIT_STR = { "~", "|", "#", ",", "/", "_" }
local formatData
formatData = function(data , typeName)
    if typeName == TypeNames.Num then
        data = tonumber(data)
    elseif typeName == TypeNames.String then
        data = tostring(data)
    elseif startswith(typeName, TypeNames.Array) then
        local types = string.split(typeName, "_")
        local arr = {}
        data = string.gsub(data, "，", ",")
        local splitArr = {}
        local isLoop = false
        local preSplit
        for i = 1, string.len(data) do
            local s = string.sub(data, i, i)
            local isContain = false
            for _, v in ipairs(SPLIT_STR) do
                if s ~= preSplit and v == s then
                    isContain = true
                    break
                end
            end
            if isContain then
                for _ , sp in ipairs(splitArr) do
                    if  s == sp then
                        isLoop = true
                        break
                    end
                end
                if not isLoop then
                    splitArr[#splitArr + 1] = s
                    preSplit = s
                end
                if isLoop then
                    break
                end
            end
        end
        local getArr 
        getArr = function(str, index)
            if str == "" then return {} end
            local arr = string.split(str, splitArr[index])
            local ret = {}
            if index > 1 then
                for _, v in ipairs(arr) do
                    ret[#ret + 1] = getArr(v, index - 1)
                end
            else
                for _, v in ipairs(arr) do
                    ret[#ret + 1] = formatData(v, #types > 1 and types[#types] or TypeNames.String)
                end
            end
            return ret
        end
        data = getArr(data, #splitArr)
    end
    return data
end

function configLoader.load(filePath , keyName)
    local str = cc.FileUtils:getInstance():getStringFromFile(filePath)
    local handle = csv.openstring(str)
    local result = {}
    local index  = 0
    local indexMap = {}
    local typeMap = {}
    local cache = {}
    for r in handle:lines() do
        index = index + 1
        if index == nameRowID then
            for i, v in ipairs(r) do 
                indexMap[i] = v
            end
        elseif index == typeRowID then
            for i, v in ipairs(r) do 
                typeMap[i] = string.upper(v)
            end
        else
            if(#indexMap > 0 and #typeMap > 0) then
                local solve = function(data)
                    local t = {}
                    for index , v in ipairs(r) do
                        t[indexMap[index]] = formatData(v, typeMap[index])
                    end
                    if keyName and t[keyName] then
                        result[t[keyName]] = t
                    else
                        result[#result + 1] = t
                    end
                end
                if(cache and #cache > 0) then
                    for _, data in ipairs(cache) do
                        solve(data)
                    end
                    cache = nil
                end
                solve(r)
            else
                cache[#cache + 1] = r
            end
        end
    end
    handle:close()
    return result
end

return configLoader