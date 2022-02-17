local EventCaptureScreen = class("EventCaptureScreen")

function EventCaptureScreen:ctor(param)
    dump(param)
    -- self.param = param
    self.inited = true
    self.name = param.name
    self.targetname = param.targetname
    
    self.timename = param.timename
    self.savename = param.savename
    self.endcall = param.endcall

    self.executed = false
end

function EventCaptureScreen:executeEnd()
    return self.executed 
end

function EventCaptureScreen:getTargetName()
    return self.targetname
end

function EventCaptureScreen:execute(dt)
    
end

function EventCaptureScreen:executeEvent(param)
    if self.inited then
        local target = param.target
        if target and (self.timename == target.__timeState) then
            self.inited = false

            print(" EventCaptureScreen 1 "..tostring(self.savename))
            cc.utils:captureScreen(function (flag, output)
                local target = param.target
                
                if self.endcall then
                    local func = target[self.endcall]

                    -- print(flag, output)
                    -- print(func, self.endcall)
                    if func and type(func) == "function" then
                        self.executed = true

                        performWithDelay(target, function()       
                            func(target)
                        end, 0.2)
                    else
                        self.executed = true
                    end
                else
                    self.executed = true
                end
            end, self.savename)
        end
    end
end

return EventCaptureScreen