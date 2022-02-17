
local CCStudioAnim = class("CCStudioAnim", cc.load("mvc").BehaviorBase)

function CCStudioAnim:animEnter()
    local action
    local extend = string.lower(self.RESOURCE_FILENAME:match(".+%.(%w+)$"))
    if extend == "csb" then
        action = cc.CSLoader:createTimeline(self.RESOURCE_FILENAME)
    elseif extend == "lua" then
        action = self.__csbAnimation
    end
    action:play("uiEnter", false)
    -- 调用 runAction 函数
    self.mLayout:runAction( action )
end

function CCStudioAnim:animExit()
    if self.inClose then
        return
    end
    self.inClose = true
    local action
    local extend = string.lower(self.RESOURCE_FILENAME:match(".+%.(%w+)$"))
    if extend == "csb" then
        action = cc.CSLoader:createTimeline(self.RESOURCE_FILENAME)
    elseif extend == "lua" then
        action = self.__csbAnimation
    end
    action:play("uiExit", false)
    local closeFunc = function()
        self:removeFromParent()
        self.inClose = false
    end
    self.mLayout:runAction( action );
    self.mLayout:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(closeFunc)))
end

return CCStudioAnim