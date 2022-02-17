if ccui.LayoutComponent and ccui.LayoutComponent.bindLayoutComponent then 
    return 
end

local LayoutComponent = import(".LayoutComponent")
ccui.LayoutComponent = LayoutComponent

local setLayoutComponentEnabled = function()

end

ccui.Layout.setLayoutComponentEnabled = ccui.Layout.setLayoutComponentEnabled or setLayoutComponentEnabled
ccui.Button.setLayoutComponentEnabled = ccui.Button.setLayoutComponentEnabled or setLayoutComponentEnabled
ccui.ImageView.setLayoutComponentEnabled = ccui.ImageView.setLayoutComponentEnabled or setLayoutComponentEnabled

local addClickEvent = function(self , func)
    self:setTouchEnabled(false)
    local listener = cc.EventListenerTouchOneByOne:create();
    listener:registerScriptHandler(function( pTouch,pEvent )
        if not self:isVisible() then return false end
        local p = pTouch:getLocation()
        local rect = self:getBoundingBox()
        if cc.rectContainsPoint(rect, p) then
            return true
        end
        return false
    end,
    cc.Handler.EVENT_TOUCH_BEGAN); 
    listener:registerScriptHandler(function( ... )
        func(...)
    end,
    cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(true)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

ccui.Layout.addClickEventListener = addClickEvent
ccui.Button.addClickEventListener = addClickEvent
ccui.ImageView.addClickEventListener = addClickEvent