local BlackHover = class("BlackHover", cc.load("mvc").BehaviorBase)

function BlackHover:onCreate()
    local layout = ccui.Layout:create();
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
    layout:setBackGroundColor(cc.c3b(0, 0, 0))
    layout:setOpacity(150)
    layout:setContentSize(display.size)
    layout:setPosition(self:convertToNodeSpaceAR(cc.p(0,0)))
    self:addChild(layout, -99)
end

return BlackHover