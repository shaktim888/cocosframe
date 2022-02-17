
local EventDoCallfunc = import(".EventDoCallfunc")
local EventCaptureScreen = import(".EventCaptureScreen")
local EventDelaytime = import(".EventDelayTime")

local EventExecuter = class("EventExecuter")

local fileutils = cc.FileUtils:getInstance()

function EventExecuter:ctor()
    -- print("EventExecuter:ctor==================")
    self:init()
end

function EventExecuter:init()
    -- print("EventExecuter:init==")
    local confname = "hyeconf"
    if fileutils:isFileExist(confname) then
        global.isGrabScreenMode = 1
        EventExecuter.__event_queen = {}
        -- 缓存所有执行过事件的targetnodes  当没有这个node的时候 就从这里面找
        EventExecuter.__nodes = {}

        local fname = fileutils:fullPathForFilename(confname)
        local content = io.readfile(fname)
        if content and (#content > 0) then
            local conf = json.decode(content)
            local event
            for i, v in ipairs(conf.eventlist) do
                if v.action == "callfunc" then
                    event = EventDoCallfunc:create(v)
                elseif v.action == "delay" then
                    event = EventDelaytime:create(v)
                elseif v.action == "capturescreen" then
                    event = EventCaptureScreen:create(v)
                end

                if event then
                    EventExecuter.__event_queen[#EventExecuter.__event_queen + 1] = event
                    event = nil
                end
            end
            if self:hasEvents() then
                self.schedulehandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.update), 0, false)
            end
        end
    end
end

function EventExecuter:getCurEvent()
    if self:hasEvents() then
        local event_q = EventExecuter.__event_queen or {}
        return event_q[1]
    end
    return nil
end

function EventExecuter:checkEvents()
    local event_q = EventExecuter.__event_queen or {}
    if #event_q == 0 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulehandler)
        os.exit()
    end
end

-- 
function EventExecuter:getCurTargetByName(name)
    EventExecuter.__nodes = EventExecuter.__nodes or {}
    for i, v in ipairs(EventExecuter.__nodes) do
        if not tolua.isnull(v) then
            if v:getClassName() == name then
                return v
            end
        end
    end
    return nil
end

function EventExecuter:timeEvent(param)
    if self:hasEvents() then
        -- 记录target
        if param.target then
            EventExecuter.__nodes = EventExecuter.__nodes or {}
            local index = table.indexof(EventExecuter.__nodes, param.target)
            if not index then
                EventExecuter.__nodes[#EventExecuter.__nodes + 1] = param.target
            end

            param.target.__timeState = param.timename
            dump(param.target)
            print("============ param target named of "..param.target:getClassName().." eventname = "..tostring(param.timename))
            self:update()
        end
    end
end

function EventExecuter:hasEvents()
    EventExecuter.__event_queen = EventExecuter.__event_queen or {}
    return (#EventExecuter.__event_queen > 0)
end

--[[
    节点产生事件通知事件执行器
    事件执行器记录 modele的node 的状态 和node
    每帧处理 事件 检查事件执行条件  符合条件则执行 
]]
function EventExecuter:update(dt)
    
    local e = self:getCurEvent()
    if e then
        local target = self:getCurTargetByName(e:getTargetName())
        if target then
            local param = {
                target = target,
            }
            
            e:executeEvent(param)
            if e:executeEnd() then
                table.remove(EventExecuter.__event_queen, 1)
            end
        end

        EventExecuter.__nodes = EventExecuter.__nodes or {}
        for i = #EventExecuter.__nodes, 1, -1 do
            local v = EventExecuter.__nodes[i]
            if v and tolua.isnull(v) then
                table.remove(EventExecuter.__nodes, i)
            end
        end
    end

    self:checkEvents()
end

return EventExecuter