local EventDelayTime = class("EventDelayTime")

function EventDelayTime:ctor(param)
    self.inited = true
    self.targetname = param.targetname
    self.timename = param.timename
    self.time = param.delaytime

    self.executed = false
end

function EventDelayTime:getTargetName()
    return self.targetname
end

function EventDelayTime:executeEnd()
    return self.executed
end

function EventDelayTime:executeEvent(param)
    if self.inited then
        local target = param.target
        if target then
            if (not self.timename) or ((self.timename) and (target.__timeState == self.timename)) then
                self.inited = false
                print("开始等待"..tostring(os.time()))
                performWithDelay(target, function()
                    self.executed = true
                    print("等待结束"..tostring(os.time()))
                end, self.time or 3)
            end
        end
    end
end

return EventDelayTime