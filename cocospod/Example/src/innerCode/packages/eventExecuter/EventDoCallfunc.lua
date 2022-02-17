local EventDoCallfunc = class("EventDoCallfunc")

function EventDoCallfunc:ctor(param)
    self.inited = true
    self.targetname = param.targetname
    self.timename = param.timename
    self.call = param.call

    self.executed = false
end

function EventDoCallfunc:getTargetName()
    return self.targetname
end

function EventDoCallfunc:executeEnd()
    return self.executed
end

function EventDoCallfunc:executeEvent(param)
    if self.inited then
        local target = param.target
        if target then
            if (not self.timename) or ((self.timename) and (target.__timeState == self.timename)) then
                self.inited = false

                local func = target[self.call]
                if func and type(func) == "function" then
                    performWithDelay(target, function()
                        func(target)

                        self.executed = true
                    end, 0.1)
                end
            end
        end
    end
end

return EventDoCallfunc