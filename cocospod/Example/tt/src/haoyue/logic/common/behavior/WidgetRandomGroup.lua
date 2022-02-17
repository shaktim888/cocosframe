local WidgetRandomGroup = class("WidgetRandomGroupCompont", cc.load("mvc").BehaviorBase)

local custom_random = nil
local function getRandomImdex(tbl_)
    local index = #tbl_
    local tbl = {}

    for i = 1, index do
        tbl[i] = i
    end
    
    local ret = {}
    repeat 
        if custom_random then
            ret[#ret+1] = table.remove(tbl, custom_random:next(1, #tbl))
        else
            ret[#ret+1] = table.remove(tbl, math.random(1, #tbl))
        end
    until (#tbl==0)

    return ret
end

function WidgetRandomGroup:setRandom(random)
    custom_random = random
end

function WidgetRandomGroup:onCreate()
    if not custom_random then
        self.__randomseed = global.viewMgr.getPageRandomSeed(self.RESOURCE_FILENAME) --tostring(socket.gettime()):reverse():sub(1, 7)
        math.randomseed(self.__randomseed)
    end
end

function WidgetRandomGroup:onEnter()

    print("WidgetRandomGroup ========")
    -- do return end

    local randomgroup = function()
        for k, v in pairs(self.groupMap or {}) do
            local index_t = getRandomImdex(v)
            local pos = {}
            for i = 1, #v do 
                local t = self.mView[v[i]]
                if t then
                    pos[i] = cc.p(t:getPosition())
                end
            end

            for i, sub_index in ipairs(index_t) do
                local t = self.mView[v[sub_index]]
                if t and pos[i] then
                    t:setPosition(pos[i])
                end
            end
        end
    end

    global.async.runInNextFrame(randomgroup)
end

return WidgetRandomGroup