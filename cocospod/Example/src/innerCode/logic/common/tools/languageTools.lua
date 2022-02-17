local languageTools = {}

local function split(s, sp)
    local res = {}

    local temp = s
    local len = 0
    while true do
        len = string.find(temp, sp)
        if len ~= nil then
            local result = string.sub(temp, 1, len-1)
            temp = string.sub(temp, len+1)
            table.insert(res, result)
        else
            table.insert(res, temp)
            break
        end
    end

    return res
end

languageTools._languageSave = {}
languageTools._curLanguage = nil

function languageTools.getCurrentLanguage()
    return cc.Application:getInstance():getCurrentLanguage()
end

function languageTools.switchTo(lang)
    languageTools._curLanguage = lang
    global.event.emit(global.eventName.UI_REFRESH)
end

function languageTools.addData(key, langVal)
    languageTools._languageSave[key] = langVal
end

function languageTools.L(key)
    local arr = split(key, "%.")
    local cur = languageTools._languageSave[languageTools._curLanguage]
    for i, v in ipairs(arr) do
        if cur[v] then
            cur = cur[v]
        else
            return key
        end
    end
    if type(cur) == "string" then
        return cur
    else
        return key
    end
end

local ret = {}
setmetatable(ret, {
    __call = function( _, name)
        return languageTools.L(name)
    end,
    __newindex = function(_, name, value)
        assert(false, "不可改变")
    end,
    __index = function(_, name)
        return languageTools[name]
    end
})
return ret